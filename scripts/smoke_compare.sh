#!/usr/bin/env bash
set -euo pipefail
BASE="${API_ENGINE_URL:-http://localhost:8081}"

echo "GET $BASE/health"
curl -fsS "$BASE/health" >/dev/null

echo "POST $BASE/v1/compare"
resp="$(curl -fsS -X POST "$BASE/v1/compare" -H 'Content-Type: application/json' -d '{
  "place_id": "pl_demo",
  "fulfillment_context": {
    "mode": "delivery",
    "dropoff": { "latitude": 43.6532, "longitude": -79.3832 }
  },
  "basket": { "lines": [{ "dish_id": "dish_burger", "quantity": 1 }] },
  "filters": { "willing_to_use_aggregator": true }
}')"

echo "$resp" | grep -q recommendation || { echo "missing recommendation"; exit 1; }
echo "smoke_compare: OK"
