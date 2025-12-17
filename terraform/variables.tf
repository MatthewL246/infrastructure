variable "hetzner_cloud_token" {
  description = "Token for the Hetzner Cloud project (read/write)"
  type        = string
  sensitive   = true
}

variable "hetzner_ssh_keys" {
  description = "SSH keys for Hetzner servers, which will be authorized on all servers. Key is name (user@hostname), value is public key (ssh-ed25519 ...)"
  type        = map(string)
}
