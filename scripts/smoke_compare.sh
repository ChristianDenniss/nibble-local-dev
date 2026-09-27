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
    "dropoff": { "latitude": 45.9458, "longitude": -66.6414 }
  },
  "basket": { "lines": [{ "dish_id": "dish_burger", "quantity": 1 }] },
  "filters": { "willing_to_use_aggregator": true }
}')"

echo "$resp" | grep -q recommendation || { echo "missing recommendation"; exit 1; }
echo "$resp" | grep -q 'paths_ranked[^0-9]*[3-9]' || { echo "expected at least three providers"; exit 1; }
echo "$resp" | grep -q all_in || { echo "missing all-in total"; exit 1; }
echo "smoke_compare: OK"
