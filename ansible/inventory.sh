#! /usr/bin/env bash

set -euo pipefail

# See https://docs.ansible.com/projects/ansible/latest/dev_guide/developing_inventory.html#developing-inventory-scripts
if [[ "$*" != "--list" ]]; then
    echo "Error: expected --list to be the only argument."
    exit 1
fi

base_dir="$(dirname "$(realpath "$0")")/.."
cd "$base_dir/terraform"

inventory_template='
{
    "all": {
        "hosts": [
            "gateway"
        ]
    },
    "_meta": {
        "hostvars": {
            "gateway": {
                "ansible_host": $gateway_ip,
                "ansible_port": $gateway_ssh_port,
                "ansible_user": "matthew",
                "ansible_become_password": $gateway_password,
                "ansible_pipelining": true,
                "password_hash": $gateway_password_hash,
                "email_domain": $email_domain,
                "headscale_hostname": $headscale_hostname
            }
        }
    }
}'

jq --null-input \
    --arg gateway_ip "$(tofu output -raw gateway_ipv4)" \
    --arg gateway_ssh_port "$(tofu output --raw gateway_ssh_port)" \
    --arg gateway_password "$(pass show gateway_password)" \
    --arg gateway_password_hash "$(pass show gateway_password_hash)" \
    --arg email_domain "$(tofu output --raw email_domain)" \
    --arg headscale_hostname "$(tofu output --raw headscale_hostname)" \
    "$inventory_template"
