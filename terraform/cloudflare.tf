provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_dns_record" "hetz_nbg_ipv4" {
  zone_id = var.cloudflare_zone_id
  name    = "hetz-nbg"
  type    = "A"
  content = hcloud_server.hetz_nbg.ipv4_address
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "hetz_nbg_ipv6" {
  zone_id = var.cloudflare_zone_id
  name    = "hetz-nbg"
  type    = "AAAA"
  content = hcloud_server.hetz_nbg.ipv6_address
  ttl     = 1
  proxied = false
}
