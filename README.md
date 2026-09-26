# nibble-local-dev

Orchestrates the sibling Nibble repos as one local stack: clone them, build images, start Postgres and the services, and stream logs.

**Why this repo exists:** nobody should have to remember five Dockerfiles and a database URL. Local development is a product of its own. This repo is that product — not a service, and not the domain.

Docker Compose and Make targets for running the stack on your machine.

## Prerequisites

- [Git](https://git-scm.com/)
- [GitHub CLI](https://cli.github.com/) (`gh auth login` — used for private Go module download during `make build`)
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

`nibble-api-engine` depends on **`nibble-go-data-model`**, **`nibble-go-data-store`**, and **`nibble-platform-contracts`** as **versioned Go modules from GitHub**. Optional **`go.work`** here is only for editing multiple repos at once on your machine (see [Go modules](#go-modules-compile-time-deps)).

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

Private module downloads use **your** GitHub session (nothing stored in this repo):

```bash
gh auth login
```

### 4. Build and run

`make build` passes a token from `gh auth token` into Docker for `go mod download`.
A first `make start` does the same if the stack images are not on the machine yet.

```bash
make pull        # optional: refresh base images (postgres, node, …)
make build       # build service images (uses BuildKit; does not re-pull every time)
make start       # start the stack in the foreground with live logs
make status      # check containers
```

**Windows (no Make):**

```powershell
.\with-github-auth.ps1 --progress=plain build
.\start.ps1
# or rebuild + attach in one go:
.\start.ps1 -Build
```

`make start` / `.\start.ps1` stay attached so you see postgres init (first run creates `nibble`), api-engine migrations, and every service log. Ctrl+C stops the stack. To tear down containers for **this** repo, use `make stop` or `make down` (same thing).

Default **host** ports are chosen to avoid common conflicts (local Postgres on 5432, other stacks on 8080/9090/5173):

| Service | Host port |
| ------- | --------- |
| Postgres | 5433 |
| api-engine HTTP / gRPC | 8081 / 9091 |
| web-platform | 5174 |

Change the left side of each `ports` entry in `docker-compose.yml` if a port is still taken. An old **`doordash-*`** compose stack may still be running — stop it with `docker stop doordash-api-engine-1 doordash-web-platform-1` or remove those containers if you no longer need them.

Open [http://localhost:5174](http://localhost:5174). The page should show **200 success** after it calls `api-engine` `/health`.

### Compare vertical slice (demo)

With the stack running, `data-acquisition` uses `ACQUISITION_ADAPTER=curated` (compose default) to load **Fredericton markets + compare catalog** via **ingest v2** (equivalent to `scripts/seed/*.sql` + `seed_compare_demo.sql`). Use `demo` for catalog-only without markets.

**Persistent market seed (Fredericton / UNBF):** after migrations, either run the `curated` adapter or apply SQL:

```powershell
psql postgres://nibble:nibble@localhost:5433/nibble?sslmode=disable -f scripts/seed/global.sql
psql postgres://nibble:nibble@localhost:5433/nibble?sslmode=disable -f scripts/seed/fredericton.sql
```

Or set `ACQUISITION_ADAPTER=curated` on `data-acquisition` (after sibling modules include market ingest).

1. **Web UI:** [http://localhost:5174/compare](http://localhost:5174/compare) — run compare for `pl_demo` / `dish_burger`.
2. **Smoke script:** `.\scripts\smoke_compare.ps1` or `bash scripts/smoke_compare.sh` (hits `POST /v1/compare`).
3. **Manual SQL seed** (optional): `psql postgres://nibble:nibble@localhost:5433/nibble?sslmode=disable -f scripts/seed_compare_demo.sql`
4. **Storefront browse** (optional, for `VITE_MOCK=0`): `psql ... -f scripts/seed_storefront_demo.sql` then open [http://localhost:5174](http://localhost:5174) — loads `GET /storefront` for account `acct_dev`.
5. **Source catalog E2E** (Phase 1): `.\scripts\smoke_catalog_e2e.ps1` (lists `ch_store` stores, then menu). Web: [http://localhost:5174/source-menu](http://localhost:5174/source-menu).

Module pins after releases: [`docs/architecture/module-pins.md`](docs/architecture/module-pins.md).

Other useful targets:

| Target           | Description                                      |
| ---------------- | ------------------------------------------------ |
| `make pull`      | Refresh upstream base images (postgres, node, …) |
| `make start-detach` | Start in the background (detached compose)     |
| `make restart`   | Stop the stack, then start it again in the foreground |
| `make down` / `make stop` | Stop and remove **this** stack (`nibble-local-dev` compose only) |
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
`api-engine` reports healthy on container `:8080` (host **8081** when calling from your machine).

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
| web-platform (host) | 5174 → 5173 in container |
| api-engine HTTP (host) | 8081 → 8080 in container |
| api-engine gRPC (host) | 9091 → 9090 in container |
| postgres (host) | 5433 → 5432 in container |

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
