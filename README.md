# nibble-local-dev

Current catalog setup and repository ownership: [CATALOG.md](CATALOG.md).
Compose builds now use sibling checkouts; no GitHub build token is needed.


Orchestrates the sibling Nibble repos as one local stack: clone them, build images, start Postgres and the services, and stream logs.

**Why this repo exists:** nobody should have to remember five Dockerfiles and a database URL. Local development is a product of its own. This repo is that product — not a service, and not the domain.

Docker Compose and Make targets for running the stack on your machine.

## Prerequisites

- [Git](https://git-scm.com/)
- [GitHub CLI](https://cli.github.com/) (`gh auth login` — used to clone private repositories)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine + Compose)
- [Make](https://www.gnu.org/software/make/) (optional but recommended)

Go and Node are not required on the host; services build inside Docker.

## Repo layout

All services live as **sibling folders** under one workspace directory:

```text
nibble/
  nibble-go-data-model/
  nibble-go-data-store/
  nibble-platform-contracts/
  nibble-api-engine/
  nibble-data-acquisition/
  nibble-web-platform/
  nibble-local-dev/   ← you are here
```

`nibble-api-engine` depends on `nibble-go-data-model`, `nibble-go-data-store`, and `nibble-platform-contracts`. Compose builds these from sibling checkouts through a Go workspace; `go.work` provides the same resolution for local tests.

## Onboarding (new developers)

### 1. Get this repo

Clone only `nibble-local-dev` first:

```bash
git clone https://github.com/ChristianDenniss/nibble-local-dev.git
cd nibble-local-dev
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

If `nibble-local-dev`’s `origin` is on GitHub, the script can infer the owner from that remote.

### 3. Authenticate with GitHub

Cloning private repositories uses your GitHub session:

```bash
gh auth login
```

### 4. Build and run

`make build` builds the sibling checkouts through Go workspaces.
A first `make start` builds the images if they are missing.

```bash
make build       # pull images and build containers (plain progress in the terminal)
make start       # start the stack in the foreground with live logs
make status      # check containers
```

**Windows (no Make):**

```powershell
docker compose --progress=plain build
.\start.ps1
# or rebuild + attach in one go:
.\start.ps1 -Build
```

`make start` / `.\start.ps1` stay attached so you see postgres init (first run creates `nibble`), api-engine migrations, and every service log. Ctrl+C stops the stack.

Open [http://localhost:5173](http://localhost:5173). Open `/browse` to explore the imported restaurant catalog.

### Compare vertical slice (demo)

The default worker now collects Uber Eats and DoorDash. The older compare demo can still be seeded manually using `scripts/seed_compare_demo.sql`; it is separate from the provider browse read model.

1. **Web UI:** [http://localhost:5173/compare](http://localhost:5173/compare) — run compare for `pl_demo` / `dish_burger`.
2. **Smoke script:** `.\scripts\smoke_compare.ps1` or `bash scripts/smoke_compare.sh` (hits `POST /v1/compare`).
3. **Manual SQL seed** (optional): `psql postgres://nibble:nibble@localhost:5432/nibble?sslmode=disable -f scripts/seed_compare_demo.sql`

Module pins after releases: [`docs/architecture/module-pins.md`](docs/architecture/module-pins.md).

Other useful targets:

| Target           | Description                                      |
| ---------------- | ------------------------------------------------ |
| `make start-detach` | Start in the background (detached compose)     |
| `make restart`   | Stop the stack, then start it again in the foreground |
| `make down`      | Stop and remove containers                       |
| `make logs`      | Follow combined logs with timestamps             |

## Versioning

Each repository uses **semantic-release** (same model as
[troj-model-dashboard](https://github.com/TrojAISec/troj-model-dashboard)): squash-merge
PRs with `feat:` / `fix:` titles, get `vX.Y.Z` **GitHub Releases** on `main`. See
[`docs/architecture/versioning.md`](docs/architecture/versioning.md).

## Go modules (compile-time deps)

`nibble-go-data-model`, `nibble-go-data-store`, and `nibble-platform-contracts` are versioned Go modules; their git release
tags (`v1.1.0`, …) are what `go get` uses. Services pin those versions in `go.mod` (no
committed `replace`). Host-side Go commands against private modules need:

```bash
export GOPRIVATE=github.com/ChristianDenniss/*
export GONOSUMDB=github.com/ChristianDenniss/*
```

In Docker, leave `VITE_API_URL` unset. Compose uses `API_ENGINE_URL` so the Vite
dev server proxies `/health` to `api-engine`. `nibble-web-platform` waits until
`api-engine` reports healthy on `:8080`.

**Local Compose** builds sibling source through Go workspaces. Standalone CI/release
builds require publishing the coordinated library changes and bumping module pins.

**Host multi-repo edit** — `go.work` overrides module paths to sibling folders
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

| Folder                    | GitHub |
| ------------------------- | ------ |
| nibble-go-data-model      | https://github.com/ChristianDenniss/nibble-go-data-model |
| nibble-go-data-store      | https://github.com/ChristianDenniss/nibble-go-data-store |
| nibble-platform-contracts | https://github.com/ChristianDenniss/nibble-platform-contracts |
| nibble-api-engine         | https://github.com/ChristianDenniss/nibble-api-engine |
| nibble-data-acquisition   | https://github.com/ChristianDenniss/nibble-data-acquisition |
| nibble-web-platform       | https://github.com/ChristianDenniss/nibble-web-platform |
| nibble-local-dev          | https://github.com/ChristianDenniss/nibble-local-dev |
