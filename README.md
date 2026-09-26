# local-dev

Docker Compose and Make targets for running the doordash stack on your machine.

## Prerequisites

- [Git](https://git-scm.com/)
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

`api-engine` and `data-acquisition` import versioned Go modules (`go-data-model`, `platform-contracts` at semver tags like **v0.1.0**). For local compiles against sibling checkouts, use the **`go.work`** file in this repo (see [Go module versions](#go-module-versions)).

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

### 3. Build and run

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

**Local compile** — use the workspace file in this repo:

```bash
export GOWORK="$(pwd)/go.work"          # bash, from this directory
$env:GOWORK = "$PWD\go.work"            # PowerShell
```

**Docker Compose** builds generate a `go.work` inside the image from sibling folders.

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
