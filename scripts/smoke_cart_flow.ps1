# Cart flow smoke test: catalog -> persist cart -> record handoff event.
$base = if ($env:API_BASE) { $env:API_BASE } else { "http://localhost:8081" }

$catalog = Invoke-RestMethod -Uri "$base/v1/storefront?account_id=acct_dev" -Method Get
if (-not $catalog.cart.id) { throw "expected an account cart" }

$lines = @($catalog.cart.lines)
if ($lines.Count -eq 0) {
  $offer = @($catalog.offers)[0]
  if (-not $offer) { throw "expected at least one catalog offer to seed the cart" }
  $lines = @(@{
    restaurantId = $offer.restaurantId
    menuItemId = $offer.menuItemId
    providerId = $offer.providerId
    quantity = 1
  })
}
$body = @{ id = $catalog.cart.id; lines = $lines } | ConvertTo-Json -Depth 8
$saved = Invoke-RestMethod -Uri "$base/v1/cart?account_id=acct_dev" -Method Put -ContentType "application/json" -Body $body
if ($saved.id -ne $catalog.cart.id) { throw "cart was not persisted" }

$eventBody = @{ kind = "handoff"; providerId = $lines[0].providerId; targetURL = "https://example.test" } | ConvertTo-Json
$event = Invoke-RestMethod -Uri "$base/v1/cart/events" -Method Post -ContentType "application/json" -Body $eventBody
if ($event.status -ne "accepted") { throw "cart event was not accepted" }

Write-Host "OK: cart $($saved.id) persisted and handoff event accepted"
