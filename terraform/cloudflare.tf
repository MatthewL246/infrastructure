provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "cloudflare_zone" "primary_domain" {
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_dns_record" "gateway_ipv4" {
  zone_id = var.cloudflare_zone_id
  name    = "gateway-staging"
  type    = "A"
  content = hcloud_server.gateway.ipv4_address
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "gateway_ipv6" {
  zone_id = var.cloudflare_zone_id
  name    = "gateway-staging"
  type    = "AAAA"
  content = hcloud_server.gateway.ipv6_address
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "headscale_ipv4" {
  zone_id = var.cloudflare_zone_id
  name    = "headscale-staging"
  type    = "A"
  content = hcloud_server.gateway.ipv4_address
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "headscale_ipv6" {
  zone_id = var.cloudflare_zone_id
  name    = "headscale-staging"
  type    = "AAAA"
  content = hcloud_server.gateway.ipv6_address
  ttl     = 1
  proxied = false
}
