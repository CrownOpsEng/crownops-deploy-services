#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TASK_FILE="${ROOT_DIR}/roles/obsidian_livesync/tasks/couchdb.yml"
CONFIG_TEMPLATE="${ROOT_DIR}/roles/obsidian_livesync/templates/local.ini.j2"
COMPOSE_TEMPLATE="${ROOT_DIR}/roles/obsidian_livesync/templates/couchdb-docker-compose.yml.j2"

if ! rg -n '^\[couchdb\]$' "${CONFIG_TEMPLATE}" >/dev/null; then
  echo "expected local.ini template to define a [couchdb] section" >&2
  exit 1
fi

if ! rg -n '^single_node = true$' "${CONFIG_TEMPLATE}" >/dev/null; then
  echo "expected local.ini template to enable single_node mode" >&2
  exit 1
fi

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

SYSTEM_LINE="$(rg -n '^- name: Ensure CouchDB system databases exist$' "${TASK_FILE}" | cut -d: -f1)"
USER_LINE="$(rg -n '^- name: Read existing CouchDB user documents$' "${TASK_FILE}" | cut -d: -f1)"
if [[ -z "${SYSTEM_LINE}" || -z "${USER_LINE}" || "${SYSTEM_LINE}" -ge "${USER_LINE}" ]]; then
  echo "system database readiness check must run before user document provisioning" >&2
  exit 1
fi

for db in _users _replicator _global_changes; do
  if ! rg -n "^[[:space:]]+- ${db}$" "${TASK_FILE}" >/dev/null; then
    echo "expected ${db} to be included in the system database readiness loop" >&2
    exit 1
  fi
done

printf 'couchdb single-node bootstrap smoke test passed\n'
