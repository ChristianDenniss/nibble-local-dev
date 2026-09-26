$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

$LocalDevRoot = $PSScriptRoot
$WorkspaceRoot = Split-Path -Parent $LocalDevRoot

$Repos = @(
    "go-data-model",
    "platform-contracts",
    "api-engine",
    "data-acquisition",
    "web-platform",
    "local-dev"
)

function Get-GitHubOwner {
    if (-not [string]::IsNullOrWhiteSpace($env:GITHUB_OWNER)) {
        return $env:GITHUB_OWNER
    }

    $origin = git -C $LocalDevRoot remote get-url origin 2>$null
    if ($LASTEXITCODE -eq 0 -and $origin -match "github\.com[:/](?<owner>[^/]+)/") {
        return $Matches["owner"]
    }

    return "ChristianDenniss"
}

$Owner = Get-GitHubOwner
Write-Host "Using GitHub owner: $Owner"
Write-Host "Workspace root: $WorkspaceRoot"

foreach ($name in $Repos) {
    $path = Join-Path $WorkspaceRoot $name
    $url = "https://github.com/$Owner/$name.git"

    if (Test-Path (Join-Path $path ".git")) {
        Write-Host "pulling $name"
        git -C $path pull --ff-only origin main
        if ($LASTEXITCODE -ne 0) {
            throw "git pull failed for $name"
        }
        continue
    }

    if (Test-Path $path) {
        throw "$path exists but is not a git repo. Remove it or clone manually."
    }

    Write-Host "cloning $name"
    git clone $url $path
    if ($LASTEXITCODE -ne 0) {
        throw "git clone failed for $name"
    }
}

Write-Host "All repos are present at latest main."
Write-Host "Next: make build && make start"
