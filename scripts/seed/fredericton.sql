-- First Nibble market: Fredericton (hackathon / UNBF). Apply after scripts/seed/global.sql.
-- psql postgres://nibble:nibble@localhost:5433/nibble?sslmode=disable -f scripts/seed/fredericton.sql

INSERT INTO markets (id, slug, name, country, region, currency, timezone, status, geohash_prefixes) VALUES
  ('mkt_fredericton', 'fredericton', 'Fredericton', 'CA', 'NB', 'CAD', 'America/Moncton', 'active', 'f80t')
ON CONFLICT (id) DO UPDATE SET
  slug = EXCLUDED.slug, name = EXCLUDED.name, country = EXCLUDED.country, region = EXCLUDED.region,
  currency = EXCLUDED.currency, timezone = EXCLUDED.timezone, status = EXCLUDED.status,
  geohash_prefixes = EXCLUDED.geohash_prefixes, updated_at = now();

INSERT INTO market_probe_dropoffs (
  id, market_id, label, latitude, longitude, address, city, region, postal_code, geohash
) VALUES
  ('probe_frd_unbf', 'mkt_fredericton', 'UNBF campus', 45.9458, -66.6414, '3 Bailey Dr', 'Fredericton', 'NB', 'E3B 5A3', 'f80t7s'),
  ('probe_frd_downtown', 'mkt_fredericton', 'Downtown', 45.9636, -66.6431, '427 Queen St', 'Fredericton', 'NB', 'E3B 1B5', 'f80t7r'),
  ('probe_frd_regent', 'mkt_fredericton', 'Regent / uptown', 45.9369, -66.6630, '1381 Regent St', 'Fredericton', 'NB', 'E3C 1A2', 'f80t74')
ON CONFLICT (id) DO UPDATE SET
  market_id = EXCLUDED.market_id, label = EXCLUDED.label,
  latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, address = EXCLUDED.address,
  city = EXCLUDED.city, region = EXCLUDED.region, postal_code = EXCLUDED.postal_code,
  geohash = EXCLUDED.geohash, updated_at = now();

INSERT INTO channel_market_coverage (id, channel_id, market_id, status, note) VALUES
  ('cov_skip_fredericton', 'ch_skip', 'mkt_fredericton', 'expected', 'Skip operates in Fredericton'),
  ('cov_doordash_fredericton', 'ch_doordash', 'mkt_fredericton', 'expected', 'DoorDash operates in Fredericton'),
  ('cov_ubereats_fredericton', 'ch_ubereats', 'mkt_fredericton', 'unknown', 'Confirm with catalog API'),
  ('cov_in_person_fredericton', 'ch_in_person', 'mkt_fredericton', 'expected', 'Always available'),
  ('cov_phone_fredericton', 'ch_phone', 'mkt_fredericton', 'expected', 'Always available'),
  ('cov_merchant_web_fredericton', 'ch_merchant_web', 'mkt_fredericton', 'expected', 'Per kitchen, not market-wide')
ON CONFLICT (channel_id, market_id) DO UPDATE SET
  id = EXCLUDED.id, status = EXCLUDED.status, note = EXCLUDED.note, updated_at = now();
