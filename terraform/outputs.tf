output "hetz_nbg_ipv4" {
  description = "Public IPv4 address of the hetz-nbg server."
  value       = hcloud_server.hetz_nbg.ipv4_address
}

output "hetz_nbg_ipv6" {
  description = "Public IPv6 address of the hetz-nbg server."
  value       = hcloud_server.hetz_nbg.ipv6_address
}

output "hetz_nbg_ssh_port" {
  description = "SSH port of the hetz-nbg server."
  value       = random_integer.hetz_nbg_ssh_port.result
}
