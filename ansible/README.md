# Step 4: Ansible Server Configuration

This folder configures the EC2 host created by Terraform.

## What this playbook does

- Installs Docker
- Installs Git
- Starts and enables Docker service
- Adds `ec2-user` to docker group
- Clones your app repository to `/opt/gitops-lite`

## Files

- `ansible.cfg`: basic Ansible defaults
- `inventory.ini.example`: sample inventory format
- `generate_inventory.sh`: creates `inventory.ini` from Terraform output
- `playbook.yml`: server configuration playbook

## Prerequisites

1. Terraform Step 3 is already applied
2. SSH key file available on your machine (`.pem`)
3. Ansible installed (`ansible --version`)

## Create inventory from Terraform output

From project root:

```bash
chmod +x ansible/generate_inventory.sh
./ansible/generate_inventory.sh ~/.ssh/your-key.pem
```

This writes `ansible/inventory.ini` automatically.

## Test SSH connectivity

```bash
cd ansible
ansible all -m ping
```

Expected output includes `pong` and `FAILED=0`.

## Run playbook

```bash
ansible-playbook playbook.yml \
	-e app_repo_url=https://github.com/<your-username>/<your-repo>.git \
	-e app_branch=main
```

Expected output should end with a recap similar to:

- `failed=0`
- `unreachable=0`

