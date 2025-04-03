# ☁️ Fully Automated SSL + Reverse Proxy with Terraform + Traefik + Cloudflare

![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)

> 🔧 Built entirely by a **2nd-year university student** during an internship — fully automated and production-ready.

---

## 🚀 About This Project

This project automates SSL certificate issuance, DNS record creation, and reverse proxy setup for internal services running on **private servers without public IPs**. It uses:

- **Terraform** for orchestration
- **Traefik** for reverse proxy and HTTPS
- **Cloudflare DNS** for domain management
- **MinIO** as the Terraform backend
- **Twingate** (or other zero-trust solutions) for private server access

All of it is wrapped into reusable Terraform modules to spin up a full reverse proxy setup — with just one command.

---

## 🧱 Stack

- **Terraform** (with `null`, `cloudflare`, and `aws` providers)
- **Traefik v2.10**
- **Cloudflare DNS**
- **MinIO** (as an S3 backend for Terraform)
- **Twingate** (for private network access)
- **Bash** (for server-side automation)
- **Systemd** (to manage the Traefik service)

---

## 📂 Directory Structure

```
.
├── main.tf
├── variables.tf
├── terraform.tfvars
├── modules/
│   └── traefik/
│       ├── main.tf
├── scripts/
│   ├── setup_traefik.sh
│   └── clean_treafik.sh
├── files/
│   ├── traefik.toml
│   └── traefik.service
└── README.md
```

---

## 🔧 Requirements

- A domain managed via Cloudflare
- A Cloudflare API Key / API Token
- SSH access to internal/private servers
- [MinIO](https://min.io/) server for Terraform backend (or any compatible S3 service)
- [Twingate](https://www.twingate.com/) (or other private VPN solution)

---

## 📦 Deployment

### Step 1: Configure Variables

Fill in your values in `terraform.tfvars`:

```hcl
cloudflare_api_email   = "you@example.com"
cloudflare_api_key     = "your-global-api-key"
cloudflare_zone_id     = "zone-id"
controller2_server_ip  = "192.168.0.2"
ssh_user               = "root"
ssh_private_key_path   = "~/.ssh/id_rsa"
```

### Step 2: Deploy Traefik

```bash
terraform apply -target=null_resource.traefik_deployment
```

### Step 3: Add Services

```hcl
module "service_portainer" {
  source               = "./modules/traefik"
  service_name         = "portainer"
  domain               = "portainer.example.com"
  backend_url          = "http://192.168.0.3:9443"
  cloudflare_email     = var.cloudflare_api_email
  cloudflare_api_token = var.cloudflare_api_token
  server_two_ip        = var.controller2_server_ip
  ssh_user             = var.ssh_user
  ssh_private_key_path = var.ssh_private_key_path
}
```

### Step 4: Access via browser

Navigate to `https://portainer.example.com` with valid SSL, issued automatically via Let's Encrypt.

---

## 🤝 Contributing

Contributions are welcome! If you’d like to:
- Add support for more providers
- Add health checks or monitoring
- Enhance module structure

Feel free to fork the repo and submit a PR!

---

## 👨‍💻 Author

Made with 💻 by **Yasindu Dissanayake** a 2nd year CS student & DevOps intern passionate about automating infrastructure.

---

## 📜 License

Licensed under the **Apache 2.0 License**.
Feel free to fork, build upon, and contribute.

---

## 🧠 Final Thoughts

No public IPs? 🕵️
No Nginx? 🛑
One command? ✅

Just pure Terraform + Traefik + Cloudflare DNS magic.

**Now imagine what I’ll build next.**

