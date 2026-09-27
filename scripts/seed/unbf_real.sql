-- Curated real-business seed for the UNB Fredericton demo area.
-- Apply after global.sql and seed_storefront_demo.sql:
--   psql postgres://nibble:nibble@localhost:5433/nibble?sslmode=disable -f scripts/seed/unbf_real.sql
--
-- Business metadata is sourced in unbf_real_businesses.json. Menu prices below
-- are representative demo values and must not be presented as live quotes.

-- Remove only the original synthetic storefront fixture and its demo references.
DELETE FROM sponsored_placements WHERE legacy_restaurant_id IN ('rest_koi', 'rest_slice', 'rest_stack');
DELETE FROM promotion_targets WHERE legacy_restaurant_id IN ('rest_koi', 'rest_slice', 'rest_stack');
DELETE FROM cart_lines WHERE restaurant_id IN ('rest_koi', 'rest_slice', 'rest_stack');
DELETE FROM order_lines WHERE order_id IN (SELECT id FROM orders WHERE restaurant_id IN ('rest_koi', 'rest_slice', 'rest_stack'));
DELETE FROM orders WHERE restaurant_id IN ('rest_koi', 'rest_slice', 'rest_stack');
DELETE FROM offers WHERE restaurant_id IN ('rest_koi', 'rest_slice', 'rest_stack');
DELETE FROM menu_items WHERE restaurant_id IN ('rest_koi', 'rest_slice', 'rest_stack');
DELETE FROM restaurant_hours WHERE restaurant_id IN ('rest_koi', 'rest_slice', 'rest_stack');
DELETE FROM restaurant_cuisines WHERE restaurant_id IN ('rest_koi', 'rest_slice', 'rest_stack');
DELETE FROM restaurant_categories WHERE restaurant_id IN ('rest_koi', 'rest_slice', 'rest_stack');
DELETE FROM restaurants WHERE id IN ('rest_koi', 'rest_slice', 'rest_stack');

INSERT INTO restaurants
  (id, name, latitude, longitude, address, city, region, postal_code, rating_average, rating_count, phone, app_url)
VALUES
  ('rest_unbf_tims', 'Tim Hortons - UNB Student Union Building', 45.9458, -66.6414, '21 Pacey Dr, UNB Student Union Building', 'Fredericton', 'NB', 'E3B 5A3', 0, 0, '506-458-5401', 'https://www.timhortons.ca/app'),
  ('rest_cellar', 'The Cellar Pub', 45.9450, -66.6410, '21 Pacey Dr', 'Fredericton', 'NB', 'E3B 5A3', 0, 0, '506-451-1009', 'https://cellarpub.ca/'),
  ('rest_unbf_catertrax', 'UNB Fredericton Food Services', 45.9458, -66.6414, '19 Bailey Dr', 'Fredericton', 'NB', 'E3B 5A3', 0, 0, '506-458-2898', 'https://unb-fredericton.catertrax.com/'),
  ('rest_rocket_burger', 'Rocket Burger', 45.9636, -66.6419, '349 King St', 'Fredericton', 'NB', 'E3B 1E4', 0, 0, '506-206-6636', 'https://www.rocketburger.ca/'),
  ('rest_stlouis', 'St. Louis Bar & Grill', 45.9639, -66.6440, '280 King St', 'Fredericton', 'NB', 'E3B 1G8', 0, 0, '506-455-1025', 'https://locations.stlouiswings.com/fredericton'),
  ('rest_moco', 'MoCo Downtown', 45.9507, -66.6420, '100 Regent St', 'Fredericton', 'NB', 'E3B 3W4', 0, 0, '506-455-6626', 'https://mocodowntown.ca/'),
  ('rest_540_north', '540 North', 45.9670, -66.6350, '912 Union St', 'Fredericton', 'NB', 'E3A 3P7', 0, 0, '506-429-5500', 'https://www.540kitchenandbar.com/contact-1'),
  ('rest_diamond_house', 'Diamond House Chinese Restaurant', 45.8372, -66.4820, '261 Restigouche Rd', 'Oromocto', 'NB', 'E2V 2H1', 0, 0, '506-357-8811', 'https://diamondhousechineserestaurantnb.com/'),
  ('rest_pizza_delight_oromocto', 'Pizza Delight - Oromocto Mall', 45.8350, -66.4800, '1198 Onondaga St, Oromocto Mall', 'Oromocto', 'NB', 'E2V 1B8', 0, 0, '506-357-3359', 'https://www.pizzadelight.com/oromocto-mall'),
  ('rest_spicy_roots', 'Spicy Roots Bistro', 45.8360, -66.4830, '286 Restigouche Rd E2', 'Oromocto', 'NB', 'E2V 2H5', 0, 0, '506-700-2179', 'https://spicyrootsbistro.com/')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude,
  address = EXCLUDED.address, city = EXCLUDED.city, region = EXCLUDED.region,
  postal_code = EXCLUDED.postal_code, phone = EXCLUDED.phone, app_url = EXCLUDED.app_url,
  updated_at = now();

