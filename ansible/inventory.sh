#! /usr/bin/env bash

set -euo pipefail

# See https://docs.ansible.com/projects/ansible/latest/dev_guide/developing_inventory.html#developing-inventory-scripts
if [[ "$*" != "--list" ]]; then
    echo "Error: expected --list to be the only argument."
    exit 1
fi

base_dir="$(dirname "$(realpath "$0")")/.."
cd "$base_dir/terraform"

terraform_state="$(tofu show -json)"
gateway_ip="$(echo "$terraform_state" | jq --raw-output ".values.outputs.gateway_ipv4.value")"
gateway_ssh_port="$(echo "$terraform_state" | jq --raw-output ".values.outputs.gateway_ssh_port.value")"
gateway_password="$(pass show gateway_password)"
gateway_password_hash="$(pass show gateway_password_hash)"

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
                "password_hash": $gateway_password_hash
            }
        }
    }
}'

jq --null-input \
    --arg gateway_ip "$gateway_ip" \
    --arg gateway_ssh_port "$gateway_ssh_port" \
    --arg gateway_password "$gateway_password" \
    --arg gateway_password_hash "$gateway_password_hash" \
    "$inventory_template"
