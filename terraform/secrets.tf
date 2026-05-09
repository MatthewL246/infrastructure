ephemeral "local_command" "hetzner_token" {
  command   = "pass"
  arguments = ["show", var.hetzner_token_name]
}

ephemeral "local_command" "cloudflare_token" {
  command   = "pass"
  arguments = ["show", var.cloudflare_token_name]
}

data "local_command" "gateway_password_hash" {
  command   = "pass"
  arguments = ["show", var.gateway_password_hash_name]
}

locals {
  hetzner_token         = sensitive(chomp(ephemeral.local_command.hetzner_token.stdout))
  cloudflare_token      = sensitive(chomp(ephemeral.local_command.cloudflare_token.stdout))
  gateway_password_hash = sensitive(chomp(data.local_command.gateway_password_hash.stdout))
}
