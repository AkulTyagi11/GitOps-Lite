#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"
INVENTORY_FILE="${ROOT_DIR}/ansible/inventory.ini"
KEY_PATH="${1:-$HOME/.ssh/your-key.pem}"

if [[ ! -d "${TF_DIR}" ]]; then
  echo "Terraform directory not found at ${TF_DIR}" >&2
  exit 1
fi

if [[ ! -f "${TF_DIR}/terraform.tfstate" ]]; then
  echo "terraform.tfstate not found. Run terraform apply first." >&2
  exit 1
fi

EC2_PUBLIC_IP="$(cd "${TF_DIR}" && terraform output -raw ec2_public_ip)"

cat > "${INVENTORY_FILE}" <<EOF
[app]
app_server ansible_host=${EC2_PUBLIC_IP} ansible_user=ec2-user ansible_ssh_private_key_file=${KEY_PATH}
EOF

echo "Generated ${INVENTORY_FILE} with host ${EC2_PUBLIC_IP}"
