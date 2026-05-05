#! /usr/bin/env bash

set -euo pipefail

base_dir="$(dirname "$(realpath "$0")")/.."

# Ansible requires an SSH agent to be running because it can't ask for the key passphrase by itself
r=0
ssh-add -l >/dev/null 2>&1 || r=$?
if [[ "$r" == 2 ]]; then
    echo "Failed to connect to SSH agent, running ssh-agent..."
    ssh_agent_vars="$(ssh-agent)"
    echo "$ssh_agent_vars"
    eval "$ssh_agent_vars"
fi

ssh-add -l >/dev/null 2>&1 || r=$?
if [[ "$r" == 1 ]]; then
    echo "No keys have been added to ssh-agent, running ssh-add..."
    ssh-add
fi

cd "$base_dir/ansible"

ansible-playbook --inventory ./inventory.sh --diff ./gateway.yml
