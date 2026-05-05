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
