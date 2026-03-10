#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MAIN_TASK_FILE="${ROOT_DIR}/roles/obsidian_livesync/tasks/main.yml"
ROLE_DIR="${ROOT_DIR}/roles/obsidian_livesync"

if [[ -e "${ROLE_DIR}/tasks/traefik.yml" ]]; then
  echo "obsidian_livesync must not own a Traefik task file" >&2
  exit 1
fi

for template in obsidian-couchdb.yml.j2 traefik-docker-compose.yml.j2 traefik.yml.j2; do
  if [[ -e "${ROLE_DIR}/templates/${template}" ]]; then
    echo "obsidian_livesync must not keep legacy Traefik template ${template}" >&2
    exit 1
  fi
done

if ! rg -n 'obsidian_livesync no longer accepts the legacy variable' "${MAIN_TASK_FILE}" >/dev/null; then
  echo "expected obsidian_livesync to fail fast on removed legacy variables" >&2
  exit 1
fi

if ! rg -n 'obsidian_livesync\.ingress\.shared_network_name' "${MAIN_TASK_FILE}" >/dev/null; then
  echo "expected obsidian_livesync to require only the shared ingress network contract in public mode" >&2
  exit 1
fi

printf 'obsidian role boundary smoke test passed\n'
