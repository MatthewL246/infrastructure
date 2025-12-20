#! /usr/bin/env bash

set -euo pipefail


# Starting setup
base_dir="$(dirname "$(realpath "$0")")"

# Ansible requires an SSH agent to be running because it can't ask for the key passphrase by itself
r="0"
ssh-add -l >/dev/null 2>&1 || r="$?"
if [[ "$r" == 2 ]]; then
    # Failed to connect to SSH agent
    eval "$(ssh-agent)"
fi

ssh-add -l >/dev/null 2>&1 || r="$?"
if [[ "$r" == 1 ]]; then
    # No keys have been added
    ssh-add
fi


# Terraform operations
cd "$base_dir/terraform"

tofu validate && tflint
tofu apply

json_data="$(tofu show -json)"
hetz_de_ip="$(echo "$json_data" | jq --raw-output ".values.outputs.hetz_de_ipv4.value")"
hetz_de_ssh_port="$(echo "$json_data" | jq --raw-output ".values.root_module.resources[] | select (.address == \"terraform_data.hetz_de_ssh_port\") | .values.output")"
hetz_de_first_time_setup_completed="$(echo "$json_data" | jq --raw-output ".values.root_module.resources[] | select (.address == \"terraform_data.hetz_de_first_time_setup_completed\") | .values.output")"

if [[ "$hetz_de_first_time_setup_completed" = "false" ]]; then
    hetz_de_user=root
else
    hetz_de_user=matthew
fi


# Ansible operations
cd "$base_dir/ansible"

generated_inventory="$(mktemp)"
echo "hetz-de ansible_host=$hetz_de_ip ansible_port=$hetz_de_ssh_port ansible_user=$hetz_de_user" >"$generated_inventory"

ansible-playbook --inventory "$generated_inventory" --diff --verbose ./hetz-de.yml

rm "$generated_inventory"
