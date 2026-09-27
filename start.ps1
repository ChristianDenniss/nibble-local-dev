param(
    [switch]$Build
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== local-dev stack ==="
Write-Host "Starting postgres, api-engine, data-acquisition, and the Nibble web platform in the foreground."
Write-Host "You will see image/container progress, database init, migrations, and service logs."
Write-Host "Ctrl+C stops the stack."
Write-Host ""

$env:BUILDKIT_PROGRESS = "plain"

function Test-StackImages {
    foreach ($name in @('nibble-api-engine', 'nibble-data-acquisition', 'nibble-web-platform')) {
        docker image inspect $name *> $null
        if ($LASTEXITCODE -ne 0) { return $false }
    }
    return $true
}

$needBuild = [bool]$Build
if (-not $needBuild -and -not (Test-StackImages)) {
    Write-Host "Stack images are missing. Building from sibling checkouts..."
    $needBuild = $true
}

if ($needBuild) {
    Write-Host "Building sibling repositories, then attaching logs..."
    docker compose --progress=plain up --build --remove-orphans --timestamps
    exit $LASTEXITCODE
}

Write-Host "Attaching to compose (use .\start.ps1 -Build to rebuild images first)..."
docker compose --progress=plain up --remove-orphans --timestamps
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
