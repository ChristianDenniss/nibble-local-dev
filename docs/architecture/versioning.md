# Versioning

Each doordash repository versions itself **automatically**. You do not edit version
numbers by hand — the version comes from commit messages on `main`, using the same
[semantic-release](https://semantic-release.gitbook.io/) setup as
[troj-model-dashboard](https://github.com/TrojAISec/troj-model-dashboard).

> **TL;DR** — Squash-merge PRs with Conventional Commit titles (`feat: …`, `fix: …`).
> The Release workflow tags `vX.Y.Z`, publishes a **GitHub Release** with notes, and
> attaches `CHANGELOG.md`.

---

## 1. Semantic Versioning (SemVer)

Every release is `MAJOR.MINOR.PATCH`:

| Part | Bumped when | Meaning |
| --- | --- | --- |
| **MAJOR** | `feat!` or `BREAKING CHANGE:` | Breaking change |
| **MINOR** | `feat:` on `main` | New backwards-compatible feature |
| **PATCH** | `fix:` / `perf:` / `revert:` | Bug fix or small improvement |

**First release on a repo is `v1.0.0`** when the first releasable commit lands on
`main`.

---

## 2. Conventional Commits

```
<type>: <short description>
```

Examples:

```
feat: add ingest health metrics
fix: retry postgres on startup
```

| Type | Version effect |
| --- | --- |
| `feat` | minor |
| `fix`, `perf`, `revert` | patch |
| `chore`, `docs`, `refactor`, `style`, `test` | no release |

Use **`feat!:`** or a **`BREAKING CHANGE:`** footer for a major bump.

Because we **squash-merge**, the **PR title** is what semantic-release reads.

---

## 3. What runs in CI

Every repo has **`.github/workflows/release.yml`**:

1. **Verify** — build/test (Go, Node, or Docker Compose config for `local-dev`).
2. **Release** — semantic-release creates tag `vX.Y.Z`, GitHub Release, and attaches
   `CHANGELOG.md`.

Config: **`.releaserc.json`** (same plugin layout as troj-model-dashboard).

Release tooling is installed ephemerally in CI (not in app `package-lock.json`).

---

## 4. Go modules between repos

Library repos (`go-data-model`, `platform-contracts`) publish **Go module versions**
that match their git tags (`v1.2.3` → `go get …@v1.2.3`).

Services (`api-engine`, `data-acquisition`) pin those modules in **`go.mod`** / **`go.sum`**
at released GitHub tags. **Docker and CI** build each service repo alone and run
`go mod download` — they do not compile against sibling folders on disk.

Optional **`go.work`** in `local-dev` is for developers only (simultaneous edits across
repos). It is not used in Dockerfiles or Release verify jobs.

Release order when changing a shared type:

1. Merge and release the library (`feat:` → new tag).
2. Bump the service: `go get github.com/ChristianDenniss/go-data-model@vX.Y.Z` (with
   `GOWORK=off` in CI) and merge the service PR.

---

## 5. Where to see versions

| Location | What |
| --- | --- |
| **GitHub → Releases** | Official release notes per repo |
| **Tags** | `v*` tags |
| **Actions → Release** | Workflow logs |

Until the first releasable merge to `main`, Releases shows empty — expected.

---

## 6. Maintenance branches

Patch an old line without shipping everything on `main`:

1. Fix on `main` first.
2. Branch `1.2.x` from `tags/v1.2.0`.
3. Cherry-pick, PR to `1.2.x` with `fix:` title → `v1.2.1`.

Maintenance branch names match troj: `1.2.x`, `1.x` (see `.releaserc.json`).

---

## 7. Auth for private Go modules

`go-data-model` and `platform-contracts` are private. **`go mod download`** must run as
an authenticated GitHub user.

**Local (`make build`):** run **`gh auth login`** once. `with-github-auth` reads
`gh auth token` and passes it to Docker for that build only — no PAT file in the repo.

**GitHub Actions:** the default `GITHUB_TOKEN` cannot read other private repos. Whoever
owns the org/account adds a classic PAT as repo secret **`GH_PAT`** on
`api-engine`, `data-acquisition`, and `local-dev` if they want Release verify to pass
(optional one-time setup in GitHub Settings, not in source control).

---

## 8. Dry run locally

Same pins as `release.yml`:

```bash
npm install --no-save --no-package-lock \
  semantic-release@24.2.3 \
  @semantic-release/changelog@6.0.3 \
  @semantic-release/commit-analyzer@13.0.1 \
  @semantic-release/github@11.0.1 \
  @semantic-release/release-notes-generator@14.0.3 \
  conventional-changelog-conventionalcommits@8.0.0
npx semantic-release --dry-run --no-ci
```
