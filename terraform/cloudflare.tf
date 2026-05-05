provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_dns_record" "gateway_ipv4" {
  zone_id = var.cloudflare_zone_id
  name    = "gateway"
  type    = "A"
  content = hcloud_server.gateway.ipv4_address
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "gateway_ipv6" {
  zone_id = var.cloudflare_zone_id
  name    = "gateway"
  type    = "AAAA"
  content = hcloud_server.gateway.ipv6_address
  ttl     = 1
  proxied = false
}
