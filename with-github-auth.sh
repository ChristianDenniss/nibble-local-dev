#!/usr/bin/env bash
set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required. Install from https://cli.github.com/ then: gh auth login" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Not logged in. Run: gh auth login" >&2
  exit 1
fi

token="$(gh auth token)"
if [[ -z "${token}" ]]; then
  echo "Could not read a token from gh. Run: gh auth login" >&2
  exit 1
fi

export GITHUB_TOKEN="${token}"
echo "Using GitHub token from gh auth for docker compose (private go mod download)."

if [[ "$#" -lt 1 ]]; then
  echo "Usage: ./with-github-auth.sh docker compose ..." >&2
  exit 1
fi

exec "$@"
