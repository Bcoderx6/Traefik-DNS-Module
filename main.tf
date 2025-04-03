terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = ""
    key    = ""
    region = ""

    endpoints = {
      s3 = ""
    }
    access_key = ""
    secret_key = ""

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}

provider "cloudflare" {
  email   = var.cloudflare_api_email
  api_key = var.cloudflare_api_key
}


# AWS Provider for Minio
provider "aws" {
  region = "us-east-1"

  # Minio-specific settings
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  # Endpoint configuration
  endpoints {
    s3 = ""
  }

  # Access credentials
  access_key = ""
  secret_key = ""
}

# Create Cloudflare Records

resource "cloudflare_record" "sonarqube" {
  zone_id = var.cloudflare_zone_id
  name    = "sonarqube"
  content   = var.controller2_server_ip
  type    = "A"
  proxied = false
}

provider "null" {}

# Modules for create Services

module "service_sonarqube" {
  source = "./modules/traefik"

  cloudflare_email     = var.cloudflare_api_email
  cloudflare_api_token = var.cloudflare_api_key

  server_two_ip        = var.controller2_server_ip
  ssh_user             = var.ssh_user
  ssh_private_key_path = var.ssh_private_key_path

  service_name         = "sonarqube"
  domain               = "sonarqube.yash.com"
  backend_url          = "http://192.168.8.1:9000"
  entry_points         = ["websecure"]
}

# Treafik Deployment

resource "null_resource" "traefik_deployment" {
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    host        = var.controller2_server_ip
  }

  # Copy Treafik Setup Script
  provisioner "file" {
    source      = "${path.module}/scripts/setup_traefik.sh"
    destination = "/tmp/setup_traefik.sh"
  }

  # Copy Treafik cleanup for Terraform Destroy

  provisioner "file" {
    source      = "${path.module}/scripts/clean_treafik.sh"
    destination = "/tmp/clean_treafik.sh"
  }

  # Copy Treafik configuration files

  provisioner "file" {
    source      = "${path.module}/files/traefik.toml"
    destination = "/tmp/traefik.toml"
  }

  provisioner "file" {
    source      = "${path.module}/files/traefik.service"
    destination = "/tmp/traefik.service"
  }

  # Execute Treafik setup

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup_traefik.sh",
      "chmod +x /tmp/clean_treafik.sh",
      "sudo /tmp/setup_traefik.sh '${var.cloudflare_api_email}' '${var.cloudflare_api_token}' '${var.domain_name}'"
    ]
  }

  # Setup Trigger For Cleanup

  triggers = {
    server_ip         = var.controller2_server_ip
    ssh_user          = var.ssh_user
    ssh_private_key   = var.ssh_private_key_path
  }
}

resource "null_resource" "traefik_cleanup" {
  depends_on = [null_resource.traefik_deployment]

  triggers = {
    deployment_id     = null_resource.traefik_deployment.id
    server_ip         = null_resource.traefik_deployment.triggers.server_ip
    ssh_user          = null_resource.traefik_deployment.triggers.ssh_user
    ssh_private_key   = null_resource.traefik_deployment.triggers.ssh_private_key
  }

  # Run with Terraform Destroy

  provisioner "remote-exec" {
    when = destroy

    connection {
      type        = "ssh"
      user        = self.triggers.ssh_user
      private_key = file(self.triggers.ssh_private_key)
      host        = self.triggers.server_ip
    }

    inline = [
      "echo 'Running cleanup script...'",
      "sudo /tmp/clean_treafik.sh || echo 'Cleanup script failed, but continuing'"
    ]
  }
}