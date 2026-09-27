-- Home feed demo: public promotions (plane 6) and sponsored placements (plane 9) on the legacy
-- storefront restaurants. Apply after scripts/seed/global.sql and scripts/seed_storefront_demo.sql.
-- psql postgres://nibble:nibble@localhost:5433/nibble?sslmode=disable -f scripts/seed_merchandising_demo.sql

-- Public promotions (providers' deals; not paid placement)
INSERT INTO promotions (id, channel_id, name, description, kind, fulfillment_mode, value_cents, value_bps, currency, starts_at, ends_at) VALUES
  ('promo_koi_pickup', 'ch_merchant_web', 'Koi Sushi pickup deal', '20% off when you order pickup direct from Koi.', 'percent_off', 'pickup', 0, 2000, 'CAD', '2026-01-01 00:00:00-04', '2027-12-31 23:59:59-04'),
  ('promo_slice_free_delivery', 'ch_ubereats', 'Free delivery on River Slice', 'No delivery fee on Uber Eats this month.', 'free_delivery', 'delivery', 0, 0, 'CAD', '2026-01-01 00:00:00-04', '2027-12-31 23:59:59-04'),
  ('promo_stack_5_off', 'ch_doordash', '$5 off The Stack', '', 'amount_off', '', 500, 0, 'CAD', '2026-01-01 00:00:00-04', '2027-12-31 23:59:59-04'),
  ('promo_skip_wendys_40_today', 'ch_skip', '40% off Wendy''s', 'Get 40% off Wendy''s on Skip with code FH9221B1. Minimum $30 spend. Today only.', 'percent_off', 'delivery', 0, 4000, 'CAD', '2026-09-27 00:00:00-03', '2026-09-27 23:59:59-03'),
  ('promo_skip_cibc_welcome_20', 'ch_skip', '$20 off with CIBC + Skip+', 'Eligible CIBC cardholders get a $20 welcome voucher on a Skip+ order of $40 or more. Check My Skip for eligibility.', 'amount_off', 'delivery', 2000, 0, 'CAD', '2026-01-01 00:00:00-04', '2027-12-31 23:59:59-04'),
  ('promo_skip_cibc_monthly_10', 'ch_skip', '$10 monthly Skip voucher', 'Eligible CIBC cardholders get a $10 Skip voucher after four orders of $30 or more in a calendar month. Check My Skip for eligibility.', 'amount_off', 'delivery', 1000, 0, 'CAD', '2026-01-01 00:00:00-04', '2027-12-31 23:59:59-04'),
  ('promo_mcd_value_meal_5', 'ch_merchant_web', '$5 McValue Meals', 'Selected McValue Meals are $5 at participating McDonald''s locations. In-store or drive-thru only; not available through delivery.', 'fixed_price', 'pickup', 500, 0, 'CAD', '2026-01-13 00:00:00-04', '2027-01-12 23:59:59-04'),
  ('promo_mcd_coffee_1', 'ch_merchant_web', '$1 small McCafé coffee', 'Small McCafé Premium Roast coffee is $1 at participating McDonald''s locations. In-store or drive-thru only; not available through delivery.', 'fixed_price', 'pickup', 100, 0, 'CAD', '2026-01-13 00:00:00-04', '2027-01-12 23:59:59-04')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name, description = EXCLUDED.description, kind = EXCLUDED.kind,
  fulfillment_mode = EXCLUDED.fulfillment_mode, value_cents = EXCLUDED.value_cents, value_bps = EXCLUDED.value_bps,
  starts_at = EXCLUDED.starts_at, ends_at = EXCLUDED.ends_at, updated_at = now();

INSERT INTO promotion_constraints (id, promotion_id, min_subtotal_cents) VALUES
  ('pc_stack_5_off_min', 'promo_stack_5_off', 2500),
  ('pc_skip_wendys_40_min', 'promo_skip_wendys_40_today', 3000),
  ('pc_skip_cibc_welcome_min', 'promo_skip_cibc_welcome_20', 4000),
  ('pc_skip_cibc_monthly_min', 'promo_skip_cibc_monthly_10', 3000),
  ('pc_mcd_value_meal', 'promo_mcd_value_meal_5', 0),
  ('pc_mcd_coffee', 'promo_mcd_coffee_1', 0)
ON CONFLICT (id) DO UPDATE SET min_subtotal_cents = EXCLUDED.min_subtotal_cents;

UPDATE promotion_constraints
SET code = 'FH9221B1'
WHERE id = 'pc_skip_wendys_40_min';

UPDATE promotion_constraints
SET membership_required = true
WHERE id IN ('pc_skip_cibc_welcome_min', 'pc_skip_cibc_monthly_min');

INSERT INTO promotion_targets (id, promotion_id, legacy_restaurant_id) VALUES
  ('pt_koi_pickup', 'promo_koi_pickup', 'rest_koi'),
  ('pt_slice_free_delivery', 'promo_slice_free_delivery', 'rest_slice'),
  ('pt_stack_5_off', 'promo_stack_5_off', 'rest_stack'),
  ('pt_skip_wendys_40_main', 'promo_skip_wendys_40_today', 'rest_wendys_main'),
  ('pt_skip_wendys_40_prospect', 'promo_skip_wendys_40_today', 'rest_wendys_prospect'),
  ('pt_mcd_value_meal_prospect', 'promo_mcd_value_meal_5', 'rest_mcdonalds_prospect'),
  ('pt_mcd_value_meal_nashwaaksis', 'promo_mcd_value_meal_5', 'rest_mcdonalds_nashwaaksis'),
  ('pt_mcd_coffee_prospect', 'promo_mcd_coffee_1', 'rest_mcdonalds_prospect'),
  ('pt_mcd_coffee_nashwaaksis', 'promo_mcd_coffee_1', 'rest_mcdonalds_nashwaaksis')
ON CONFLICT (id) DO UPDATE SET legacy_restaurant_id = EXCLUDED.legacy_restaurant_id;

-- Advertisers pay Nibble for labelled placements (never affects compare, D28)
INSERT INTO advertisers (id, name, contact_email, status) VALUES
  ('adv_koi', 'Koi Sushi', 'owner@koisushi.example', 'active'),
  ('adv_slice', 'River Slice', 'hello@riverslice.example', 'active'),
  ('adv_stack', 'The Stack', 'marketing@thestack.example', 'active')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, contact_email = EXCLUDED.contact_email, status = EXCLUDED.status, updated_at = now();

INSERT INTO sponsored_campaigns (id, advertiser_id, market_id, name, status, starts_at, ends_at, pricing_model, bid_cents, daily_budget_cents, total_budget_cents, currency) VALUES
  ('camp_koi_fall', 'adv_koi', 'mkt_fredericton', 'Koi fall launch', 'active', '2026-01-01 00:00:00-04', '2027-12-31 23:59:59-04', 'cpm', 800, 2000, 50000, 'CAD'),
  ('camp_slice_students', 'adv_slice', 'mkt_fredericton', 'River Slice students', 'active', '2026-01-01 00:00:00-04', '2027-12-31 23:59:59-04', 'cpc', 45, 1500, 30000, 'CAD'),
  ('camp_stack_always_on', 'adv_stack', NULL, 'The Stack always-on', 'active', '2026-01-01 00:00:00-04', '2027-12-31 23:59:59-04', 'flat', 300, 0, 20000, 'CAD')
ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status, starts_at = EXCLUDED.starts_at, ends_at = EXCLUDED.ends_at,
  pricing_model = EXCLUDED.pricing_model, bid_cents = EXCLUDED.bid_cents,
  daily_budget_cents = EXCLUDED.daily_budget_cents, total_budget_cents = EXCLUDED.total_budget_cents, updated_at = now();

INSERT INTO sponsored_placements (id, campaign_id, slot, priority, legacy_restaurant_id, promotion_id, headline, body, image_url, call_to_action) VALUES
  ('spl_koi_banner', 'camp_koi_fall', 'home_banner', 10, 'rest_koi', 'promo_koi_pickup', 'Fresh rolls, 20% off pickup', 'Order direct from Koi Sushi and skip the app fees.', '', 'Order now'),
  ('spl_slice_banner', 'camp_slice_students', 'home_banner', 5, 'rest_slice', NULL, 'Late-night slices near UNB', 'River Slice is open until 2 AM on weekends.', '', 'See menu'),
  ('spl_koi_rail', 'camp_koi_fall', 'home_rail', 10, 'rest_koi', NULL, 'Chef''s picks this week', '', '', ''),
  ('spl_slice_rail', 'camp_slice_students', 'home_rail', 5, 'rest_slice', NULL, 'Student favourite', '', '', ''),
  ('spl_stack_rail', 'camp_stack_always_on', 'home_rail', 0, 'rest_stack', NULL, 'Smash burgers done right', '', '', '')
ON CONFLICT (id) DO UPDATE SET
  slot = EXCLUDED.slot, priority = EXCLUDED.priority, legacy_restaurant_id = EXCLUDED.legacy_restaurant_id,
  promotion_id = EXCLUDED.promotion_id, headline = EXCLUDED.headline, body = EXCLUDED.body,
  image_url = EXCLUDED.image_url, call_to_action = EXCLUDED.call_to_action, updated_at = now();
