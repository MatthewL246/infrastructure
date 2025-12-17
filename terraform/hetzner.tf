provider "hcloud" {
  token = var.hetzner_cloud_token
}

locals {
  # I chose Nuremberg because it supports cost-optimized servers and is physically slightly closer to the US
  # https://docs.hetzner.com/cloud/general/locations/#what-datacenters-are-there
  hetz_de_datacenter = "nbg1-dc3"
}

resource "hcloud_ssh_key" "keys" {
  for_each = var.hetzner_ssh_keys

  name       = each.key
  public_key = each.value
}

resource "hcloud_primary_ip" "hetz_de_ipv4" {
  name          = "hetz_de_ipv4"
  datacenter    = local.hetz_de_datacenter
  type          = "ipv4"
  auto_delete   = false
  assignee_type = "server"
}

resource "hcloud_primary_ip" "hetz_de_ipv6" {
  name          = "hetz_de_ipv6"
  datacenter    = local.hetz_de_datacenter
  type          = "ipv6"
  auto_delete   = false
  assignee_type = "server"
}

resource "hcloud_firewall" "hetz_de" {
  name = "hetz_de_firewall"

  rule {
    description = "Allow all ICMP"
    direction   = "in"
    protocol    = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  dynamic "rule" {
    for_each = var.hetz_de_ssh_port_changed ? [] : [1]

    content {
      description = "Allow SSH (default port for first-time setup)"
      direction   = "in"
      protocol    = "tcp"
      source_ips = [
        "0.0.0.0/0",
        "::/0"
      ]
      port = "22"
    }
  }

  rule {
    description = "Allow SSH"
    direction   = "in"
    protocol    = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
    port = "20022"
  }

  rule {
    description = "Allow WireGuard"
    direction   = "in"
    protocol    = "udp"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
    port = "51820"
  }

  rule {
    description = "Allow HTTP"
    direction   = "in"
    protocol    = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
    port = "80"
  }

  rule {
    description = "Allow HTTPS"
    direction   = "in"
    protocol    = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
    port = "443"
  }
}

resource "hcloud_server" "hetz_de" {
  name        = "hetz-de"
  datacenter  = local.hetz_de_datacenter
  server_type = "cax11"

  image    = "ubuntu-24.04"
  ssh_keys = [for key in values(hcloud_ssh_key.keys) : key.id]
  # For potential future upgrades and downgrades
  keep_disk = true
  # Prefer manual snapshots for cost reasons
  backups = false

  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.hetz_de_ipv4.id
    ipv6_enabled = true
    ipv6         = hcloud_primary_ip.hetz_de_ipv6.id
  }

  firewall_ids = [hcloud_firewall.hetz_de.id]

  lifecycle {
    # Recommended by the hcloud provider docs because a server's SSH keys cannot be updated in-place
    ignore_changes = [ssh_keys]
  }
}
