#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

cat > "${TMP_DIR}/render.yml" <<EOF
---
- name: Render restic backup runner template
  hosts: localhost
  connection: local
  gather_facts: false
  tasks:
    - name: Render runner
      ansible.builtin.template:
        src: ${ROOT_DIR}/roles/host_restic/templates/restic-backup.sh.j2
        dest: ${TMP_DIR}/restic-backup.sh
      vars:
        restic_targets_dir: /opt/crownops-backup/targets
        restic_jobs_dir: /opt/crownops-backup/jobs
EOF

ansible-playbook -i 'localhost,' "${TMP_DIR}/render.yml" >/dev/null

if grep -F '${#' "${TMP_DIR}/restic-backup.sh" >/dev/null; then
  echo "rendered restic backup runner should not contain bash \${#...} constructs that collide with Jinja parsing" >&2
  exit 1
fi

if ! grep -F 'POST_BACKUP_COMMANDS[*]:-' "${TMP_DIR}/restic-backup.sh" >/dev/null; then
  echo "rendered restic backup runner is missing the post-backup command guard" >&2
  exit 1
fi

printf 'restic backup runner template smoke test passed\n'
