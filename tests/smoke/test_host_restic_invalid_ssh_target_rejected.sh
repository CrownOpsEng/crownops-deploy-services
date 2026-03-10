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
        name: ${ROOT_DIR}/roles/host_restic
      vars:
        host_restic:
          enabled: true
          install_package: false
          backup_root: /tmp/crownops-restic
          targets_dir: /tmp/crownops-restic/targets
          jobs_dir: /tmp/crownops-restic/jobs
          passwords_dir: /tmp/crownops-restic/passwords
          backup_script_path: /tmp/crownops-restic/backup.sh
          maintain_script_path: /tmp/crownops-restic/maintain.sh
          ssh_dir: /tmp/crownops-restic/ssh
          targets:
            - name: primary
              repository: sftp:backup@example.com:/srv/restic/core
              password: test-password
              ssh_private_key: test-private-key
              ssh_known_hosts: ""
          datasets:
            - name: host-foundation
              owner: core
              paths:
                - /etc/ssh
          jobs:
            - name: host-foundation
              dataset_names:
                - host-foundation
              target_names:
                - primary
EOF

set +e
OUTPUT="$(ansible-playbook -i 'localhost,' "${TMP_DIR}/play.yml" 2>&1)"
STATUS=$?
set -e

if [[ ${STATUS} -eq 0 ]]; then
  echo "expected host_restic to reject ssh_private_key targets without ssh_known_hosts" >&2
  exit 1
fi

if [[ "${OUTPUT}" != *"uses ssh_private_key without ssh_known_hosts"* ]]; then
  echo "expected host_restic failure output to mention missing ssh_known_hosts" >&2
  printf '%s\n' "${OUTPUT}" >&2
  exit 1
fi

printf 'host_restic invalid ssh target rejection smoke test passed\n'
