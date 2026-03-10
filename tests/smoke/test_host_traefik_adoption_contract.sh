#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TASK_FILE="${ROOT_DIR}/roles/host_traefik/tasks/main.yml"
STATIC_TEMPLATE="${ROOT_DIR}/roles/host_traefik/templates/traefik.yml.j2"
COMPOSE_TEMPLATE="${ROOT_DIR}/roles/host_traefik/templates/traefik-docker-compose.yml.j2"

for expected in 'managed' 'adopt_managed' 'adopted Traefik compose file matches managed contract'; do
  if ! rg -n "${expected}" "${TASK_FILE}" >/dev/null; then
    echo "expected host_traefik adoption validation to mention ${expected}" >&2
    exit 1
  fi
done

if ! rg -n '/dynamic/routes' "${STATIC_TEMPLATE}" >/dev/null; then
  echo "expected host_traefik to scope managed routes to /dynamic/routes" >&2
  exit 1
fi

if rg -n '/var/run/docker.sock' "${COMPOSE_TEMPLATE}" >/dev/null; then
  echo "host_traefik must not mount the Docker socket" >&2
  exit 1
fi

printf 'host_traefik adoption contract smoke test passed\n'
