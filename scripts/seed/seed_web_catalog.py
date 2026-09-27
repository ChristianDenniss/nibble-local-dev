"""Generate the API demo seed from the web app's mock catalog.

Usage:
  python scripts/seed/seed_web_catalog.py | psql "$DATABASE_URL"

The web mock and API demo therefore share one source of truth instead of
drifting as restaurants, menu items, or offers are added.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[3]
DEFAULT_CATALOG = ROOT / "nibble-web-platform" / "src" / "catalog" / "catalog.json"

PROVIDERS = {
    "prov_ubereats": "Uber Eats",
    "prov_doordash": "DoorDash",
    "prov_skip": "SkipTheDishes",
    "prov_direct": "Restaurant website",
}

CATEGORIES = {
    "cat_food": ("food", "Food", "Restaurants near you"),
}

CUISINES = {
    "cui_burgers": ("burgers", "Burgers"),
    "cui_chicken": ("chicken", "Chicken"),
    "cui_mexican": ("mexican", "Mexican"),
    "cui_pizza": ("pizza", "Pizza"),
    "cui_shawarma": ("shawarma", "Shawarma"),
    "cui_sushi": ("sushi", "Sushi"),
    "cui_indian": ("indian", "Indian"),
    "cui_coffee": ("coffee", "Coffee"),
    "cui_healthy": ("healthy", "Healthy"),
    "cui_dessert": ("dessert", "Dessert"),
    "cui_chinese": ("chinese", "Chinese"),
    "cui_thai": ("thai", "Thai"),
    "cui_seafood": ("seafood", "Seafood"),
    "cui_sandwiches": ("sandwiches", "Sandwiches"),
    "cui_wings": ("wings", "Wings"),
    "cui_breakfast": ("breakfast", "Breakfast"),
    "cui_vegan": ("vegan", "Vegan"),
    "cui_donuts": ("donuts", "Donuts"),
}


def sql(value: Any) -> str:
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, (int, float)):
        return str(value)
    return "'" + str(value).replace("'", "''") + "'"


def batches(rows: Iterable[tuple[Any, ...]], size: int = 500) -> Iterable[list[tuple[Any, ...]]]:
    batch: list[tuple[Any, ...]] = []
    for row in rows:
        batch.append(row)
        if len(batch) == size:
            yield batch
            batch = []
    if batch:
        yield batch


def insert(table: str, columns: tuple[str, ...], rows: Iterable[tuple[Any, ...]], conflict: str = "DO NOTHING") -> str:
    statements: list[str] = []
    for batch in batches(rows):
        values = ",\n".join(
            "  (" + ", ".join(sql(value) for value in row) + ")"
            for row in batch
        )
        statements.append(
            f"INSERT INTO {table} ({', '.join(columns)}) VALUES\n{values}\nON CONFLICT {conflict};"
        )
    return "\n\n".join(statements)


def restaurant_rows(catalog: dict[str, Any]) -> list[tuple[Any, ...]]:
    rows = []
    for restaurant in catalog["restaurants"]:
        location = restaurant.get("location", {})
        rating = restaurant.get("rating", {})
        rows.append((
            restaurant["id"], restaurant["name"], restaurant.get("imageURL", ""), location.get("latitude", 0),
            location.get("longitude", 0), location.get("address", ""),
            location.get("city", ""), location.get("region", ""),
            location.get("postalCode", ""), rating.get("average", 0),
            rating.get("count", 0), restaurant.get("phone", ""),
            restaurant.get("appURL", ""),
        ))
    return rows


def item_rows(catalog: dict[str, Any]) -> list[tuple[Any, ...]]:
    return [
        (
            item["id"], item["restaurantId"], item["name"],
            item.get("description", ""), item.get("section", ""),
            item.get("imageURL", ""),
        )
        for item in catalog["items"]
    ]


def offer_rows(catalog: dict[str, Any]) -> list[tuple[Any, ...]]:
    return [
        (
            offer["id"], offer["restaurantId"], offer["providerId"],
            offer.get("menuItemId", ""), offer.get("price", {}).get("amountCents", 0),
            offer.get("price", {}).get("currency", "CAD"), offer.get("estimatedMinutes", 0),
        )
        for offer in catalog["offers"]
    ]


def taco_boyz_base_price_rows(catalog: dict[str, Any]) -> list[tuple[Any, ...]]:
    """Add a few first-party base prices alongside delivery-provider prices.

    Values are representative menu prices checked against Taco Boyz's official
    order/menu pages on 2026-09-27; taxes and delivery fees are excluded.
    """
    restaurant = next(
        (entry for entry in catalog["restaurants"] if "520 Smythe" in entry.get("name", "")),
        None,
    )
    if not restaurant:
        return []
    prices = {
        "Regular Nachos": 595,
        "Regular Burrito": 995,
        "Regular Burrito Bowl": 995,
        "Regular Quesadilla": 1035,
        "Three Tacos": 1095,
    }
    items = {
        item["name"]: item
        for item in catalog["items"]
        if item.get("restaurantId") == restaurant["id"]
    }
    return [
        (
            f"{item['id']}_prov_direct", restaurant["id"], "prov_direct", item["id"],
            amount_cents, "CAD", 0,
        )
        for name, amount_cents in prices.items()
        if (item := items.get(name)) is not None
    ]


def main() -> None:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--catalog", type=Path, default=DEFAULT_CATALOG)
    args = parser.parse_args()
    catalog = json.loads(args.catalog.read_text(encoding="utf-8"))

    print("-- Generated from nibble-web-platform/src/catalog/catalog.json. Do not edit by hand.")
    print("BEGIN;")
    print("""
