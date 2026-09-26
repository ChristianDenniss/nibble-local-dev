param(
    [switch]$Build
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== web-platform local-dev ==="
Write-Host "Starting postgres, api-engine, data-acquisition, web-platform in the foreground."
Write-Host "You will see image/container progress, database init, migrations, and service logs."
Write-Host "Ctrl+C stops the stack."
Write-Host ""

$env:BUILDKIT_PROGRESS = "plain"

if ($Build) {
    Write-Host "Building images (GitHub token from gh auth), then attaching logs..."
    powershell -NoProfile -ExecutionPolicy Bypass -File .\with-github-auth.ps1 --progress=plain up --build --remove-orphans --timestamps
    exit $LASTEXITCODE
}

Write-Host "Attaching to compose (use .\start.ps1 -Build to rebuild images first)..."
docker compose --progress=plain up --remove-orphans --timestamps
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
