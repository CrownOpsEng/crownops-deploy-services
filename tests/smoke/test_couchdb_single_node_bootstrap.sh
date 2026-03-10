#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TASK_FILE="${ROOT_DIR}/roles/obsidian_livesync/tasks/couchdb.yml"
COMPOSE_TEMPLATE="${ROOT_DIR}/roles/obsidian_livesync/templates/couchdb-docker-compose.yml.j2"
LOCAL_INI_TEMPLATE="${ROOT_DIR}/roles/obsidian_livesync/templates/local.ini.j2"
HANDLER_FILE="${ROOT_DIR}/roles/obsidian_livesync/handlers/main.yml"

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

if ! rg -n '^\[chttpd\]$' "${LOCAL_INI_TEMPLATE}" >/dev/null; then
  echo "expected local.ini template to define a [chttpd] section" >&2
  exit 1
fi

if ! rg -n '^[[:space:]]*enable_cors = true$' "${LOCAL_INI_TEMPLATE}" >/dev/null; then
  echo "expected local.ini template to enable CORS explicitly" >&2
  exit 1
fi

CHTTPD_LINE="$(rg -n '^\[chttpd\]$' "${LOCAL_INI_TEMPLATE}" | cut -d: -f1)"
CORS_LINE="$(rg -n '^\[cors\]$' "${LOCAL_INI_TEMPLATE}" | cut -d: -f1)"
ENABLE_CORS_LINE="$(rg -n '^[[:space:]]*enable_cors = true$' "${LOCAL_INI_TEMPLATE}" | cut -d: -f1)"
HEADERS_LINE="$(rg -n '^[[:space:]]*headers = ' "${LOCAL_INI_TEMPLATE}" | cut -d: -f1)"
METHODS_LINE="$(rg -n '^[[:space:]]*methods = ' "${LOCAL_INI_TEMPLATE}" | cut -d: -f1)"
MAX_AGE_LINE="$(rg -n '^[[:space:]]*max_age = ' "${LOCAL_INI_TEMPLATE}" | cut -d: -f1)"

if [[ -z "${CHTTPD_LINE}" || -z "${CORS_LINE}" || -z "${ENABLE_CORS_LINE}" || -z "${HEADERS_LINE}" || -z "${METHODS_LINE}" || -z "${MAX_AGE_LINE}" ]]; then
  echo "expected local.ini template to define CORS enablement, headers, methods, and max_age" >&2
  exit 1
fi

if [[ "${ENABLE_CORS_LINE}" -le "${CHTTPD_LINE}" || "${ENABLE_CORS_LINE}" -ge "${CORS_LINE}" ]]; then
  echo "enable_cors must be defined inside [chttpd], not inside [cors]" >&2
  exit 1
fi

if [[ "${HEADERS_LINE}" -le "${CORS_LINE}" || "${METHODS_LINE}" -le "${CORS_LINE}" || "${MAX_AGE_LINE}" -le "${CORS_LINE}" ]]; then
  echo "cors headers, methods, and max_age must be defined inside the [cors] section" >&2
  exit 1
fi

if ! rg -n 'notify: Restart CouchDB stack' "${TASK_FILE}" >/dev/null; then
  echo "expected local.ini changes to notify a CouchDB restart" >&2
  exit 1
fi

if ! rg -n 'flush_handlers' "${TASK_FILE}" >/dev/null; then
  echo "expected CouchDB tasks to flush restart handlers before API validation" >&2
  exit 1
fi

if ! rg -n '^- name: Restart CouchDB stack$' "${HANDLER_FILE}" >/dev/null; then
  echo "expected obsidian_livesync role to define a CouchDB restart handler" >&2
  exit 1
fi

if ! rg -n 'state: restarted' "${HANDLER_FILE}" >/dev/null; then
  echo "expected CouchDB restart handler to use docker compose restart semantics" >&2
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

for db in _users _replicator; do
  if ! rg -n "^[[:space:]]+- ${db}$" "${TASK_FILE}" >/dev/null; then
    echo "expected ${db} to be included in the system database readiness loop" >&2
    exit 1
  fi
done

printf 'couchdb single-node bootstrap smoke test passed\n'
