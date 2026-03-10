#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

cat > "${TMP_DIR}/play.yml" <<EOF
---
- hosts: localhost
  connection: local
  gather_facts: false
  vars:
    ops_domain: ops.example.com
  tasks:
    - ansible.builtin.include_role:
        name: ${ROOT_DIR}/roles/obsidian_livesync
      vars:
        obsidian_livesync:
          enabled: true
          access_mode: invalid
          base_url: https://notes.example.com
          handoff_dir: /tmp/crownops-handoff
          private_mesh:
            url_strategy: tailscale_magicdns
            tailnet_name: crownops.ts.net
          ingress:
            route_name: obsidian-couchdb
            shared_network_name: proxy
          couchdb:
            dir: /tmp/crownops-couchdb
            container_name: couchdb
            internal_network_name: internal
            bind_host: 127.0.0.1
            port: 5984
            admin_user: admin
            admin_password: test-password
            vaults:
              - name: demo
                db_name: vault_demo
                user: vault_demo_user
                password: test-password
EOF

set +e
OUTPUT="$(ansible-playbook -i 'localhost,' "${TMP_DIR}/play.yml" 2>&1)"
STATUS=$?
set -e

if [[ ${STATUS} -eq 0 ]]; then
  echo "expected obsidian_livesync to reject an invalid access_mode" >&2
  exit 1
fi

if [[ "${OUTPUT}" != *"value of access_mode must be one of: public_https, private_mesh"* ]]; then
  echo "expected obsidian_livesync failure output to mention access_mode validation" >&2
  printf '%s\n' "${OUTPUT}" >&2
  exit 1
fi

if [[ "${OUTPUT}" == *"No variable found with this name"* ]]; then
  echo "obsidian_livesync legacy variable guard should not crash on clean input" >&2
  printf '%s\n' "${OUTPUT}" >&2
  exit 1
fi

printf 'obsidian contract validation smoke test passed\n'
