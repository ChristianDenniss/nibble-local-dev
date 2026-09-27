-- Legacy storefront catalog for GET /storefront (matches nibble-web-platform mock shape).
-- psql postgres://nibble:nibble@localhost:5433/nibble?sslmode=disable -f scripts/seed_storefront_demo.sql

INSERT INTO providers (id, name) VALUES
  ('prov_skip', 'Skip'),
  ('prov_doordash', 'DoorDash'),
  ('prov_ubereats', 'Uber Eats'),
  ('prov_instacart', 'Instacart'),
  ('prov_grubhub', 'Grubhub'),
  ('prov_fantuan', 'Fantuan')
ON CONFLICT (id) DO NOTHING;

INSERT INTO categories (id, slug, name, description) VALUES
  ('cat_food', 'food', 'Food', 'Restaurants near you'),
  ('cat_grocery', 'grocery', 'Grocery', 'Same-day grocery'),
  ('cat_convenience', 'convenience', 'Convenience', 'Snacks and essentials'),
  ('cat_alcohol', 'alcohol', 'Alcohol', 'Beer, wine, and more'),
  ('cat_pickup', 'pickup', 'Pickup', 'Skip the delivery fee'),
  ('cat_retail', 'retail', 'Retail', 'Stores and extras'),
  ('cat_pets', 'pets', 'Pets', 'Food and supplies'),
  ('cat_pharmacy', 'pharmacy', 'Pharmacy', 'Health and wellness'),
  ('cat_flowers', 'flowers', 'Flowers', 'Bouquets and plants'),
  ('cat_baby', 'baby', 'Baby', 'Diapers, formula, and more'),
  ('cat_beauty', 'beauty', 'Beauty', 'Skincare and cosmetics'),
  ('cat_bakery', 'bakery', 'Bakery', 'Fresh bread and pastries'),
  ('cat_gifts', 'gifts', 'Gifts', 'Last-minute presents')
ON CONFLICT (id) DO NOTHING;

INSERT INTO cuisines (id, slug, name) VALUES
  ('cui_sushi', 'sushi', 'Sushi'),
  ('cui_pizza', 'pizza', 'Pizza'),
  ('cui_burgers', 'burgers', 'Burgers'),
  ('cui_mexican', 'mexican', 'Mexican'),
  ('cui_indian', 'indian', 'Indian'),
  ('cui_coffee', 'coffee', 'Coffee'),
  ('cui_healthy', 'healthy', 'Healthy'),
  ('cui_dessert', 'dessert', 'Dessert'),
  ('cui_chinese', 'chinese', 'Chinese'),
  ('cui_thai', 'thai', 'Thai'),
  ('cui_seafood', 'seafood', 'Seafood'),
  ('cui_sandwiches', 'sandwiches', 'Sandwiches'),
  ('cui_wings', 'wings', 'Wings'),
  ('cui_breakfast', 'breakfast', 'Breakfast'),
  ('cui_vegan', 'vegan', 'Vegan'),
  ('cui_donuts', 'donuts', 'Donuts')
ON CONFLICT (id) DO NOTHING;

