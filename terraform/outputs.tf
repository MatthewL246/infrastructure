output "hetz_de_ipv4" {
  description = "Public IPv4 address of the hetz-de server."
  value       = hcloud_server.hetz_de.ipv4_address
}

output "hetz_de_ipv6" {
  description = "Public IPv6 address of the hetz-de server."
  value       = hcloud_server.hetz_de.ipv6_address
}
