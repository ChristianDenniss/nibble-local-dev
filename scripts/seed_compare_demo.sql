-- Minimal fixture: pickup vs third-party delivery for POST /v1/compare.
-- Apply after migrations: psql "$DATABASE_URL" -f scripts/seed_compare_demo.sql

INSERT INTO channels (id, slug, kind, name) VALUES
  ('ch_skip', 'skip', 'aggregator', 'Skip'),
  ('ch_store', 'store', 'merchant_app', 'Store app')
ON CONFLICT (id) DO NOTHING;

INSERT INTO brands (id, slug, name) VALUES ('br_demo', 'demo-burger', 'Demo Burger')
ON CONFLICT (id) DO NOTHING;

INSERT INTO places (id, brand_id, name, latitude, longitude, address, city, region, postal_code) VALUES
  ('pl_demo', 'br_demo', 'Demo Burger Queen St', 45.9636, -66.6431, '427 Queen St', 'Fredericton', 'NB', 'E3B 1B5')
ON CONFLICT (id) DO NOTHING;

INSERT INTO dishes (id, brand_id, name, description) VALUES
  ('dish_burger', 'br_demo', 'Classic Burger', 'Demo canonical dish')
ON CONFLICT (id) DO NOTHING;

INSERT INTO source_stores (id, channel_id, external_store_id, name, latitude, longitude) VALUES
  ('ss_skip', 'ch_skip', 'ext-skip-1', 'Demo via Skip', 45.9636, -66.6431),
  ('ss_store', 'ch_store', 'ext-store-1', 'Demo store direct', 45.9636, -66.6431)
ON CONFLICT (id) DO NOTHING;

INSERT INTO place_purchase_options (id, place_id, channel_id, fulfillment_mode, delivery_executor, source_store_id) VALUES
  ('ppo_pickup', 'pl_demo', 'ch_store', 'pickup', '', 'ss_store'),
  ('ppo_3p', 'pl_demo', 'ch_skip', 'delivery', 'third_party', 'ss_skip')
ON CONFLICT (id) DO NOTHING;

INSERT INTO source_menus (id, source_store_id, fulfillment_mode, delivery_executor) VALUES
  ('menu_store_pickup', 'ss_store', 'pickup', ''),
  ('menu_skip_del', 'ss_skip', 'delivery', 'third_party')
ON CONFLICT (id) DO NOTHING;

INSERT INTO source_categories (id, source_menu_id, name) VALUES
  ('cat_store', 'menu_store_pickup', 'Mains'),
  ('cat_skip', 'menu_skip_del', 'Mains')
ON CONFLICT (id) DO NOTHING;

INSERT INTO source_items (id, source_category_id, name) VALUES
  ('si_store_burger', 'cat_store', 'Classic Burger'),
  ('si_skip_burger', 'cat_skip', 'Classic Burger')
ON CONFLICT (id) DO NOTHING;

INSERT INTO item_matches (id, source_item_id, dish_id, confidence, status, method) VALUES
  ('im_store', 'si_store_burger', 'dish_burger', 0.99, 'active', 'manual'),
  ('im_skip', 'si_skip_burger', 'dish_burger', 0.99, 'active', 'manual')
ON CONFLICT (id) DO NOTHING;

INSERT INTO item_price_observations (id, source_item_id, amount_cents, currency, fulfillment_mode, delivery_executor, observed_at) VALUES
  ('ipo_store', 'si_store_burger', 1200, 'CAD', 'pickup', '', now()),
  ('ipo_skip', 'si_skip_burger', 1350, 'CAD', 'delivery', 'third_party', now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO quote_observations (
  id, source_store_id, channel_id, fulfillment_mode, delivery_executor, dropoff_geohash,
  membership_tier, quote_kind, basket_subtotal_cents, observed_at
) VALUES (
  'qo_skip', 'ss_skip', 'ch_skip', 'delivery', 'third_party', 'f80t7',
  '', 'indicative', 1000, now()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO quote_fee_lines (id, quote_obs_id, kind, amount_cents, currency) VALUES
  ('qfl_del', 'qo_skip', 'delivery', 399, 'CAD'),
  ('qfl_svc', 'qo_skip', 'service', 199, 'CAD')
ON CONFLICT (id) DO NOTHING;
