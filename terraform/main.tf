terraform {
  required_version = "~> 1.11.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.57.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.14.0"
    }
  }
}
