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

cd "$base_dir/ansible"

ansible-playbook --inventory ./inventory.sh --diff --verbose ./hetz-de.yml
