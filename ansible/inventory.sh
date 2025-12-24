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
hetz_nbg_ip="$(echo "$terraform_state" | jq --raw-output ".values.outputs.hetz_nbg_ipv4.value")"
hetz_nbg_ssh_port="$(echo "$terraform_state" | jq --raw-output ".values.outputs.hetz_nbg_ssh_port.value")"
hetz_nbg_password="$(pass show hetz_nbg_password)"
hetz_nbg_password_hash="$(pass show hetz_nbg_password_hash)"

inventory_template='
{
    "ungrouped": {
        "hosts": [
            "hetz-nbg"
        ]
    },
    "all": {
        "children": [
            "ungrouped"
        ]
    },
    "_meta": {
        "hostvars": {
            "hetz-nbg": {
                "ansible_host": $hetz_nbg_ip,
                "ansible_port": $hetz_nbg_ssh_port,
                "ansible_user": "matthew",
                "ansible_become_password": $hetz_nbg_password,
                "ansible_pipelining": true,
                "password_hash": $hetz_nbg_password_hash
            }
        }
    }
}'

jq --null-input \
    --arg hetz_nbg_ip "$hetz_nbg_ip" \
    --arg hetz_nbg_ssh_port "$hetz_nbg_ssh_port" \
    --arg hetz_nbg_password "$hetz_nbg_password" \
    --arg hetz_nbg_password_hash "$hetz_nbg_password_hash" \
    "$inventory_template"
