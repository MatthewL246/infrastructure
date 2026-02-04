# Personal cloud server infrastructure

This repository contains my personal infrastructure as code configuration. It uses Terraform (I use [OpenTofu](https://opentofu.org)) to deploy and manage cloud resources and [Ansible](https://docs.ansible.com/projects/ansible/latest/index.html) to configure the servers.

## About this project

As of right now, I would consider this an individual project. It is probably only useful to me, but I keep it public because some parts of it might end up being useful/educational to someone else and because I have a general preference for transparency when possible.

Contributions will be considered on a case-by-case basis: if you want to fix a bug, correct a typo, or suggest a best practice, you are completely welcome to! However, feature requests that I don't think are relevant to my usage will probably not be accepted.

## Usage

1. Fill in the required Terraform variables (see [`variables.tf`](./terraform/variables.tf)) in `terraform.tfvars`.
2. Use standard Terraform/OpenTofu commands to deploy the infrastructure.
3. Configure the servers using Ansible with the `run-ansible.sh` script.

Note: to run standard Ansible commands, make sure to use the inventory-generation script with `--inventory inventory.sh`.