-- Replace the local storefront fixture so API mode matches the web mock.
DELETE FROM restaurant_hours;
DELETE FROM offers;
DELETE FROM menu_items;
DELETE FROM restaurant_cuisines;
DELETE FROM restaurant_categories;
DELETE FROM restaurants;
DELETE FROM providers;
DELETE FROM cuisines;
DELETE FROM categories;
""")

    print(insert("providers", ("id", "name"), PROVIDERS.items()))
    print(insert(
        "categories", ("id", "slug", "name", "description"),
        ((key, slug, name, description) for key, (slug, name, description) in CATEGORIES.items()),
    ))
    print(insert(
        "cuisines", ("id", "slug", "name"),
        ((key, slug, name) for key, (slug, name) in CUISINES.items()),
    ))
    print(insert(
        "restaurants",
        ("id", "name", "image_url", "latitude", "longitude", "address", "city", "region", "postal_code", "rating_average", "rating_count", "phone", "app_url"),
        restaurant_rows(catalog),
    ))
    print(insert(
        "restaurant_categories", ("restaurant_id", "category_id"),
        ((restaurant["id"], category_id) for restaurant in catalog["restaurants"] for category_id in restaurant.get("categoryIds", [])),
    ))
    print(insert(
        "restaurant_cuisines", ("restaurant_id", "cuisine_id"),
        ((restaurant["id"], cuisine_id) for restaurant in catalog["restaurants"] for cuisine_id in restaurant.get("cuisineIds", [])),
    ))
    print(insert(
        "menu_items", ("id", "restaurant_id", "name", "description", "section", "image_url"),
        item_rows(catalog),
    ))
    print(insert(
        "offers", ("id", "restaurant_id", "provider_id", "menu_item_id", "amount_cents", "currency", "estimated_minutes"),
        offer_rows(catalog) + taco_boyz_base_price_rows(catalog),
    ))
    featured = catalog["restaurants"][:3]
    print("DELETE FROM sponsored_placements WHERE slot = 'home_rail';")
    print(insert(
        "advertisers", ("id", "name", "contact_email", "status"),
        (("adv_web_catalog", "Nibble featured partner", "demo@nibble.local", "active"),),
        "(id) DO UPDATE SET name = EXCLUDED.name, contact_email = EXCLUDED.contact_email, status = EXCLUDED.status, updated_at = now()",
    ))
    print(insert(
        "sponsored_campaigns",
        ("id", "advertiser_id", "market_id", "name", "status", "starts_at", "ends_at", "pricing_model", "bid_cents", "daily_budget_cents", "total_budget_cents", "currency"),
        (("camp_web_catalog_featured", "adv_web_catalog", None, "Featured near you", "active", "2026-01-01 00:00:00+00", "2027-12-31 23:59:59+00", "flat", 0, 0, 0, "CAD"),),
        "(id) DO UPDATE SET advertiser_id = EXCLUDED.advertiser_id, name = EXCLUDED.name, status = EXCLUDED.status, starts_at = EXCLUDED.starts_at, ends_at = EXCLUDED.ends_at",
    ))
    print(insert(
        "sponsored_placements",
        ("id", "campaign_id", "slot", "priority", "legacy_restaurant_id", "headline", "body", "image_url", "call_to_action"),
        (
            (f"placement_web_featured_{index + 1}", "camp_web_catalog_featured", "home_rail", 30 - index, restaurant["id"], "", "Explore the menu and compare your whole cart.", restaurant.get("imageURL", ""), "Browse menu")
            for index, restaurant in enumerate(featured)
        ),
        "(id) DO UPDATE SET campaign_id = EXCLUDED.campaign_id, slot = EXCLUDED.slot, priority = EXCLUDED.priority, legacy_restaurant_id = EXCLUDED.legacy_restaurant_id, headline = EXCLUDED.headline, body = EXCLUDED.body, image_url = EXCLUDED.image_url, call_to_action = EXCLUDED.call_to_action, updated_at = now()",
    ))

    print("""
-- Match the account used by the development mock and give it the same locations.
INSERT INTO accounts (id, name, email, phone)
VALUES ('acct_aottgpvp_root', 'Aottg', 'aottgpvp@gmail.com', '506-555-0148')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, email = EXCLUDED.email, phone = EXCLUDED.phone;

DELETE FROM saved_addresses WHERE account_id = 'acct_aottgpvp_root' OR id IN ('addr_home', 'addr_work');
INSERT INTO saved_addresses (id, account_id, label, latitude, longitude, address, city, region, postal_code, current) VALUES
  ('addr_home', 'acct_aottgpvp_root', 'UNBF', 45.9458, -66.6414, '3 Bailey Dr', 'Fredericton', 'NB', 'E3B 5A3', TRUE),
  ('addr_work', 'acct_aottgpvp_root', 'Downtown', 45.9636, -66.6431, '427 Queen St', 'Fredericton', 'NB', 'E3B 1B5', FALSE)
ON CONFLICT (id) DO UPDATE SET account_id = EXCLUDED.account_id, label = EXCLUDED.label,
  latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, address = EXCLUDED.address,
  city = EXCLUDED.city, region = EXCLUDED.region, postal_code = EXCLUDED.postal_code,
  current = EXCLUDED.current;
COMMIT;
""")


if __name__ == "__main__":
    main()
