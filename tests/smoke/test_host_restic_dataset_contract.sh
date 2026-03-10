#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MAIN_TASK_FILE="${ROOT_DIR}/roles/host_restic/tasks/main.yml"
COMPOSE_FILE="${ROOT_DIR}/roles/host_restic/tasks/compose.yml"
COMPOSE_JOB_FILE="${ROOT_DIR}/roles/host_restic/tasks/compose_job.yml"
VALIDATE_FILE="${ROOT_DIR}/roles/host_restic/tasks/validate.yml"

if rg -n 'restic_backup_contributions' "${COMPOSE_FILE}" "${COMPOSE_JOB_FILE}" "${VALIDATE_FILE}" "${ROOT_DIR}/roles/host_restic/README.md" >/dev/null; then
  echo "host_restic should not reference the legacy restic_backup_contributions model outside the legacy rejection guard" >&2
  exit 1
fi

for expected in 'host_restic\.datasets' 'host_restic\.jobs' 'host_restic\.feature_owned_jobs'; do
  if ! rg -n "${expected}" "${MAIN_TASK_FILE}" "${COMPOSE_FILE}" "${VALIDATE_FILE}" >/dev/null; then
    echo "expected ${expected} to be part of the host_restic contract" >&2
    exit 1
  fi
done

for expected in 'dataset_names' 'selector_tags'; do
  if ! rg -n "${expected}" "${COMPOSE_JOB_FILE}" "${VALIDATE_FILE}" >/dev/null; then
    echo "expected ${expected} in the host_restic dataset selection flow" >&2
    exit 1
  fi
done

if ! rg -n 'feature_owned_jobs is intentionally unsupported' "${VALIDATE_FILE}" >/dev/null; then
  echo "expected host_restic to reject unsupported feature-owned jobs" >&2
  exit 1
fi

printf 'host_restic dataset contract smoke test passed\n'
