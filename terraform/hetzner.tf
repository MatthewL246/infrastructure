provider "hcloud" {
  token = local.hetzner_token
}

locals {
  # I chose Nuremberg because it supports cost-optimized servers and is physically slightly closer to the US
  # https://docs.hetzner.com/cloud/general/locations/#what-datacenters-are-there
  gateway_location = "nbg1"
}

resource "random_integer" "gateway_ssh_port" {
  min = 1025
  max = 65535
}

# Exists to prevent Hetzner from automatically generating a root password for the server, so it keeps the root account locked. Just uses a throwaway key I generated and then deleted. Setting allow_public_ssh_keys to false in the cloud-init user data prevents this key from actually being authorized.
resource "hcloud_ssh_key" "dummy" {
  name       = "dummy"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPTgbKioreT00Lh7VQpNNeqxNVfe3Pr5qm1Y6onUl5OL"
}

resource "hcloud_primary_ip" "gateway_ipv4" {
  name        = "gateway-ipv4"
  location    = local.gateway_location
  type        = "ipv4"
  auto_delete = false

  # Avoid deleting IP addresses because IP reputation is a thing
  delete_protection = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "hcloud_primary_ip" "gateway_ipv6" {
  name        = "gateway-ipv6"
  location    = local.gateway_location
  type        = "ipv6"
  auto_delete = false

  delete_protection = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "hcloud_firewall" "gateway" {
  name = "gateway-firewall"

  rule {
    description = "Allow all ICMP"
    direction   = "in"
    protocol    = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  rule {
    description = "Allow SSH"
    direction   = "in"
    protocol    = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
    port = random_integer.gateway_ssh_port.result
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

resource "hcloud_server" "gateway" {
  name        = "gateway"
  location    = local.gateway_location
  server_type = "cax11"

  # I used to use Ubuntu but decided to switch to Debian for a few reasons: it doesn't force you to use Snap, it is more upstream and (in theory) more stable, it is in general less commercial and more open-source
  image    = "debian-13"
  ssh_keys = [hcloud_ssh_key.dummy.id]
  # For potential future upgrades and downgrades
  keep_disk = true
  # Prefer manual snapshots for cost reasons
  backups = false

  # Minimal cloud-init user data is needed to configure users and SSH so that Ansible can connect for the first time
  user_data = "#cloud-config\n${yamlencode({
    users = [{
      name   = "matthew"
      groups = ["sudo"]
      # TODO: don't rely on GitHub to store SSH keys
      ssh_import_id = ["gh:MatthewL246"]
      # Keep the account unlocked so SSH access is allowed and sudo works
      lock_passwd = false
      passwd      = local.gateway_password_hash
    }]
    # Don't actually authorize the dummy SSH key
    allow_public_ssh_keys = false
    write_files = [{
      # Minimal secure SSH daemon configuration, will be replaced with an Ansible-managed one
      path    = "/etc/ssh/sshd_config"
      content = <<-EOT
        Port ${random_integer.gateway_ssh_port.result}
        PermitRootLogin no
        PasswordAuthentication no
        KbdInteractiveAuthentication no
      EOT
    }]
    runcmd = [
      "systemctl restart ssh.service"
    ]
  })}"

  public_net {
    ipv4 = hcloud_primary_ip.gateway_ipv4.id
    ipv6 = hcloud_primary_ip.gateway_ipv6.id
  }

  firewall_ids = [hcloud_firewall.gateway.id]

  lifecycle {
    # Recommended by the hcloud provider docs because these cannot be updated in-place but only matter for initial server creation
    ignore_changes = [ssh_keys, user_data]
  }
}
