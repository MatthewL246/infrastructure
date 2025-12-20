provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_dns_record" "terraform_test_ipv4" {
  zone_id = var.cloudflare_zone_id
  name    = "terraform_test"
  type    = "A"
  content = hcloud_server.hetz_de.ipv4_address
  ttl     = 1
  proxied = false
  comment = "Terraform test record (IPv4)"
}

resource "cloudflare_dns_record" "terraform_test_ipv6" {
  zone_id = var.cloudflare_zone_id
  name    = "terraform_test"
  type    = "AAAA"
  content = hcloud_server.hetz_de.ipv6_address
  ttl     = 1
  proxied = false
  comment = "Terraform test record (IPv6)"
}
