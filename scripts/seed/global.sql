-- Global catalog: channels + membership products. Apply after migrations (0005_markets).
-- psql postgres://nibble:nibble@localhost:5433/nibble?sslmode=disable -f scripts/seed/global.sql

INSERT INTO channels (id, slug, kind, name) VALUES
  ('ch_skip', 'skip', 'aggregator', 'SkipTheDishes'),
  ('ch_doordash', 'doordash', 'aggregator', 'DoorDash'),
  ('ch_ubereats', 'ubereats', 'aggregator', 'Uber Eats'),
  ('ch_merchant_web', 'merchant-web', 'merchant_web', 'Merchant website'),
  ('ch_phone', 'phone', 'phone', 'Phone order'),
  ('ch_in_person', 'in-person', 'in_person', 'In person')
ON CONFLICT (id) DO UPDATE SET
  slug = EXCLUDED.slug, kind = EXCLUDED.kind, name = EXCLUDED.name, updated_at = now();

INSERT INTO membership_products (id, channel_id, name, slug) VALUES
  ('mp_dashpass', 'ch_doordash', 'DashPass', 'dashpass'),
  ('mp_uber_one', 'ch_ubereats', 'Uber One', 'uber-one'),
  ('mp_skip_plus', 'ch_skip', 'Skip+', 'skip-plus')
ON CONFLICT (id) DO UPDATE SET
  channel_id = EXCLUDED.channel_id, name = EXCLUDED.name, slug = EXCLUDED.slug;
