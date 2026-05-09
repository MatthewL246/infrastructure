variable "hetzner_token_name" {
  description = "Name of the Hetzner Cloud API token stored in pass. Required permissions: read/write."
  type        = string
  ephemeral   = true
}

variable "cloudflare_token_name" {
  description = "Name of the Cloudflare account API token stored in pass. Required permissions: single-zone DNS edit."
  type        = string
  ephemeral   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the website (must match the one authorized by the API token)."
  type        = string
  sensitive   = true
}

# I wanted to use an ephemeral variable for the password, use a random_bytes resource to generate the salt, and create the hash inside Terraform. but it turns out that there isn't any good way to "convert" an ephemeral variable into a non-ephemeral one.
#
# - Data sources like "local_command" and "external" can't read ephemeral variables because they need to store their full commands in the state (which would include the plaintext password).
# - A "local-exec" provisioner could access the ephemeral variable, but there is no way to use its output (without something messy like writing it to a file and then reading that file later).
# - Setting a temporary password and using a "remote-exec" provisioner to SSH in and change it would be an option but is also quite messy. Terraform shouldn't be making SSH connections.
#
# In the end, storing a password hash in the same place as password isn't terrible, I just need to be careful to change the hash when I change the password.
#
# Revisit this if the hcloud provider is updated to allow using ephemeral variables in user_data or if there is an easier way to create a non-ephemeral hash from an ephemeral variable.
variable "gateway_password_hash_name" {
  description = "Name of the password hash stored in pass to apply to the matthew account on the gateway server. Generate this with `mkpasswd -m yescrypt`."
  type        = string
}
