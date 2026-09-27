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
make pull        # optional: refresh base images (postgres, node, …)
make build       # build service images (uses BuildKit; does not re-pull every time)
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

The default worker collects public provider catalogs. The curated market seed can be applied manually using the SQL below.

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
   Add `-f scripts/seed_merchandising_demo.sql` for Home banners, deals, and sponsored rails (`GET /v1/home`).
5. **Source catalog E2E** (Phase 1): `.\scripts\smoke_catalog_e2e.ps1` (lists `ch_store` stores, then menu). Web: [http://localhost:5174/source-menu](http://localhost:5174/source-menu).

Module pins after releases: [`docs/architecture/module-pins.md`](docs/architecture/module-pins.md).

### Sign-in

`api-engine` owns sessions: `POST /v1/auth/signup`, `/v1/auth/login`, `/v1/auth/logout`, `GET /v1/auth/me`, plus Google / Apple OAuth under `/v1/auth/oauth/{provider}/start|callback`. The browser gets an HttpOnly `nibble_session` cookie through the Vite `/api` proxy, so the web app and API share one origin.

- **Email + password** works with no config. After `seed_storefront_demo.sql`, log in as `alex@example.com` / `nibble-demo`. With the web mock adapter (the default), the same demo login works without the API.
- **Google:** create an OAuth client (type *Web application*) in Google Cloud Console, add `http://localhost:5174/api/v1/auth/oauth/google/callback` as an authorized redirect URI, and put `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` in `.env` (see [`.env.example`](.env.example)). Authentication uses the real API even when the pictured catalog is enabled. Set `VITE_AUTH_MODE=mock` only for isolated UI testing.
- **Apple:** needs an Apple Developer account (Services ID, Sign in with Apple key) and an **HTTPS** redirect URI, which Apple requires. Point `OAUTH_CALLBACK_BASE_URL` at a public HTTPS origin (for example a tunnel to port 5174), set `AUTH_COOKIE_SECURE=true`, and fill the `APPLE_*` variables.

SSO buttons stay disabled until their provider is configured (`GET /v1/auth/providers`).

**Not in the MVP (needed later):**

- Rate limiting / lockout on `POST /v1/auth/login` and `/signup`.
- Password reset (forgot-password email + reset token).
- Email verification for password sign-ups (SSO accounts are already provider-verified).
- A real guest storefront: signed-out visitors currently fall back to `DEFAULT_ACCOUNT_ID` (`acct_dev`) for addresses, cart, and orders.

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

### Google sign-in local setup

1. Copy `.env.example` to `.env` in this repository. Add the Google Web application client ID and secret locally; never put secrets in `VITE_*` variables or Git.
2. In Google Cloud, configure the consent screen and add test users while the app is in testing. Register exactly `http://localhost:5174/api/v1/auth/oauth/google/callback` as the authorized redirect URI.
3. Set `OAUTH_CALLBACK_BASE_URL=http://localhost:5174/api`. Run `docker compose up -d --build api-engine web-platform` from this directory.
4. Open `http://localhost:5174/login`. Google becomes enabled when the API has both credentials. Complete consent, reload to verify the cookie session persists, then log out to verify it is cleared.

For the separately running Vite catalog preview, point `API_ENGINE_URL` at the auth-capable API (the Compose HTTP default is `http://localhost:8081`) and start Vite on port 5174. Restart the API after changing credentials. If using another frontend port, register that exact callback with Google and update `OAUTH_CALLBACK_BASE_URL` too.

The catalog preview still serves catalog/account demo data; a real login does not turn its mocked addresses or orders into persistent user data. Use `VITE_MOCK=0` for the fully backend-connected app.

Provider reference: https://developers.google.com/identity/protocols/oauth2/web-server
