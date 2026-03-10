#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TASK_FILE="${ROOT_DIR}/roles/obsidian_livesync/tasks/couchdb.yml"
COMPOSE_TEMPLATE="${ROOT_DIR}/roles/obsidian_livesync/templates/couchdb-docker-compose.yml.j2"

if ! rg -n 'owner: "5984"' "${TASK_FILE}" >/dev/null; then
  echo "expected local.ini to be rendered with the CouchDB container uid" >&2
  exit 1
fi

if ! rg -n 'group: "5984"' "${TASK_FILE}" >/dev/null; then
  echo "expected local.ini to be rendered with the CouchDB container gid" >&2
  exit 1
fi

if rg -n '/opt/couchdb/etc/local\\.d/local\\.ini:ro' "${COMPOSE_TEMPLATE}" >/dev/null; then
  echo "local.ini bind mount must not be read-only for the official CouchDB image entrypoint" >&2
  exit 1
fi

if rg -n 'bootstrap-couchdb\\.sh' "${TASK_FILE}" >/dev/null; then
  echo "unexpected legacy bootstrap helper reference remains in CouchDB tasks" >&2
  exit 1
fi

SETUP_READ_LINE="$(rg -n '^- name: Read CouchDB cluster setup state$' "${TASK_FILE}" | cut -d: -f1)"
SETUP_ENABLE_LINE="$(rg -n '^- name: Enable CouchDB single-node setup$' "${TASK_FILE}" | cut -d: -f1)"
SETUP_WAIT_LINE="$(rg -n '^- name: Wait for CouchDB single-node setup to finish$' "${TASK_FILE}" | cut -d: -f1)"
SYSTEM_LINE="$(rg -n '^- name: Wait for CouchDB system databases$' "${TASK_FILE}" | cut -d: -f1)"
USER_LINE="$(rg -n '^- name: Read existing CouchDB user documents$' "${TASK_FILE}" | cut -d: -f1)"
if [[ -z "${SETUP_READ_LINE}" || -z "${SETUP_ENABLE_LINE}" || -z "${SETUP_WAIT_LINE}" ]]; then
  echo "expected documented CouchDB single-node setup tasks to exist" >&2
  exit 1
fi

if [[ "${SETUP_READ_LINE}" -ge "${SETUP_ENABLE_LINE}" || "${SETUP_ENABLE_LINE}" -ge "${SETUP_WAIT_LINE}" ]]; then
  echo "cluster setup tasks must run in read -> enable -> wait order" >&2
  exit 1
fi

if [[ -z "${SYSTEM_LINE}" || -z "${USER_LINE}" || "${SETUP_WAIT_LINE}" -ge "${SYSTEM_LINE}" || "${SYSTEM_LINE}" -ge "${USER_LINE}" ]]; then
  echo "cluster setup and system database readiness must complete before user document provisioning" >&2
  exit 1
fi

for db in _users _replicator _global_changes; do
  if ! rg -n "^[[:space:]]+- ${db}$" "${TASK_FILE}" >/dev/null; then
    echo "expected ${db} to be included in the system database readiness loop" >&2
    exit 1
  fi
done

printf 'couchdb single-node bootstrap smoke test passed\n'
