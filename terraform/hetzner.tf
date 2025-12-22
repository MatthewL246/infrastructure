provider "hcloud" {
  token = var.hetzner_cloud_token
}

locals {
  # I chose Nuremberg because it supports cost-optimized servers and is physically slightly closer to the US
  # https://docs.hetzner.com/cloud/general/locations/#what-datacenters-are-there
  hetz_de_datacenter = "nbg1-dc3"
}

resource "random_integer" "hetz_de_ssh_port" {
  min = 1025
  max = 65535
}

# Exists to prevent Hetzner from automatically generating a root password for the server, so it keeps the root account locked. Just uses a throwaway key I generated and then deleted. Setting allow_public_ssh_keys to false in the cloud-init user data prevents this key from actually being authorized.
resource "hcloud_ssh_key" "dummy" {
  name       = "dummy"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPTgbKioreT00Lh7VQpNNeqxNVfe3Pr5qm1Y6onUl5OL"
}

resource "hcloud_primary_ip" "hetz_de_ipv4" {
  name          = "hetz_de_ipv4"
  datacenter    = local.hetz_de_datacenter
  type          = "ipv4"
  auto_delete   = false
  assignee_type = "server"
  # TODO: once this is in prod, enable delete_protection and lifecycle.prevent_destroy
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

  rule {
    description = "Allow SSH"
    direction   = "in"
    protocol    = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
    port = random_integer.hetz_de_ssh_port.result
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
      passwd      = var.hetz_de_password_hash
    }]
    # Don't actually authorize the dummy SSH key
    allow_public_ssh_keys = false
    write_files = [{
      # Minimal secure SSH daemon configuration, will be replaced with an Ansible-managed one
      path    = "/etc/ssh/sshd_config"
      content = <<-EOT
        Port ${random_integer.hetz_de_ssh_port.result}
        PermitRootLogin no
        PasswordAuthentication no
        KbdInteractiveAuthentication no
      EOT
    }]
    runcmd = [
      "systemctl daemon-reload",
      "systemctl restart ssh.service ssh.socket"
    ]
  })}"

  public_net {
    ipv4 = hcloud_primary_ip.hetz_de_ipv4.id
    ipv6 = hcloud_primary_ip.hetz_de_ipv6.id
  }

  firewall_ids = [hcloud_firewall.hetz_de.id]

  lifecycle {
    # Recommended by the hcloud provider docs because these cannot be updated in-place but only matter for initial server creation
    ignore_changes = [ssh_keys, user_data]
  }
}