UPDATE restaurants SET image_url = CASE id
  WHEN 'rest_unbf_tims' THEN 'https://ubdining.com/sites/default/files/inline-images/timsSU-inline1.jpg'
  WHEN 'rest_cellar' THEN 'https://img1.wsimg.com/isteam/ip/ea10a889-6b1f-4b85-9815-80e916c7fd1e/D6DF81F6-03C1-4DB8-B6FA-CF79F6895868.jpeg'
  WHEN 'rest_unbf_catertrax' THEN 'https://crm.catertrax.com/publisher_images/Compass/OOEChartwells/chartwellshero.jpg'
  WHEN 'rest_rocket_burger' THEN 'https://www.rocketburger.ca/wp-content/uploads/2019/10/RocketBurger-FB-Image.jpg'
  WHEN 'rest_stlouis' THEN 'https://www.stlouiswings.com/wp-content/uploads/2026/07/Wingsanity-2026-Home-Page-Banner_Banner-scaled-1.png'
  WHEN 'rest_moco' THEN 'https://img1.wsimg.com/isteam/ip/9efcde0b-c703-44a7-bf36-319ee3727d8c/DSC_1920.jpg'
  WHEN 'rest_540_north' THEN 'http://static1.squarespace.com/static/5f64ae7a63c0d6377c81f157/t/5f997447bc33106bd9dc7b2d/1603892299909/540-Social-Sharing-Image.jpg?format=1500w'
  WHEN 'rest_diamond_house' THEN 'https://d2gqo3h0psesgi.cloudfront.net/auto/diamond-house-chinese-restaurant-6qbltdp3-banner.jpg'
  WHEN 'rest_pizza_delight_oromocto' THEN 'https://www.pizzadelight.com/resources/assets/images/restaurant/default-banner-restaurant.jpg'
  WHEN 'rest_spicy_roots' THEN 'https://d2gqo3h0psesgi.cloudfront.net/auto/spicy-roots-bistro-87cb2jzf-banner.jpg'
  ELSE image_url END,
  updated_at = now()
WHERE id LIKE 'rest_%';

INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES
  ('rest_unbf_tims', 'cat_food'), ('rest_cellar', 'cat_food'), ('rest_unbf_catertrax', 'cat_food'),
  ('rest_rocket_burger', 'cat_food'), ('rest_stlouis', 'cat_food'), ('rest_moco', 'cat_food'),
  ('rest_540_north', 'cat_food'), ('rest_diamond_house', 'cat_food'),
  ('rest_pizza_delight_oromocto', 'cat_food'), ('rest_spicy_roots', 'cat_food')
ON CONFLICT DO NOTHING;

INSERT INTO restaurant_cuisines (restaurant_id, cuisine_id) VALUES
  ('rest_unbf_tims', 'cui_coffee'), ('rest_cellar', 'cui_burgers'), ('rest_unbf_catertrax', 'cui_sandwiches'),
  ('rest_rocket_burger', 'cui_burgers'), ('rest_stlouis', 'cui_wings'), ('rest_moco', 'cui_pizza'),
  ('rest_540_north', 'cui_burgers'), ('rest_diamond_house', 'cui_chinese'),
  ('rest_pizza_delight_oromocto', 'cui_pizza'), ('rest_spicy_roots', 'cui_indian')
ON CONFLICT DO NOTHING;

