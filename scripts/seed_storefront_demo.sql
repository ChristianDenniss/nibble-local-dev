-- Legacy storefront catalog for GET /storefront (matches nibble-web-platform mock shape).
-- psql postgres://nibble:nibble@localhost:5433/nibble?sslmode=disable -f scripts/seed_storefront_demo.sql

INSERT INTO providers (id, name) VALUES
  ('prov_skip', 'Skip'),
  ('prov_doordash', 'DoorDash')
ON CONFLICT (id) DO NOTHING;

INSERT INTO categories (id, slug, name, description) VALUES
  ('cat_food', 'food', 'Food', 'Restaurants near you'),
  ('cat_grocery', 'grocery', 'Grocery', 'Same-day grocery'),
  ('cat_pickup', 'pickup', 'Pickup', 'Skip the delivery fee')
ON CONFLICT (id) DO NOTHING;

INSERT INTO cuisines (id, slug, name) VALUES
  ('cui_sushi', 'sushi', 'Sushi'),
  ('cui_pizza', 'pizza', 'Pizza'),
  ('cui_burgers', 'burgers', 'Burgers')
ON CONFLICT (id) DO NOTHING;

INSERT INTO restaurants (id, name, latitude, longitude, address, city, region, postal_code, rating_average, rating_count) VALUES
  ('rest_koi', 'Koi Sushi', 45.9636, -66.6431, '410 Queen St', 'Fredericton', 'NB', '', 4.7, 1284),
  ('rest_slice', 'River Slice', 45.9636, -66.6431, '394 King St', 'Fredericton', 'NB', '', 4.5, 892),
  ('rest_stack', 'The Stack', 45.9636, -66.6431, '480 Queen St', 'Fredericton', 'NB', '', 4.4, 2103)
ON CONFLICT (id) DO NOTHING;

INSERT INTO restaurant_cuisines (restaurant_id, cuisine_id) VALUES
  ('rest_koi', 'cui_sushi'),
  ('rest_slice', 'cui_pizza'),
  ('rest_stack', 'cui_burgers')
ON CONFLICT DO NOTHING;

INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES
  ('rest_koi', 'cat_food'),
  ('rest_slice', 'cat_food'),
  ('rest_stack', 'cat_food')
ON CONFLICT DO NOTHING;

INSERT INTO menu_items (id, restaurant_id, name, description, section) VALUES
  ('item_koi_tuna', 'rest_koi', 'Spicy Tuna Roll', 'Tuna, chili mayo, cucumber, sesame.', 'Rolls'),
  ('item_slice_pepperoni', 'rest_slice', 'Pepperoni Pie', '14 inch hand-stretched pepperoni.', 'Pizzas'),
  ('item_stack_classic', 'rest_stack', 'Classic Smash', 'Two smash patties, American cheese.', 'Burgers')
ON CONFLICT (id) DO NOTHING;

INSERT INTO offers (id, restaurant_id, provider_id, menu_item_id, amount_cents, currency, estimated_minutes) VALUES
  ('off_koi_tuna_skip', 'rest_koi', 'prov_skip', 'item_koi_tuna', 1499, 'CAD', 28),
  ('off_koi_tuna_dd', 'rest_koi', 'prov_doordash', 'item_koi_tuna', 1649, 'CAD', 32),
  ('off_slice_pep_skip', 'rest_slice', 'prov_skip', 'item_slice_pepperoni', 2199, 'CAD', 24),
  ('off_stack_classic_skip', 'rest_stack', 'prov_skip', 'item_stack_classic', 1599, 'CAD', 20)
ON CONFLICT (id) DO NOTHING;

INSERT INTO accounts (id, name, email, phone) VALUES
  ('acct_dev', 'Alex Morgan', 'alex@example.com', '506-555-0148')
ON CONFLICT (id) DO NOTHING;

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
