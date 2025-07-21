-- CREATE DATABASE
CREATE DATABASE ecommercewebsite;

-- ****************************************************************************
-- ************************** TABLES DEFINITION *******************************
-- ****************************************************************************

CREATE TABLE manufacturers (
    manufacturer_id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE departments (
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
    brand_id INT,
    manufacturer_id INT,
    availability TEXT,
    updated_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE product_details (
    asin VARCHAR(20) PRIMARY KEY,
    description TEXT,
    model_number TEXT,
    date_first_available DATE,
    rating NUMERIC(2, 1),
    item_weight TEXT,
    product_dimensions TEXT,
    department_id INT,
    ingredients TEXT,
    features TEXT[]
);

CREATE TABLE rankings (
    asin VARCHAR(20) PRIMARY KEY,
    root_bs_rank INTEGER,
    bs_rank INTEGER,
    subcategory_rank JSONB,
    badge TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP
);

CREATE TABLE pricing (
    asin VARCHAR(20) PRIMARY KEY,
    initial_price NUMERIC(10, 2),
    final_price NUMERIC(10, 2),
    currency VARCHAR(10),
    discount TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP
);

CREATE TABLE media (
    asin VARCHAR(20) PRIMARY KEY,
    image_url TEXT,
    images TEXT[],
    images_count INTEGER
);

CREATE TABLE top_review (
    asin VARCHAR(20) PRIMARY KEY,
    top_review TEXT
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE product_categories (
    asin VARCHAR(20),
    category_id INTEGER,
    PRIMARY KEY (asin, category_id)
);

CREATE TABLE variations (
    asin VARCHAR(20) PRIMARY KEY,
    variations JSONB
);

CREATE TABLE sellers (
    seller_id TEXT PRIMARY KEY,
    seller_name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP
);

CREATE TABLE seller_detail (
    seller_id TEXT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT,
    contact_person VARCHAR(255),
    bio TEXT,
    phone VARCHAR(20),
    profile_picture TEXT,
    login_method VARCHAR(20) DEFAULT 'email',
    status BOOLEAN NOT NULL DEFAULT true,
    registration_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE seller_locations (
    seller_id TEXT PRIMARY KEY,
    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    zipcode VARCHAR(10),
    address_line1 TEXT,
    address_line2 TEXT
);

CREATE TABLE product_sellers (
    asin VARCHAR(20),
    seller_id TEXT,
    PRIMARY KEY (asin, seller_id)
);

CREATE TABLE delivery_options (
    delivery_id SERIAL PRIMARY KEY,
    option_name VARCHAR(50) UNIQUE NOT NULL,
    delivery_days INTEGER,
    price NUMERIC(10, 2) NOT NULL
);

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customer_detail (
    customer_id INT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    birth_date DATE,
    gender VARCHAR(10),
    country VARCHAR(100),
    profile_picture TEXT,
    status BOOLEAN NOT NULL DEFAULT true,
    login_method VARCHAR(20) DEFAULT 'email',
    registration_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE customer_locations (
    customer_id INT,
    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    zipcode VARCHAR(10),
    address_line1 TEXT,
    address_line2 TEXT
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    seller_id TEXT NOT NULL,
    delivery_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    status VARCHAR(30) NOT NULL
);

CREATE TABLE ordered_items (
    order_id INT NOT NULL,
    asin VARCHAR(20) NOT NULL,
    quantity INT NOT NULL,
    added_at TIMESTAMP DEFAULT NOW(),
    last_update TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (order_id, asin)
);

CREATE TABLE wishlists (
    wishlist_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE wishlist_items (
    wishlist_id INT NOT NULL,
    asin VARCHAR(20) NOT NULL,
    added_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (wishlist_id, asin)
);

CREATE TABLE customer_reviews (
    review_id SERIAL PRIMARY KEY,
    asin VARCHAR(20),
    customer_id INT,
    rating NUMERIC(2,1),
    comment TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_enquiries (
    enquiry_id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    gender VARCHAR(10),
    country VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    comment TEXT,
    badge VARCHAR(50) NOT NULL,
    enquiry_date DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE seller_requests (
    request_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    request_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
);

CREATE TABLE admin (
    admin_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    hashed_password TEXT NOT NULL
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
