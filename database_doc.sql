-- Create database separately:
CREATE DATABASE ecommercewebsite;
-- Connect with: \c ecommercewebsite

-- Convert from raw data of CSV file to PostgreSQL data form
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
    reviews_count INTEGER,
    categories TEXT,
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
    plus_content TEXT,
    top_review TEXT,
    variations JSONB,
    features TEXT[],
    parent_asin VARCHAR(20),
    input_asin VARCHAR(20),
    ingredients TEXT,
    bought_past_month INTEGER,
    bs_rank INTEGER,
    badge TEXT,
    subcategory_rank TEXT,
    images TEXT[]
);

-- Open terminal and connect to the 'ecommercewebsite' database
-- psql -U postgres -d ecommercewebsite

-- Then issue this command to extract data from the .csv file to the 'rawData' table, NOTE: add your own path to the 'data-products.csv'
-- \copy rawData(timestamp, title, seller_name, brand, description, initial_price, final_price, currency, availability, reviews_count, categories, asin, root_bs_rank, image_url, item_weight, rating, product_dimensions, seller_id, date_first_available, discount, model_number, manufacturer, department, plus_content, top_review, variations, features, parent_asin, input_asin, ingredients, bought_past_month, bs_rank, badge, subcategory_rank, images) FROM '/Users/macbook/Desktop/E-commerce_Database/data-products.csv' DELIMITER ',' CSV HEADER; 

