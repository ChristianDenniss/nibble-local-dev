$base = if ($env:API_BASE) { $env:API_BASE } else { "http://localhost:8081" }
$url = "$base/v1/source-stores/ss_store/menu?fulfillment_mode=pickup"
Write-Host "GET $url"
$r = Invoke-RestMethod -Uri $url -Method Get
if (-not $r.categories) { throw "expected categories in response" }
Write-Host "OK: $($r.store.name) - $($r.categories[0].items.Count) item(s) in first category"
