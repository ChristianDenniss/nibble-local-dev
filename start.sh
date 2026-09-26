#!/usr/bin/env bash
set -euo pipefail

build=0
if [[ "${1:-}" == "--build" ]]; then
  build=1
fi

echo
echo "=== web-platform local-dev ==="
echo "Starting postgres, api-engine, data-acquisition, web-platform in the foreground."
echo "You will see image/container progress, database init, migrations, and service logs."
echo "Ctrl+C stops the stack."
echo

export BUILDKIT_PROGRESS=plain

if [[ "${build}" -eq 1 ]]; then
  echo "Building images (GitHub token from gh auth), then attaching logs..."
  exec "$(dirname "$0")/with-github-auth.sh" docker compose --progress=plain up --build --remove-orphans --timestamps
fi

echo "Attaching to compose (use ./start.sh --build to rebuild images first)..."
exec docker compose --progress=plain up --remove-orphans --timestamps
