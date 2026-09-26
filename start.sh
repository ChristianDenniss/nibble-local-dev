#!/usr/bin/env bash
set -euo pipefail

build=0
if [[ "${1:-}" == "--build" ]]; then
  build=1
fi

echo
echo "=== local-dev stack ==="
echo "Starting postgres, api-engine, data-acquisition, and the Nibble web platform in the foreground."
echo "You will see image/container progress, database init, migrations, and service logs."
echo "Ctrl+C stops the stack."
echo

export BUILDKIT_PROGRESS=plain

stack_images_present() {
  local name
  for name in nibble-api-engine nibble-data-acquisition nibble-web-platform; do
    docker image inspect "$name" >/dev/null 2>&1 || return 1
  done
  return 0
}

if [[ "${build}" -eq 0 ]] && ! stack_images_present; then
  echo "Stack images are missing. Building with GitHub token from gh auth..."
  build=1
fi

if [[ "${build}" -eq 1 ]]; then
  echo "Building images (GitHub token from gh auth), then attaching logs..."
  exec "$(dirname "$0")/with-github-auth.sh" docker compose --progress=plain up --build --remove-orphans --timestamps
fi

echo "Attaching to compose (use ./start.sh --build to rebuild images first)..."
if command -v gh >/dev/null 2>&1; then
  token="$(gh auth token 2>/dev/null || true)"
  if [[ -n "${token}" ]]; then
    export GITHUB_TOKEN="${token}"
  fi
fi
exec docker compose --progress=plain up --remove-orphans --timestamps
