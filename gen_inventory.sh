#!/usr/bin/env bash
set -euo pipefail

OUT_JSON=$(terraform output -json public_ips)
EAST_IP=$(echo "$OUT_JSON" | jq -r '.east')
WEST_IP=$(echo "$OUT_JSON" | jq -r '.west')

ANSIBLE_DIR="ansible-sdwan"   # <-- write to sibling folder
mkdir -p "$ANSIBLE_DIR/inventory"

cat > "$ANSIBLE_DIR/inventory/hosts.yml" <<EOF
all:
  children:
    sdwan_edges:
      hosts:
        site-east:
          ansible_host: ${EAST_IP}
          ansible_user: azureuser
        site-west:
          ansible_host: ${WEST_IP}
          ansible_user: azureuser
EOF

echo "Inventory written to $ANSIBLE_DIR/inventory/hosts.yml"
echo "east=${EAST_IP}  west=${WEST_IP}"