-- phone / app_url: direct ordering paths (empty = not offered). Demo values, not real businesses.
INSERT INTO restaurants (id, name, latitude, longitude, address, city, region, postal_code, rating_average, rating_count, phone, app_url) VALUES
  ('rest_koi', 'Koi Sushi', 45.9636, -66.6431, '410 Queen St', 'Fredericton', 'NB', '', 4.7, 1284, '506-555-0110', 'https://apps.apple.com/ca/app/koi-sushi/id0000000001'),
  ('rest_slice', 'River Slice', 45.9636, -66.6431, '394 King St', 'Fredericton', 'NB', '', 4.5, 892, '506-555-0122', ''),
  ('rest_stack', 'The Stack', 45.9636, -66.6431, '480 Queen St', 'Fredericton', 'NB', '', 4.4, 2103, '', 'https://apps.apple.com/ca/app/the-stack/id0000000002'),
  ('rest_wendys_main', 'Wendy''s (370 Main Street)', 45.9636, -66.6431, '370 Main Street', 'Fredericton', 'NB', '', 4.2, 0, '', ''),
  ('rest_wendys_prospect', 'Wendy''s (967 Prospect St)', 45.9636, -66.6431, '967 Prospect St', 'Fredericton', 'NB', '', 4.2, 0, '', ''),
  ('rest_mcdonalds_prospect', 'McDonald''s (1177 Prospect St)', 45.9636, -66.6431, '1177 Prospect St', 'Fredericton', 'NB', '', 4.1, 0, '', ''),
  ('rest_mcdonalds_nashwaaksis', 'McDonald''s (Nashwaaksis)', 45.9830, -66.6500, 'Nashwaaksis', 'Fredericton', 'NB', '', 4.1, 0, '', '')
ON CONFLICT (id) DO UPDATE SET phone = EXCLUDED.phone, app_url = EXCLUDED.app_url;

INSERT INTO restaurant_cuisines (restaurant_id, cuisine_id) VALUES
  ('rest_koi', 'cui_sushi'),
  ('rest_slice', 'cui_pizza'),
  ('rest_stack', 'cui_burgers'),
  ('rest_wendys_main', 'cui_burgers'),
  ('rest_wendys_prospect', 'cui_burgers'),
  ('rest_mcdonalds_prospect', 'cui_burgers'),
  ('rest_mcdonalds_nashwaaksis', 'cui_burgers')
ON CONFLICT DO NOTHING;

INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES
  ('rest_koi', 'cat_food'),
  ('rest_slice', 'cat_food'),
  ('rest_stack', 'cat_food'),
  ('rest_wendys_main', 'cat_food'),
  ('rest_wendys_prospect', 'cat_food'),
  ('rest_mcdonalds_prospect', 'cat_food'),
  ('rest_mcdonalds_nashwaaksis', 'cat_food')
ON CONFLICT DO NOTHING;

-- Store vs delivery hours differ on purpose. Days: 0 = Sunday. Requires migration 0010_restaurant_hours.
DELETE FROM restaurant_hours WHERE restaurant_id IN ('rest_koi', 'rest_slice', 'rest_stack');
INSERT INTO restaurant_hours (restaurant_id, service, day_of_week, opens, closes)
SELECT h.restaurant_id, h.service, d.day, h.opens, h.closes
FROM (VALUES
  ('rest_koi',   'store',    ARRAY[0, 2, 3, 4, 5, 6], '11:30', '21:30'),
  ('rest_koi',   'delivery', ARRAY[0, 2, 3, 4, 5, 6], '12:00', '21:00'),
  ('rest_slice', 'store',    ARRAY[0, 1, 2, 3, 4],    '11:00', '23:00'),
  ('rest_slice', 'store',    ARRAY[5, 6],             '11:00', '02:00'),
  ('rest_slice', 'delivery', ARRAY[0, 1, 2, 3, 4],    '11:00', '22:30'),
  ('rest_slice', 'delivery', ARRAY[5, 6],             '11:00', '01:00'),
  ('rest_stack', 'store',    ARRAY[0, 1, 2, 3, 4, 5, 6], '11:00', '22:00'),
  ('rest_stack', 'delivery', ARRAY[0, 1, 2, 3, 4, 5, 6], '16:00', '21:30')
) AS h(restaurant_id, service, days, opens, closes)
CROSS JOIN LATERAL unnest(h.days) AS d(day);

