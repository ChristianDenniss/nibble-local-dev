#!/usr/bin/env bash
set -euo pipefail

LOCAL_DEV_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${LOCAL_DEV_ROOT}/.." && pwd)"

repos=(
  go-data-model
  go-data-store
  platform-contracts
  api-engine
  data-acquisition
  web-platform
  local-dev
)

github_owner="${GITHUB_OWNER:-}"
if [[ -z "${github_owner}" ]]; then
  origin="$(git -C "${LOCAL_DEV_ROOT}" remote get-url origin 2>/dev/null || true)"
  if [[ "${origin}" =~ github.com[:/]([^/]+)/ ]]; then
    github_owner="${BASH_REMATCH[1]}"
  else
    github_owner="ChristianDenniss"
  fi
fi

echo "Using GitHub owner: ${github_owner}"
echo "Workspace root: ${WORKSPACE_ROOT}"

for name in "${repos[@]}"; do
  path="${WORKSPACE_ROOT}/${name}"
  url="https://github.com/${github_owner}/${name}.git"

  if [[ -d "${path}/.git" ]]; then
    echo "pulling ${name}"
    git -C "${path}" pull --ff-only origin main
    continue
  fi

  if [[ -e "${path}" ]]; then
    echo "${path} exists but is not a git repo. Remove it or clone manually." >&2
    exit 1
  fi

  echo "cloning ${name}"
  git clone "${url}" "${path}"
done

echo "All repos are present at latest main."
echo "Next: make build && make start"
