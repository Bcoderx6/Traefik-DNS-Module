variable "ssh_user" {
  description = "SSH username to connect to the server"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "controller2_server_ip" {
  description = "IP address of the controller server"
  type        = string
}

variable "server_two_ip" {
  description = "IP address of the controller server"
  type        = string
}

variable "server_hostname" {
  description = "Hostname of the controller server"
  type        = string
}

variable "domain_name" {
  description = "Base domain name for your services"
  type        = string
}

variable "cloudflare_api_email" {
  description = "Cloudflare API email"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for your domain"
  type        = string
}
variable "cloudflare_api_key" {
  description = "Cloudflare API key"
  type        = string
  sensitive   = true
}