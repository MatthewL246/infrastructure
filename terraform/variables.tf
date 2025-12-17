variable "hetzner_cloud_token" {
  description = "Token for the Hetzner Cloud project (read/write)"
  type        = string
  sensitive   = true
}

variable "hetzner_ssh_keys" {
  description = "SSH keys for Hetzner servers, which will be authorized on all servers. Key is name (user@hostname), value is public key (ssh-ed25519 ...)"
  type        = map(string)
}

variable "hetz_de_ssh_port_changed" {
  description = "Has the SSH port of the hetz-de server been changed from the default? Used to configure the firewall."
  type        = bool
  default     = false
}

variable "cloudflare_api_token" {
  description = "Cloudflare account API token (required single-zone permissions: DNS:Edit)"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the website (must match the one authorized by the API token)"
  type        = string
  sensitive   = true
}
