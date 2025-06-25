-- Create database separately:
DROP DATABASE IF EXISTS ecommercewebsite;
CREATE DATABASE ecommercewebsite;
-- Connect with: \c ecommercewebsite

-- Convert from raw data of CSV file to PostgreSQL data form
DROP TABLE IF EXISTS rawData;

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
);

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
    department_id INT REFERENCES departments(department_id) ON DELETE SET NULL,
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
    currency VARCHAR(10),
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
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    seller_id TEXT NOT NULL REFERENCES sellers(seller_id) ON DELETE SET NULL,
    delivery_id INT NOT NULL REFERENCES delivery_options(delivery_id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE ordered_items (
    order_id INT NOT NULL REFERENCES orders(order_id),
    asin VARCHAR(20) NOT NULL REFERENCES products(asin),
    quantity INT NOT NULL CHECK (quantity > 0),
    added_at TIMESTAMP DEFAULT NOW(),
    last_update TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (order_id, asin)
);

-- Wishlist
CREATE TABLE wishlists (
    wishlist_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE wishlist_items (
    wishlist_id INT NOT NULL REFERENCES wishlists(wishlist_id) ON DELETE CASCADE,
    asin VARCHAR(20) NOT NULL REFERENCES products(asin) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (wishlist_id, asin)
);

CREATE TABLE customer_reviews (
    review_id SERIAL PRIMARY KEY,
    asin VARCHAR(20) REFERENCES products(asin) ON DELETE CASCADE,
    customer_id INT REFERENCES customers(customer_id),
    rating NUMERIC(2,1) CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

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

-- 4. Insert into departments
INSERT INTO departments (name)
SELECT DISTINCT department
FROM rawData
WHERE department IS NOT NULL
  AND department <> ''
  AND department NOT IN (SELECT name FROM departments);

-- 5. Insert into products
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

-- 6. Insert into product_details
INSERT INTO product_details (
    asin, description, model_number, department_id, date_first_available, -- Changed to department_id
    rating, item_weight, product_dimensions,
    parent_asin, input_asin, ingredients
)
SELECT
    r.asin, r.description, r.model_number, d.department_id, r.date_first_available, -- Changed to d.department_id
    r.rating, r.item_weight, r.product_dimensions,
    r.parent_asin, r.input_asin, r.ingredients
FROM rawData r
LEFT JOIN departments d ON r.department = d.name -- Join with departments table
WHERE r.asin IN (SELECT asin FROM products)
  AND (r.parent_asin IS NULL OR r.parent_asin IN (SELECT asin FROM products))
  AND (r.input_asin IS NULL OR r.input_asin IN (SELECT asin FROM products));

-- 7. Insert into pricing
INSERT INTO pricing (asin, initial_price, final_price, currency, discount) -- Added currency
SELECT asin, initial_price, final_price, currency, discount
FROM rawData
WHERE asin IN (SELECT asin FROM products);

-- 8. Insert into rankings
INSERT INTO rankings (asin, root_bs_rank, bs_rank, subcategory_rank, badge)
SELECT asin, root_bs_rank, bs_rank, subcategory_rank, badge
FROM rawData
WHERE asin IN (SELECT asin FROM products);

-- 9. Insert into product_sellers
INSERT INTO product_sellers (asin, seller_id)
SELECT DISTINCT asin, seller_id
FROM rawData
WHERE asin IN (SELECT asin FROM products)
  AND seller_id IN (SELECT seller_id FROM sellers);

-- 10. Insert into media
INSERT INTO media (asin, image_url, images, images_count, plus_content)
SELECT asin, image_url, images, CARDINALITY(images), plus_content
FROM rawData
WHERE asin IN (SELECT asin FROM products);

-- 11. Insert into reviews
INSERT INTO reviews (asin, reviews_count, answered_questions, top_review, bought_past_month)
SELECT asin, reviews_count, NULL, top_review, bought_past_month
FROM rawData
WHERE asin IN (SELECT asin FROM products);

-- 12. Insert into features
INSERT INTO features (asin, feature)
SELECT asin, features
FROM rawData
WHERE features IS NOT NULL AND asin IN (SELECT asin FROM products);

-- 13. Insert into variations
INSERT INTO variations (asin, variation)
SELECT asin, variations
FROM rawData
WHERE variations IS NOT NULL AND asin IN (SELECT asin FROM products);

-- 14. Insert into categories
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

-- ==========================================================
--                        PROCEDURES
-- ==========================================================
CREATE OR REPLACE PROCEDURE add_new_product(
    p_asin VARCHAR,
    p_title TEXT,
    p_brand TEXT,
    p_manufacturer TEXT,
    p_price NUMERIC,
    p_rating NUMERIC,
    p_currency VARCHAR,
    p_description TEXT,
    p_department TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    brand_id_val INT;
    manufacturer_id_val INT;
    department_id_val INT;
BEGIN
    -- Get or insert brand
    SELECT brand_id INTO brand_id_val FROM brands WHERE name = p_brand;
    IF brand_id_val IS NULL THEN
        INSERT INTO brands(name) VALUES (p_brand) RETURNING brand_id INTO brand_id_val;
    END IF;

    -- Get or insert manufacturer
    SELECT manufacturer_id INTO manufacturer_id_val FROM manufacturers WHERE name = p_manufacturer;
    IF manufacturer_id_val IS NULL THEN
        INSERT INTO manufacturers(name) VALUES (p_manufacturer) RETURNING manufacturer_id INTO manufacturer_id_val;
    END IF;

    -- Get or insert department
    IF p_department IS NOT NULL THEN
        SELECT department_id INTO department_id_val FROM departments WHERE name = p_department;
        IF department_id_val IS NULL THEN
            INSERT INTO departments(name) VALUES (p_department) RETURNING department_id INTO department_id_val;
        END IF;
    END IF;

    -- Insert into products
    INSERT INTO products(asin, title, brand_id, manufacturer_id)
    VALUES (p_asin, p_title, brand_id_val, manufacturer_id_val);

    -- Insert into pricing
    INSERT INTO pricing(asin, final_price, currency)
    VALUES (p_asin, p_price, p_currency);

    -- Insert into product_details
    INSERT INTO product_details(asin, rating, description, department_id)
    VALUES (p_asin, p_rating, p_description, department_id_val);
END;
$$;

CREATE OR REPLACE PROCEDURE place_order(
    IN p_customer_id INT,
    IN p_seller_id TEXT,
    IN p_delivery_id INT,
    IN p_items JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    new_order_id INT;
    item JSONB;
BEGIN
    INSERT INTO orders (customer_id, seller_id, delivery_id)
    VALUES (p_customer_id, p_seller_id, p_delivery_id)
    RETURNING order_id INTO new_order_id;

    FOR item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        INSERT INTO ordered_items (order_id, asin, quantity)
        VALUES (
            new_order_id,
            item->>'asin',
            (item->>'quantity')::INT
        );
    END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE update_product_price(
    p_asin VARCHAR,
    p_new_price NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE pricing
    SET final_price = p_new_price,
        updated_at = NOW()
    WHERE asin = p_asin;
END;
$$;

CREATE OR REPLACE PROCEDURE add_customer_review(
    p_asin VARCHAR,
    p_customer_id INT,
    p_rating NUMERIC,
    p_comment TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO customer_reviews (asin, customer_id, rating, comment)
    VALUES (p_asin, p_customer_id, p_rating, p_comment);
END;
$$;

-- ==========================================================
--                        TRIGGERS
-- ==========================================================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_products
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_update_sellers
BEFORE UPDATE ON sellers
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_update_pricing_timestamp
BEFORE UPDATE ON pricing
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_update_rankings_timestamp
BEFORE UPDATE ON rankings
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_update_customers_timestamp
BEFORE UPDATE ON customers
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();


-- ==========================================================
--                        FUNCTIONS
-- ==========================================================
CREATE OR REPLACE FUNCTION get_top_selling_products(limit_count INT)
RETURNS TABLE (
    asin VARCHAR,
    total_quantity BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT asin, SUM(quantity) AS total_quantity
    FROM ordered_items
    GROUP BY asin
    ORDER BY total_quantity DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_product_summary(p_asin TEXT)
RETURNS TABLE (
    title TEXT,
    brand TEXT,
    manufacturer TEXT,
    price NUMERIC,
    rating NUMERIC,
    review_count INT,
    description TEXT,
    image_url TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.title,
        b.name,
        m.name,
        pr.final_price,
        pd.rating,
        r.reviews_count,
        pd.description,
        md.image_url 
    FROM products p
    LEFT JOIN brands b ON p.brand_id = b.brand_id
    LEFT JOIN manufacturers m ON p.manufacturer_id = m.manufacturer_id
    LEFT JOIN pricing pr ON p.asin = pr.asin
    LEFT JOIN product_details pd ON p.asin = pd.asin
    LEFT JOIN reviews r ON p.asin = r.asin
    LEFT JOIN media md ON p.asin = md.asin
    WHERE p.asin = p_asin;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_customer_order_history(p_customer_id INT)
RETURNS TABLE (
    order_id INT,
    order_date TIMESTAMP,
    seller_name TEXT,
    delivery_option TEXT,
    total_items BIGINT 
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.order_id,
        o.created_at AS order_date,
        s.seller_name,
        do.option_name AS delivery_option,
        SUM(oi.quantity) AS total_items
    FROM orders o
    JOIN sellers s ON o.seller_id = s.seller_id
    JOIN delivery_options do ON o.delivery_id = do.delivery_id
    JOIN ordered_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = p_customer_id
    GROUP BY o.order_id, o.created_at, s.seller_name, do.option_name
    ORDER BY o.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_products_by_category(p_category_name TEXT)
RETURNS TABLE (
    asin VARCHAR,
    title TEXT,
    brand_name TEXT,
    final_price NUMERIC,
    rating NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.asin,
        p.title,
        b.name AS brand_name,
        pr.final_price,
        pd.rating
    FROM products p
    JOIN product_categories pc ON p.asin = pc.asin
    JOIN categories c ON pc.category_id = c.category_id
    LEFT JOIN brands b ON p.brand_id = b.brand_id
    LEFT JOIN pricing pr ON p.asin = pr.asin
    LEFT JOIN product_details pd ON p.asin = pd.asin
    WHERE c.name ILIKE p_category_name;
END;
$$ LANGUAGE plpgsql;


-- ==========================================================
--                        VIEWS
-- ==========================================================
CREATE OR REPLACE VIEW top_5_expensive_products AS
SELECT
    p.title,
    b.name AS brand_name,
    m.name AS manufacturer_name,
    pr.final_price,
    pr.currency
FROM products p
JOIN pricing pr ON p.asin = pr.asin
LEFT JOIN brands b ON p.brand_id = b.brand_id
LEFT JOIN manufacturers m ON p.manufacturer_id = m.manufacturer_id
ORDER BY pr.final_price DESC
LIMIT 5;

CREATE OR REPLACE VIEW products_with_no_reviews AS
SELECT
    p.asin,
    p.title,
    p.availability,
    pr.final_price
FROM products p
LEFT JOIN reviews r ON p.asin = r.asin
LEFT JOIN pricing pr ON p.asin = pr.asin
WHERE r.reviews_count IS NULL OR r.reviews_count = 0;

-- ==========================================================
--                        INDEXS
-- ==========================================================
CREATE INDEX idx_variations_asin ON variations(asin);
CREATE INDEX idx_product_categories_category_id ON product_categories(category_id);
CREATE INDEX idx_rankings_asin ON rankings(asin);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_ordered_items_asin ON ordered_items(asin);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_products_asin ON products(asin);
CREATE INDEX idx_product_sellers_seller_id ON product_sellers(seller_id);
CREATE INDEX idx_products_brand_id ON products(brand_id);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_products_title ON products(title);
CREATE INDEX idx_pricing_final_price ON pricing(final_price DESC);
CREATE INDEX idx_customer_detail_email ON customer_detail(email);
CREATE INDEX idx_categories_name ON categories(name);
CREATE INDEX idx_product_details_department_id ON product_details(department_id);
CREATE INDEX idx_media_asin ON media(asin);
CREATE INDEX idx_customer_reviews_customer_product ON customer_reviews(customer_id, asin);