provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_dns_record" "terraform_test_ipv4" {
  zone_id = var.cloudflare_zone_id
  name    = "terraform_test"
  type    = "A"
  content = hcloud_primary_ip.hetz_de_ipv4.ip_address
  ttl     = 1
  proxied = false
  comment = "Terraform test record (IPv4)"
}

resource "cloudflare_dns_record" "terraform_test_ipv6" {
  zone_id = var.cloudflare_zone_id
  name    = "terraform_test"
  type    = "AAAA"
  content = cidrhost(hcloud_primary_ip.hetz_de_ipv6.ip_network, 1)
  ttl     = 1
  proxied = false
  comment = "Terraform test record (IPv6)"
}
