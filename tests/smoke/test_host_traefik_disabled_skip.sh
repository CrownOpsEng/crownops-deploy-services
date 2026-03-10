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
  tasks:
    - ansible.builtin.include_role:
        name: ${ROOT_DIR}/roles/host_traefik
      vars:
        host_traefik:
          enabled: false
          manage_mode: adopt_managed
          layout_root: /tmp/traefik
          static_config_path: /tmp/traefik/traefik.yml
          dynamic_config_root: /tmp/traefik/dynamic
          dynamic_routes_dir: /tmp/traefik/dynamic/routes
          acme_storage_path: /tmp/traefik/acme/acme.json
          proxy_network_name: proxy
          container_name: traefik
          compose_project_name: traefik
          certificate_resolver_name: dnsresolver
          acme_email: ops@example.com
          dns_provider: cloudflare
          dns_env:
            CF_DNS_API_TOKEN: test-token
          routes: []
EOF

ansible-playbook -i 'localhost,' "${TMP_DIR}/play.yml" >/dev/null

printf 'host_traefik disabled skip smoke test passed\n'
