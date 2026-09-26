# Smoke test: health + compare demo (requires stack on localhost:8081).
$ErrorActionPreference = "Stop"
$base = $env:API_ENGINE_URL
if (-not $base) { $base = "http://localhost:8081" }

Write-Host "GET $base/health"
$h = Invoke-WebRequest -Uri "$base/health" -UseBasicParsing
if ($h.StatusCode -ne 200) { throw "health failed: $($h.StatusCode)" }

$body = @{
  place_id = "pl_demo"
  fulfillment_context = @{
    mode = "delivery"
    dropoff = @{ latitude = 43.6532; longitude = -79.3832 }
  }
  basket = @{ lines = @(@{ dish_id = "dish_burger"; quantity = 1 }) }
  filters = @{ willing_to_use_aggregator = $true }
} | ConvertTo-Json -Depth 6

Write-Host "POST $base/v1/compare"
$c = Invoke-RestMethod -Uri "$base/v1/compare" -Method Post -Body $body -ContentType "application/json"
if (-not $c.recommendation) { throw "no recommendation in response" }
Write-Host "compare_session_id: $($c.compare_session_id)"
Write-Host "winner all_in: $($c.recommendation.all_in.amount_cents) $($c.recommendation.all_in.currency)"
Write-Host "smoke_compare: OK"
