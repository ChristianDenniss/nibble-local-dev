# local-dev

Docker Compose and Make targets for running the doordash stack on your machine.

## Prerequisites

- [Git](https://git-scm.com/)
- [GitHub CLI](https://cli.github.com/) (`gh auth login` — used for private Go module download during `make build`)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine + Compose)
- [Make](https://www.gnu.org/software/make/) (optional but recommended)

Go and Node are not required on the host; services build inside Docker.

## Repo layout

All services live as **sibling folders** under one workspace directory:

```text
doordash/
  go-data-model/
  platform-contracts/
  api-engine/
  data-acquisition/
  web-platform/
  local-dev/   ← you are here
```

`api-engine` and `data-acquisition` depend on **`go-data-model`** and **`platform-contracts`** as **versioned Go modules from GitHub** (release tags like `v1.0.0` in each service’s `go.mod`). Optional **`go.work`** here is only for editing multiple repos at once on your machine (see [Go modules](#go-modules-compile-time-deps)).

## Onboarding (new developers)

### 1. Get this repo

Clone only `local-dev` first:

```bash
git clone https://github.com/ChristianDenniss/local-dev.git
cd local-dev
```

On Windows (PowerShell), same URL works; use whichever shell you prefer for the steps below.

### 2. Clone or update all repos

This downloads the latest `main` for every service repo into the parent folder.

**Make (Windows or Unix):**

```bash
make clone
```

**Windows (PowerShell):**

```powershell
.\clone.ps1
```

**macOS / Linux:**

```bash
chmod +x clone.sh
./clone.sh
```

Behavior:

- Missing repos → `git clone`
- Existing repos → `git pull --ff-only origin main`

GitHub org/user defaults to `ChristianDenniss`. Override for forks:

```bash
export GITHUB_OWNER=your-github-username   # bash
$env:GITHUB_OWNER = "your-github-username" # PowerShell
```

If `local-dev`’s `origin` is on GitHub, the script can infer the owner from that remote.

### 3. Authenticate with GitHub

Private module downloads use **your** GitHub session (nothing stored in this repo):

```bash
gh auth login
```

### 4. Build and run

`make build` passes a token from `gh auth token` into Docker for `go mod download`.

```bash
make build       # pull images and build containers
make up          # start postgres, api-engine, data-acquisition, web-platform
make status      # check containers
```

Open [http://localhost:5173](http://localhost:5173). The page should show **200 success** after it calls `api-engine` `/health`.

Other useful targets:

| Target      | Description              |
| ----------- | ------------------------ |
| `make down` | Stop and remove containers |
| `make logs` | Follow combined logs     |

## Versioning

Each repository uses **semantic-release** (same model as
[troj-model-dashboard](https://github.com/TrojAISec/troj-model-dashboard)): squash-merge
PRs with `feat:` / `fix:` titles, get `vX.Y.Z` **GitHub Releases** on `main`. See
[`docs/architecture/versioning.md`](docs/architecture/versioning.md).

## Go modules (compile-time deps)

`go-data-model` and `platform-contracts` are versioned Go modules; their git release
tags (`v1.0.0`, …) are what `go get` uses. Services pin those versions in `go.mod` (no
committed `replace`).

**CI and Docker** — build only this service’s repo and fetch deps with `go mod download`
from GitHub at the versions in `go.mod` / `go.sum` (same as production).

**Optional local multi-repo edit** — `go.work` overrides module paths to sibling folders
while you change libraries and services together:

```bash
export GOWORK="$(pwd)/go.work"          # bash, from this directory
$env:GOWORK = "$PWD\go.work"            # PowerShell
```

Do not commit `replace` directives in service repos; bump deps with
`go get github.com/ChristianDenniss/go-data-model@vX.Y.Z` after a library release.

## Ports

| Service        | Port(s)     |
| -------------- | ----------- |
| web-platform   | 5173        |
| api-engine HTTP | 8080       |
| api-engine gRPC | 9090       |
| postgres       | 5432        |

## Repositories

| Folder               | GitHub |
| -------------------- | ------ |
| go-data-model        | https://github.com/ChristianDenniss/go-data-model |
| platform-contracts   | https://github.com/ChristianDenniss/platform-contracts |
| api-engine           | https://github.com/ChristianDenniss/api-engine |
| data-acquisition     | https://github.com/ChristianDenniss/data-acquisition |
| web-platform         | https://github.com/ChristianDenniss/web-platform |
| local-dev    | https://github.com/ChristianDenniss/local-dev |
