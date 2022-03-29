terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.6"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://10.0.0.4:8006/api2/json"
  pm_tls_insecure = true
  pm_debug        = true
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
}