-- Hours copied from the cited official location pages where a weekly schedule was published.
DELETE FROM restaurant_hours WHERE restaurant_id IN ('rest_stlouis', 'rest_diamond_house', 'rest_pizza_delight_oromocto', 'rest_spicy_roots');
INSERT INTO restaurant_hours (restaurant_id, service, day_of_week, opens, closes)
SELECT h.restaurant_id, h.service, d.day, h.opens, h.closes
FROM (VALUES
  ('rest_stlouis', 'store', ARRAY[0], '11:30', '00:00'),
  ('rest_stlouis', 'store', ARRAY[1], '11:30', '00:00'),
  ('rest_stlouis', 'store', ARRAY[2,3,4,5,6], '11:30', '01:00'),
  ('rest_diamond_house', 'store', ARRAY[0], '13:30', '19:30'),
  ('rest_diamond_house', 'store', ARRAY[1,2,3,4,5,6], '11:30', '19:30'),
  ('rest_pizza_delight_oromocto', 'store', ARRAY[0,1,2,3,4,5,6], '11:30', '21:00'),
  ('rest_pizza_delight_oromocto', 'delivery', ARRAY[0,1,2,3,4,5,6], '11:30', '21:00'),
  ('rest_spicy_roots', 'store', ARRAY[0,1,3,4,5,6], '08:00', '21:00')
) AS h(restaurant_id, service, days, opens, closes)
CROSS JOIN LATERAL unnest(h.days) AS d(day)
ON CONFLICT DO NOTHING;

-- Representative items keep the demo browseable; these are not a live menu import.
INSERT INTO menu_items (id, restaurant_id, name, description, section, image_url) VALUES
  ('item_unbf_tims_coffee', 'rest_unbf_tims', 'Coffee', 'Brewed coffee.', 'Beverages', ''),
  ('item_cellar_burger', 'rest_cellar', 'Cellar Burger', 'Pub burger; confirm current menu and price.', 'Food', ''),
  ('item_catertrax_lunch', 'rest_unbf_catertrax', 'Campus lunch special', 'Rotating campus food-service item.', 'Daily menu', ''),
  ('item_rocket_burger', 'rest_rocket_burger', 'Rocket Burger', 'Signature burger.', 'Burgers', ''),
  ('item_stlouis_wings', 'rest_stlouis', 'Wings', 'Sauced chicken wings.', 'Wings', ''),
  ('item_moco_pizza', 'rest_moco', 'Detroit-style pizza', 'Handmade pizza; confirm current menu.', 'Pizza', ''),
  ('item_540_burger', 'rest_540_north', '540 burger', 'House burger; confirm current menu.', 'Mains', ''),
  ('item_diamond_combo', 'rest_diamond_house', 'Chinese combination plate', 'Chinese-Canadian favourite.', 'Mains', ''),
  ('item_pizza_delight', 'rest_pizza_delight_oromocto', 'Pizza', 'Pizza Delight menu item.', 'Pizza', ''),
  ('item_spicy_roots_curry', 'rest_spicy_roots', 'Indian curry', 'Rotating Indian curry selection.', 'Mains', '')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description, section = EXCLUDED.section;

-- Demo-only prices for visual comparison. Replace with observed quotes before claiming price accuracy.
INSERT INTO offers (id, restaurant_id, provider_id, menu_item_id, amount_cents, currency, estimated_minutes) VALUES
  ('off_unbf_tims_skip', 'rest_unbf_tims', 'prov_skip', 'item_unbf_tims_coffee', 299, 'CAD', 15),
  ('off_cellar_skip', 'rest_cellar', 'prov_skip', 'item_cellar_burger', 1499, 'CAD', 25),
  ('off_rocket_skip', 'rest_rocket_burger', 'prov_skip', 'item_rocket_burger', 1699, 'CAD', 30),
  ('off_stlouis_doordash', 'rest_stlouis', 'prov_doordash', 'item_stlouis_wings', 1799, 'CAD', 35),
  ('off_moco_skip', 'rest_moco', 'prov_skip', 'item_moco_pizza', 2199, 'CAD', 35),
  ('off_diamond_skip', 'rest_diamond_house', 'prov_skip', 'item_diamond_combo', 1699, 'CAD', 40),
  ('off_pizza_delight_skip', 'rest_pizza_delight_oromocto', 'prov_skip', 'item_pizza_delight', 1999, 'CAD', 40),
  ('off_spicy_roots_skip', 'rest_spicy_roots', 'prov_skip', 'item_spicy_roots_curry', 1899, 'CAD', 45)
ON CONFLICT (id) DO UPDATE SET amount_cents = EXCLUDED.amount_cents, estimated_minutes = EXCLUDED.estimated_minutes;
