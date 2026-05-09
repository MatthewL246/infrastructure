terraform {
  required_version = "~> 1.11.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.8.0"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.62.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.19.1"
    }
  }
}

# I tried using the Ansible Terraform provider (https://github.com/ansible/terraform-provider-ansible) but found it
# half-baked and annoying to use
# - You can only view a playbook's output after it has completely finished
# - The ansible_inventory resource is useless because you can't actually use it with an ansible_playbook resource:
#   https://github.com/ansible/terraform-provider-ansible/issues/37
# - Development seems to have stalled since 2024
