#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MAIN_TASK_FILE="${ROOT_DIR}/roles/host_restic/tasks/main.yml"
COMPOSE_FILE="${ROOT_DIR}/roles/host_restic/tasks/compose.yml"

for expected in \
  'restic_desired_target_env_paths' \
  'restic_desired_password_paths' \
  'restic_desired_job_config_paths' \
  'restic_desired_ssh_paths'
do
  if ! rg -n "${expected}" "${COMPOSE_FILE}" "${MAIN_TASK_FILE}" >/dev/null; then
    echo "expected host_restic managed-state cleanup to track ${expected}" >&2
    exit 1
  fi
done

for expected in \
  'Remove stale managed restic target env files' \
  'Remove stale managed restic password files' \
  'Remove stale managed restic SSH material' \
  'Remove stale managed restic job config files'
do
  if ! rg -n "${expected}" "${MAIN_TASK_FILE}" >/dev/null; then
    echo "expected host_restic managed-state cleanup task: ${expected}" >&2
    exit 1
  fi
done

printf 'host_restic managed state cleanup smoke test passed\n'