-- image_url: external photos (no hosting yet). Change later with PUT /v1/menu-items/{id}/image.
INSERT INTO menu_items (id, restaurant_id, name, description, section, image_url) VALUES
  ('item_koi_tuna', 'rest_koi', 'Spicy Tuna Roll', 'Tuna, chili mayo, cucumber, sesame.', 'Rolls',
    'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=480&q=80&auto=format&fit=crop'),
  ('item_slice_pepperoni', 'rest_slice', 'Pepperoni Pie', '14 inch hand-stretched pepperoni.', 'Pizzas',
    'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=480&q=80&auto=format&fit=crop'),
  ('item_stack_classic', 'rest_stack', 'Classic Smash', 'Two smash patties, American cheese.', 'Burgers',
    'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=480&q=80&auto=format&fit=crop')
ON CONFLICT (id) DO UPDATE SET image_url = EXCLUDED.image_url WHERE menu_items.image_url = '';

INSERT INTO offers (id, restaurant_id, provider_id, menu_item_id, amount_cents, currency, estimated_minutes) VALUES
  ('off_koi_tuna_skip', 'rest_koi', 'prov_skip', 'item_koi_tuna', 1499, 'CAD', 28),
  ('off_koi_tuna_dd', 'rest_koi', 'prov_doordash', 'item_koi_tuna', 1649, 'CAD', 32),
  ('off_koi_tuna_ue', 'rest_koi', 'prov_ubereats', 'item_koi_tuna', 1579, 'CAD', 30),
  ('off_koi_tuna_ft', 'rest_koi', 'prov_fantuan', 'item_koi_tuna', 1459, 'CAD', 34),
  ('off_slice_pep_skip', 'rest_slice', 'prov_skip', 'item_slice_pepperoni', 2199, 'CAD', 24),
  ('off_slice_pep_ue', 'rest_slice', 'prov_ubereats', 'item_slice_pepperoni', 2149, 'CAD', 27),
  ('off_stack_classic_skip', 'rest_stack', 'prov_skip', 'item_stack_classic', 1599, 'CAD', 20),
  ('off_stack_classic_ic', 'rest_stack', 'prov_instacart', 'item_stack_classic', 1729, 'CAD', 35)
ON CONFLICT (id) DO NOTHING;

INSERT INTO accounts (id, name, email, phone) VALUES
  ('acct_dev', 'Alex Morgan', 'alex@example.com', '506-555-0148')
ON CONFLICT (id) DO NOTHING;

-- Demo login: alex@example.com / nibble-demo (bcrypt, cost 10). Requires migration 0008_auth.
UPDATE accounts
SET password_hash = '$2a$10$s/a.4YqBOSHCTfPEO9kPLO9D09CluZOd7aWaZfhQOayecZyD6c1i2'
WHERE id = 'acct_dev' AND password_hash = '';

INSERT INTO saved_addresses (id, account_id, label, latitude, longitude, address, city, region, postal_code, current) VALUES
  ('addr_home', 'acct_dev', 'UNBF', 45.9458, -66.6414, '3 Bailey Dr', 'Fredericton', 'NB', 'E3B 5A3', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO payment_methods (id, account_id, brand, last4, exp_month, exp_year, is_default) VALUES
  ('pay_visa', 'acct_dev', 'Visa', '4242', 8, 2028, true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO carts (id, account_id) VALUES ('cart_dev', 'acct_dev') ON CONFLICT (id) DO NOTHING;

INSERT INTO cart_lines (id, cart_id, restaurant_id, menu_item_id, provider_id, quantity) VALUES
  ('line_1', 'cart_dev', 'rest_koi', 'item_koi_tuna', 'prov_skip', 2)
ON CONFLICT (id) DO NOTHING;

INSERT INTO orders (id, account_id, restaurant_id, provider_id, placed_at, status, amount_cents, currency) VALUES
  ('ord_1042', 'acct_dev', 'rest_stack', 'prov_skip', '2026-09-21 18:42:00-03', 'completed', 2714, 'CAD')
ON CONFLICT (id) DO NOTHING;

INSERT INTO order_lines (id, order_id, menu_item_id, name, quantity) VALUES
  ('ol_1042_1', 'ord_1042', 'item_stack_classic', 'Classic Smash', 1)
ON CONFLICT (id) DO NOTHING;
