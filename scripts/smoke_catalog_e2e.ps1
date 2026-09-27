# End-to-end: curated ingest (compose) + HTTP catalog read.
# Prereq: stack up with ACQUISITION_ADAPTER=curated (default in docker-compose.yml).
$base = if ($env:API_BASE) { $env:API_BASE } else { "http://localhost:8081" }

Write-Host "GET $base/health"
$h = Invoke-RestMethod -Uri "$base/health" -Method Get
if (($h -is [string] -and $h -ne "ok") -or ($h -isnot [string] -and $h.status -ne "ok")) { throw "health failed" }

Write-Host "GET $base/v1/channels/ch_store/source-stores"
$stores = Invoke-RestMethod -Uri "$base/v1/channels/ch_store/source-stores" -Method Get
if (-not $stores.stores -or $stores.stores.Count -lt 1) {
  throw "expected source stores on ch_store (run data-acquisition curated ingest)"
}

$storeId = $stores.stores[0].id
Write-Host "GET $base/v1/source-stores/$storeId/menu?fulfillment_mode=pickup"
$menu = Invoke-RestMethod -Uri "$base/v1/source-stores/$($storeId)/menu?fulfillment_mode=pickup" -Method Get
if (-not $menu.categories) { throw "expected menu categories" }

Write-Host "OK: channel ch_store -> store $storeId -> menu with $($menu.categories.Count) categor(ies)"
