# variables For Modules

variable "server_two_ip" {
  description = "IP address of the server running Traefik"
  type        = string
}

variable "ssh_user" {
  description = "SSH username to connect to the server"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key"
  type        = string
}

variable "service_name" {
  description = "Name of the service"
  type        = string
}

variable "domain" {
  description = "Domain name for the service"
  type        = string
}

variable "backend_url" {
  description = "Backend URL for the service"
  type        = string
}

variable "entry_points" {
  description = "Entry points for the router"
  type        = list(string)
  default     = ["websecure"]
}

variable "cert_resolver" {
  description = "Certificate resolver to use"
  type        = string
  default     = "cloudflare"
}

variable "cloudflare_email" {
  description = "Cloudflare email for DNS challenge"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token for DNS challenge"
  type        = string
  sensitive   = true
}

locals {
  formatted_entry_points = join(", ", [for ep in var.entry_points : "\"${ep}\""])
}

# Deploy Modules Service

resource "null_resource" "deploy_service" {
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    host        = var.server_two_ip
  }

  # Create Cloudflare ENV File

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/traefik",
      "sudo bash -c 'echo \"CF_API_EMAIL=${var.cloudflare_email}\" > /etc/traefik/cloudflare.env'",
      "sudo bash -c 'echo \"CF_API_KEY=${var.cloudflare_api_token}\" >> /etc/traefik/cloudflare.env'",
      "sudo chown traefik:traefik /etc/traefik/cloudflare.env",
      "sudo chmod 600 /etc/traefik/cloudflare.env"
    ]
  }

  # Create service configuration

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/traefik/config",
      "echo '[http.routers.${var.service_name}]' | sudo tee /etc/traefik/config/${var.service_name}.toml > /dev/null",
      "echo '  rule = \"Host(`${var.domain}`)\"' | sudo tee -a /etc/traefik/config/${var.service_name}.toml > /dev/null",
      "echo '  service = \"${var.service_name}\"' | sudo tee -a /etc/traefik/config/${var.service_name}.toml > /dev/null",
      "echo '  entryPoints = [${local.formatted_entry_points}]' | sudo tee -a /etc/traefik/config/${var.service_name}.toml > /dev/null",
      "echo '' | sudo tee -a /etc/traefik/config/${var.service_name}.toml > /dev/null",
      "echo '[http.routers.${var.service_name}.tls]' | sudo tee -a /etc/traefik/config/${var.service_name}.toml > /dev/null",
      "echo '    certResolver = \"${var.cert_resolver}\"' | sudo tee -a /etc/traefik/config/${var.service_name}.toml > /dev/null",
      "echo '' | sudo tee -a /etc/traefik/config/${var.service_name}.toml > /dev/null",
      "echo '[http.services.${var.service_name}.loadBalancer]' | sudo tee -a /etc/traefik/config/${var.service_name}.toml > /dev/null",
      "echo '  [[http.services.${var.service_name}.loadBalancer.servers]]' | sudo tee -a /etc/traefik/config/${var.service_name}.toml > /dev/null",
      "echo '    url = \"${var.backend_url}\"' | sudo tee -a /etc/traefik/config/${var.service_name}.toml > /dev/null"
    ]
  }

  # Setup Trigger Replace Value When Changes

  triggers = {
    service_name = var.service_name
    domain       = var.domain
    backend_url  = var.backend_url
    entry_points = join(",", var.entry_points)
  }
}

output "service_name" {
  value = var.service_name
}

output "domain" {
  value = var.domain
}