$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI (gh) is required. Install: https://cli.github.com/ then run: gh auth login"
}

gh auth status 1>$null 2>$null
if ($LASTEXITCODE -ne 0) {
    throw "Not logged in. Run: gh auth login"
}

$token = gh auth token
if ([string]::IsNullOrWhiteSpace($token)) {
    throw "Could not read a token from gh. Run: gh auth login"
}

$env:GITHUB_TOKEN = $token
Write-Host "Using GitHub token from gh auth for docker compose (private go mod download)."

if ($args.Count -lt 1) {
    throw "Usage: .\with-github-auth.ps1 <docker compose args...>"
}

& docker compose @args
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
