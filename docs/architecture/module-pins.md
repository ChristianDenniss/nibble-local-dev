# Go module pins (services)

Library repos publish tags via semantic-release. Services pin those tags in `go.mod` for Docker/CI (`GOWORK=off`).

## Release order

1. `nibble-platform-contracts`
2. `nibble-go-data-model`
3. `nibble-go-data-store`
4. `nibble-api-engine`, `nibble-data-acquisition`

## Bump after a release

```bash
cd nibble-api-engine
set GOWORK=off   # Windows; use export GOWORK=off on Unix
go get github.com/ChristianDenniss/platform-contracts@v1.3.0
go get github.com/ChristianDenniss/go-data-model@v1.5.0
go get github.com/ChristianDenniss/go-data-store@v1.2.0
go mod tidy
```

`nibble-data-acquisition` only needs `platform-contracts` (ingest v2 client).

Requires `GOPRIVATE=github.com/ChristianDenniss/*` and git credentials for private modules.

## Local simultaneous edits

Use `nibble-local-dev/go.work` — do not add `replace` directives to service `go.mod` for long-lived branches.

## Target pins (update this table when releases land)

| Module | Pin |
|--------|-----|
| platform-contracts | `v1.3.0` |
| go-data-model | `v1.5.0` |
| go-data-store | `v1.2.0` |

`nibble-go-data-store` vendors `go-data-model` for Release verify (no `GH_PAT` required).
