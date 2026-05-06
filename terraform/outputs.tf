output "gateway_ipv4" {
  description = "Public IPv4 address of the gateway server."
  value       = hcloud_server.gateway.ipv4_address
}

output "gateway_ipv6" {
  description = "Public IPv6 address of the gateway server."
  value       = hcloud_server.gateway.ipv6_address
}

output "gateway_ssh_port" {
  description = "SSH port of the gateway server."
  value       = random_integer.gateway_ssh_port.result
}

output "email_domain" {
  # TODO: use an MX record instead
  description = "Name of a domain that can receive emails."
  value       = data.cloudflare_zone.primary_domain.name
}

output "headscale_hostname" {
  description = "Hostname of the Headscale server."
  value       = cloudflare_dns_record.headscale_ipv4.name
}
