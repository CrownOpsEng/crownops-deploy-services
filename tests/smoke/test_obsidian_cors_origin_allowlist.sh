#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TASK_FILE="${ROOT_DIR}/roles/obsidian_livesync/tasks/main.yml"

for origin in "app://obsidian.md" "capacitor://localhost" "http://localhost"; do
  if ! rg -n -F "${origin}" "${TASK_FILE}" >/dev/null; then
    echo "expected derived Obsidian CORS origins to include ${origin}" >&2
    exit 1
  fi
done

printf 'obsidian cors origin allowlist smoke test passed\n'
