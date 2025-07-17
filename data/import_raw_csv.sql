-- ****************************************************************************
-- ************* Populating Data from 'data-products.csv'  ********************
-- ****************************************************************************

-- ============================================================================
-- =========================== Raw Data Tables ================================ 
-- ============================================================================
-- (Convert from raw data of CSV file to PostgreSQL data form)

CREATE TABLE rawData (
    timestamp TIMESTAMP,
    title TEXT,
    seller_name TEXT,
    brand TEXT,
    description TEXT,
    initial_price NUMERIC(10, 2),
    final_price NUMERIC(10, 2),
    currency VARCHAR(10),
    availability TEXT,
    categories TEXT[],
    asin VARCHAR(20) PRIMARY KEY,
    root_bs_rank INTEGER,
    image_url TEXT,
    item_weight TEXT,
    rating NUMERIC(2, 1),
    product_dimensions TEXT,
    seller_id TEXT,
    date_first_available DATE,
    discount TEXT,
    model_number TEXT,
    manufacturer TEXT,
    department TEXT,
    top_review TEXT,
    variations JSONB,
    features TEXT[],
    ingredients TEXT,
    bs_rank INTEGER,
    badge TEXT,
    subcategory_rank JSONB,
    images TEXT[]
);

-- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
-- $$$$$$$$$$$$$$$$$$$$$ Import Data From CSV (Optional) $$$$$$$$$$$$$$$$$$$$$$
-- $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
-- Open terminal and connect to the 'ecommercewebsite' database
-- psql -U postgres -d ecommercewebsite

-- Then issue this command to extract data from the .csv file to the 'rawData' table, NOTE: add your own path to the 'data-products.csv'
-- \copy rawData(timestamp, title, seller_name, brand, description, initial_price, final_price, currency, availability, categories, asin, root_bs_rank, image_url, item_weight, rating, product_dimensions, seller_id, date_first_available, discount, model_number, manufacturer, department, top_review, variations, features, ingredients, bs_rank, badge, subcategory_rank, images) FROM '/Users/macbook/Desktop/E-commerce_Database/data/data-products.csv' DELIMITER ',' CSV HEADER;


-- ****************************************************************************
-- ************ Data Insertions from 'data-products.csv' file *****************
-- ****************************************************************************

-- Insert into manufacturers
-- ============================================================================
INSERT INTO manufacturers (name)
SELECT DISTINCT manufacturer
FROM rawData
WHERE manufacturer IS NOT NULL
  AND manufacturer != ''
  AND manufacturer NOT IN (SELECT name FROM manufacturers);

-- Insert into brands
-- ============================================================================
INSERT INTO brands (name)
SELECT DISTINCT brand
FROM rawData
WHERE brand IS NOT NULL
  AND brand != ''
  AND brand NOT IN (SELECT name FROM brands);

-- Insert into sellers
-- ============================================================================
INSERT INTO sellers (seller_id, seller_name)
SELECT DISTINCT seller_id, seller_name
FROM rawData
WHERE seller_id IS NOT NULL
  AND seller_name IS NOT NULL
  AND seller_id != ''
  AND seller_name != ''
ON CONFLICT (seller_id) DO NOTHING;

-- Insert into departments
-- ============================================================================
INSERT INTO departments (name)
SELECT DISTINCT department
FROM rawData
WHERE department IS NOT NULL
  AND department != ''
  AND department NOT IN (SELECT name FROM departments);

-- Insert into products
-- ============================================================================
INSERT INTO products (asin, title, brand_id, manufacturer_id, availability)
SELECT
    r.asin,
    r.title,
    b.brand_id,
    m.manufacturer_id,
    r.availability
FROM rawData r
LEFT JOIN brands b ON r.brand = b.name
LEFT JOIN manufacturers m ON r.manufacturer = m.name
WHERE r.asin NOT IN (SELECT asin FROM products);

-- Insert into product_details
-- ============================================================================
INSERT INTO product_details (
    asin, description, model_number, department_id, date_first_available, 
    rating, item_weight, product_dimensions, features, ingredients
)
SELECT
    r.asin, r.description, r.model_number, d.department_id, r.date_first_available, 
    r.rating, r.item_weight, r.product_dimensions, r.features, r.ingredients
FROM rawData r
LEFT JOIN departments d ON r.department = d.name;

-- Insert into pricing
-- ============================================================================
INSERT INTO pricing (asin, initial_price, final_price, currency, discount)
SELECT asin, initial_price, final_price, currency, discount
FROM rawData
WHERE asin IN (SELECT asin FROM products);

-- Insert into rankings
-- ============================================================================
INSERT INTO rankings (asin, root_bs_rank, bs_rank, subcategory_rank, badge)
SELECT asin, root_bs_rank, bs_rank, subcategory_rank, badge
FROM rawData
WHERE asin IN (SELECT asin FROM products);

-- Insert into product_sellers
-- ============================================================================
INSERT INTO product_sellers (asin, seller_id)
SELECT DISTINCT asin, seller_id
FROM rawData
WHERE asin IN (SELECT asin FROM products)
  AND seller_id IN (SELECT seller_id FROM sellers);

-- Insert into media
-- ============================================================================
INSERT INTO media (asin, image_url, images, images_count)
SELECT asin, image_url, images, CARDINALITY(images)
FROM rawData
WHERE asin IN (SELECT asin FROM products);

-- Insert into reviews
-- ============================================================================
INSERT INTO top_review (asin, top_review)
SELECT asin, top_review
FROM rawData
WHERE asin IN (SELECT asin FROM products);


-- Insert into variations
-- ============================================================================
INSERT INTO variations (asin, variations)
SELECT asin, variations
FROM rawData
WHERE variations IS NOT NULL AND asin IN (SELECT asin FROM products);

-- Insert into categories
-- ============================================================================
-- create temporary table of category names
CREATE TEMP TABLE tmp_categories AS
SELECT DISTINCT TRIM(unnest(categories)) AS name
FROM rawData
WHERE categories IS NOT NULL;

-- Insert new categories
INSERT INTO categories (name)
SELECT name
FROM tmp_categories
WHERE name NOT IN (SELECT name FROM categories);

-- Insert into product_categories
INSERT INTO product_categories (asin, category_id)
SELECT DISTINCT r.asin, c.category_id
FROM rawData r
JOIN LATERAL unnest(r.categories) AS category_name ON true
JOIN categories c ON TRIM(category_name) = c.name
WHERE r.asin IN (SELECT asin FROM products);