-- Product
CREATE TABLE manufacturers (
    manufacturer_id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE departments(
    department_id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
)

CREATE TABLE brands (
    brand_id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE products (
    asin VARCHAR(20) PRIMARY KEY,
    title TEXT NOT NULL,
    brand_id INT REFERENCES brands(brand_id) ON DELETE SET NULL,
    manufacturer_id INT REFERENCES manufacturers(manufacturer_id) ON DELETE SET NULL,
    availability TEXT
);

CREATE TABLE product_details (
    asin VARCHAR(20) PRIMARY KEY REFERENCES products(asin) ON DELETE CASCADE,
    description TEXT,
    model_number TEXT,
    date_first_available DATE,
    rating NUMERIC(2, 1),
    item_weight TEXT,
    product_dimensions TEXT,
    currency VARCHAR(10),
    department_id INT REFERENCES department(department_id) ON DELETE SET NULL,
    parent_asin VARCHAR(20) REFERENCES products(asin) ON DELETE SET NULL,
    input_asin VARCHAR(20) REFERENCES products(asin) ON DELETE SET NULL,
    ingredients TEXT,
    CONSTRAINT rating_range CHECK (rating >= 0 AND rating <= 5)
);

CREATE TABLE rankings (
    ranking_id SERIAL PRIMARY KEY,
    asin VARCHAR(20) REFERENCES products(asin) ON DELETE CASCADE,
    root_bs_rank INTEGER,
    bs_rank INTEGER,
    subcategory_rank TEXT,
    badge TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP
);

CREATE TABLE pricing (
    asin VARCHAR(20) PRIMARY KEY REFERENCES products(asin) ON DELETE CASCADE,
    initial_price NUMERIC(10, 2),
    final_price NUMERIC(10, 2),
    discount TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP
);

CREATE TABLE sellers (
    seller_id TEXT PRIMARY KEY,
    seller_name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP
);

CREATE TABLE product_sellers (
    asin VARCHAR(20) REFERENCES products(asin) ON DELETE CASCADE,
    seller_id TEXT REFERENCES sellers(seller_id) ON DELETE CASCADE,
    PRIMARY KEY (asin, seller_id),
    CONSTRAINT unique_product_seller_delivery UNIQUE (asin, seller_id)
);

CREATE TABLE media (
    asin VARCHAR(20) PRIMARY KEY REFERENCES products(asin) ON DELETE CASCADE,
    image_url TEXT,
    images TEXT[],  
    images_count INTEGER,
    plus_content TEXT
);

CREATE TABLE reviews (
    asin VARCHAR(20) PRIMARY KEY REFERENCES products(asin) ON DELETE CASCADE,
    reviews_count INTEGER,
    answered_questions INTEGER,
    top_review TEXT,
    bought_past_month INTEGER
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE product_categories (
    asin VARCHAR(20) REFERENCES products(asin) ON DELETE CASCADE,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE CASCADE,
    PRIMARY KEY (asin, category_id)
);

CREATE TABLE features (
    feature_id SERIAL PRIMARY KEY,
    asin VARCHAR(20) REFERENCES products(asin) ON DELETE CASCADE,
    feature TEXT[]
);

CREATE TABLE variations (
    variation_id SERIAL PRIMARY KEY,
    asin VARCHAR(20) REFERENCES products(asin) ON DELETE CASCADE,
    variation JSONB
);

CREATE TABLE delivery_options (
    delivery_id SERIAL PRIMARY KEY,
    option_name VARCHAR(50) UNIQUE NOT NULL,
    delivery_days INTEGER,
    price NUMERIC(10, 2) NOT NULL
);


-- Customer
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,             
    username VARCHAR(50) UNIQUE NOT NULL, 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customer_detail (
    customer_id INT PRIMARY KEY REFERENCES customers(customer_id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,       
    password_hash TEXT,                       
    first_name VARCHAR(100),                     
    last_name VARCHAR(100),                    
    phone VARCHAR(20),                           
    birth_date DATE,                             
    gender VARCHAR(10),                          
    country VARCHAR(100),
    profile_picture TEXT, --Image url                    
    login_method VARCHAR(20) DEFAULT 'email'     -- 'email', 'google', 'facebook', etc.
);

CREATE TABLE customer_locations(
    customer_id INT REFERENCES customer_detail(customer_id) ON DELETE CASCADE,
    city VARCHAR(100),
    state VARCHAR(100),
    zipcode VARCHAR(10),
    address_line1 TEXT,                         
    address_line2 TEXT
);


-- Customer order
CREATE TABLE orders (
    order_id INT NOT NULL SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    seller_id INT NOT NULL REFERENCES sellers(seller_id) ON DELETE SET NULL,
    delivery_id INT NOT NULL REFERENCES delivery_options(delivery_id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE ordered_items (
    order_id INT NOT NULL REFERENCES orders(order_id),
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    added_at TIMESTAMP DEFAULT NOW(),
    last_update TIMESTAMP DEFAULT NOW()
    PRIMARY KEY (order_id, product_id)
);

-- Wishlist
CREATE TABLE wishlists (
    wishlist_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE wishlist_items (
    wishlist_id INT NOT NULL REFERENCES wishlists(wishlist_id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (wishlist_id, product_id)
);


CREATE INDEX idx_variations_asin ON variations(asin);
CREATE INDEX idx_product_categories_category_id ON product_categories(category_id);
CREATE INDEX idx_rankings_asin ON rankings(asin);

-- Insert the associated attribute to each table

-- 1. Insert into manufacturers
INSERT INTO manufacturers (name)
SELECT DISTINCT manufacturer
FROM rawData
WHERE manufacturer IS NOT NULL
  AND manufacturer <> ''
  AND manufacturer NOT IN (SELECT name FROM manufacturers);

-- 2. Insert into brands
INSERT INTO brands (name)
SELECT DISTINCT brand
FROM rawData
WHERE brand IS NOT NULL
  AND brand <> ''
  AND brand NOT IN (SELECT name FROM brands);

-- 3. Insert into sellers
INSERT INTO sellers (seller_id, seller_name)
SELECT DISTINCT seller_id, seller_name
FROM rawData
WHERE seller_id IS NOT NULL
  AND seller_name IS NOT NULL
  AND seller_id <> ''
  AND seller_name <> ''
ON CONFLICT (seller_id) DO NOTHING;


-- 4. Insert into products
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

-- 5. Insert into product_details
INSERT INTO product_details (
    asin, description, model_number, department, date_first_available,
    rating, item_weight, product_dimensions, currency,
    parent_asin, input_asin, ingredients
)
SELECT
    r.asin, r.description, r.model_number, r.department, r.date_first_available,
    r.rating, r.item_weight, r.product_dimensions, r.currency,
    r.parent_asin, r.input_asin, r.ingredients
FROM rawData r
WHERE r.asin IN (SELECT asin FROM products)
  AND (r.parent_asin IS NULL OR r.parent_asin IN (SELECT asin FROM products))
  AND (r.input_asin IS NULL OR r.input_asin IN (SELECT asin FROM products));


-- 6. Insert into pricing
INSERT INTO pricing (asin, initial_price, final_price, discount)
SELECT asin, initial_price, final_price, discount
FROM rawData
WHERE asin IN (SELECT asin FROM products);

-- 7. Insert into rankings
INSERT INTO rankings (asin, root_bs_rank, bs_rank, subcategory_rank, badge)
SELECT asin, root_bs_rank, bs_rank, subcategory_rank, badge
FROM rawData
WHERE asin IN (SELECT asin FROM products);

-- 8. Insert into product_sellers
INSERT INTO product_sellers (asin, seller_id)
SELECT DISTINCT asin, seller_id
FROM rawData
WHERE asin IN (SELECT asin FROM products)
  AND seller_id IN (SELECT seller_id FROM sellers);

-- 9. Insert into media
INSERT INTO media (asin, image_url, images, images_count, plus_content)
SELECT asin, image_url, images, CARDINALITY(images), plus_content
FROM rawData
WHERE asin IN (SELECT asin FROM products);

-- 10. Insert into reviews
INSERT INTO reviews (asin, reviews_count, answered_questions, top_review, bought_past_month)
SELECT asin, reviews_count, NULL, top_review, bought_past_month
FROM rawData
WHERE asin IN (SELECT asin FROM products);

-- 11. Insert into features
INSERT INTO features (asin, feature)
SELECT asin, features
FROM rawData
WHERE features IS NOT NULL AND asin IN (SELECT asin FROM products);

-- 12. Insert into variations
INSERT INTO variations (asin, variation)
SELECT asin, variations
FROM rawData
WHERE variations IS NOT NULL AND asin IN (SELECT asin FROM products);

-- 13. Insert into categories
-- Step A: create temporary table of category names
CREATE TEMP TABLE tmp_categories AS
SELECT DISTINCT TRIM(unnest(string_to_array(categories, ','))) AS name
FROM rawData
WHERE categories IS NOT NULL;

-- Step B: insert new categories
INSERT INTO categories (name)
SELECT name
FROM tmp_categories
WHERE name NOT IN (SELECT name FROM categories);

-- Step C: insert into product_categories
INSERT INTO product_categories (asin, category_id)
SELECT DISTINCT r.asin, c.category_id
FROM rawData r,
     unnest(string_to_array(r.categories, ',')) AS category_name
JOIN categories c ON TRIM(category_name) = c.name
WHERE r.asin IN (SELECT asin FROM products);