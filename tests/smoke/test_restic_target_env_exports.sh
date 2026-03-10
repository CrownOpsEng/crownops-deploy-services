#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

cat > "${TMP_DIR}/render.yml" <<EOF
---
- name: Render restic target env template
  hosts: localhost
  connection: local
  gather_facts: false
  tasks:
    - name: Render target env
      ansible.builtin.template:
        src: ${ROOT_DIR}/roles/restic_host_backups/templates/restic-target.env.j2
        dest: ${TMP_DIR}/h4f.env
      vars:
        restic_ssh_dir: /opt/crownops-backup/ssh
        restic_target_password_file_path: /opt/crownops-backup/passwords/h4f.password
        restic_target:
          name: h4f
          repository: sftp:backup@example.com:/srv/restic/core
          sftp_port: 2222
          auto_init: true
          sftp_command: ""
          ssh_private_key: "test-key"
          ssh_known_hosts: "example.com ssh-ed25519 AAAATEST"
          environment:
            RESTIC_CACHE_DIR: /var/cache/restic
EOF

ansible-playbook -i 'localhost,' "${TMP_DIR}/render.yml" >/dev/null

for expected in \
  "export RESTIC_REPOSITORY=" \
  "export RESTIC_PASSWORD_FILE=" \
  "export RESTIC_AUTO_INIT=" \
  "export RESTIC_SFTP_COMMAND=" \
  "export RESTIC_CACHE_DIR="; do
  if ! grep -F "${expected}" "${TMP_DIR}/h4f.env" >/dev/null; then
    echo "expected ${expected} in rendered restic target env" >&2
    exit 1
  fi
done

if ! grep -F 'backup@example.com' "${TMP_DIR}/h4f.env" >/dev/null; then
  echo "rendered restic target env should include the sftp destination in RESTIC_SFTP_COMMAND" >&2
  exit 1
fi

if ! grep -F 'backup@example.com -s sftp' "${TMP_DIR}/h4f.env" >/dev/null; then
  echo "rendered restic target env should place the destination before the requested sftp subsystem" >&2
  exit 1
fi

if ! grep -F ' -p 2222 ' "${TMP_DIR}/h4f.env" >/dev/null; then
  echo "rendered restic target env should include the configured non-default SFTP port" >&2
  exit 1
fi

printf 'restic target env export smoke test passed\n'
