#! /usr/bin/env bash

set -euo pipefail

base_dir="$(dirname "$(realpath "$0")")/.."

# Ansible requires an SSH agent to be running because it can't ask for the key passphrase by itself
r=0
ssh-add -l >/dev/null 2>&1 || r=$?
if [[ "$r" == 2 ]]; then
    # Failed to connect to SSH agent
    eval "$(ssh-agent)"
fi

ssh-add -l >/dev/null 2>&1 || r=$?
if [[ "$r" == 1 ]]; then
    # No keys have been added
    ssh-add
fi

cd "$base_dir/terraform"

json_data="$(tofu show -json)"
hetz_de_ip="$(echo "$json_data" | jq --raw-output ".values.outputs.hetz_de_ipv4.value")"
hetz_de_ssh_port="$(echo "$json_data" | jq --raw-output ".values.outputs.hetz_de_ssh_port.value")"

cd "$base_dir/ansible"

generated_inventory="$(mktemp)"
trap 'rm -f "$generated_inventory"' EXIT
echo "hetz-de ansible_host=$hetz_de_ip ansible_port=$hetz_de_ssh_port ansible_user=matthew" >>"$generated_inventory"

ansible-playbook --inventory "$generated_inventory" --diff --verbose -v ./hetz-de.yml --check
