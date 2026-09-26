#!/usr/bin/env bash
set -euo pipefail

echo
echo "=== web-platform local-dev ==="
echo "Stopping the stack, then starting it again in the foreground."
echo "Ctrl+C stops the stack."
echo

export BUILDKIT_PROGRESS=plain
docker compose --progress=plain down
echo "Attaching to compose..."
exec docker compose --progress=plain up --remove-orphans --timestamps
