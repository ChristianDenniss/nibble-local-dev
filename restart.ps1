$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== web-platform local-dev ==="
Write-Host "Stopping the stack, then starting it again in the foreground."
Write-Host "Ctrl+C stops the stack."
Write-Host ""

$env:BUILDKIT_PROGRESS = "plain"
docker compose --progress=plain down
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host "Attaching to compose..."
docker compose --progress=plain up --remove-orphans --timestamps
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
