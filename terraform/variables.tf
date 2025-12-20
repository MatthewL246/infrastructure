variable "hetzner_cloud_token" {
  description = "Token for the Hetzner Cloud project (read/write)."
  type        = string
  sensitive   = true
}

variable "hetzner_ssh_keys" {
  description = "SSH keys for Hetzner servers, which will be authorized on all servers. Key is name (user@hostname), value is public key (ssh-ed25519 ...)."
  type        = map(string)
}

variable "hetz_de_first_time_setup_completed" {
  description = "Has first-time setup been completed for the hetz-de server? If this is false, SSH connections must use the root user."
  type        = bool
  default     = false
}

variable "hetz_de_ssh_port" {
  description = "SSH port used by the hetz-de server."
  type        = number
  default     = 22
}

variable "cloudflare_api_token" {
  description = "Cloudflare account API token (required single-zone permissions: DNS:Edit)."
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the website (must match the one authorized by the API token)."
  type        = string
  sensitive   = true
}
