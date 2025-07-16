
-- Create database
DROP DATABASE IF EXISTS ecommercewebsite;
CREATE DATABASE ecommercewebsite;

-- ****************************************************************************
-- *************************** Table Definitions  *****************************
-- ****************************************************************************

-- ============================================================================
-- ======================== Product and Related Tables ======================== 
-- ============================================================================

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
    availability TEXT,
    updated_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
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
    ingredients TEXT,
    features TEXT[],
    CONSTRAINT rating_range CHECK (rating >= 0 AND rating <= 5)
);

CREATE TABLE rankings (
    asin VARCHAR(20) PRIMARY KEY REFERENCES products(asin) ON DELETE CASCADE,
    root_bs_rank INTEGER,
    bs_rank INTEGER,
    subcategory_rank JSONB,
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

CREATE TABLE media (
    asin VARCHAR(20) PRIMARY KEY REFERENCES products(asin) ON DELETE CASCADE,
    image_url TEXT,
    images TEXT[],
    images_count INTEGER
);

CREATE TABLE top_review (
    asin VARCHAR(20) PRIMARY KEY REFERENCES products(asin) ON DELETE CASCADE,
    top_review TEXT
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

CREATE TABLE variations (
    asin VARCHAR(20) PRIMARY KEY REFERENCES products(asin) ON DELETE CASCADE,
    variations JSONB
);


-- ============================================================================
-- ======================== Seller and Related Tables ========================= 
-- ============================================================================

CREATE TABLE sellers (
    seller_id TEXT PRIMARY KEY,
    seller_name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP
);

CREATE TABLE seller_detail (
    seller_id TEXT PRIMARY KEY REFERENCES sellers(seller_id) ON DELETE CASCADE,
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
    seller_id TEXT PRIMARY KEY REFERENCES sellers(seller_id) ON DELETE CASCADE,
    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    zipcode VARCHAR(10),
    address_line1 TEXT,
    address_line2 TEXT,
    CONSTRAINT fk_seller_detail
        FOREIGN KEY (seller_id)
        REFERENCES seller_detail(seller_id)
        ON DELETE CASCADE
);

CREATE TABLE product_sellers (
    asin VARCHAR(20) REFERENCES products(asin) ON DELETE CASCADE,
    seller_id TEXT REFERENCES sellers(seller_id) ON DELETE CASCADE,
    PRIMARY KEY (asin, seller_id),
    CONSTRAINT unique_product_seller_delivery UNIQUE (asin, seller_id)
);


-- ============================================================================
-- ========================== Delivery Option Tables ==========================
-- ============================================================================

CREATE TABLE delivery_options (
    delivery_id SERIAL PRIMARY KEY,
    option_name VARCHAR(50) UNIQUE NOT NULL,
    delivery_days INTEGER,
    price NUMERIC(10, 2) NOT NULL
);


-- ============================================================================
-- ======================= Customer and Related Tables ========================
-- ============================================================================

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
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female')),
    country VARCHAR(100),
    profile_picture TEXT, --Image url
    status BOOLEAN NOT NULL DEFAULT true,
    login_method VARCHAR(20) DEFAULT 'email',     -- 'email', 'google', 'facebook', etc.
    registration_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE customer_locations(
    customer_id INT REFERENCES customer_detail(customer_id) ON DELETE CASCADE,
    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    zipcode VARCHAR(10),
    address_line1 TEXT,
    address_line2 TEXT
);


-- ============================================================================
-- ========================= Order and Related Tables =========================
-- ============================================================================

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    seller_id TEXT NOT NULL REFERENCES sellers(seller_id) ON DELETE SET NULL,
    delivery_id INT NOT NULL REFERENCES delivery_options(delivery_id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    status VARCHAR(30) NOT NULL CHECK (status IN ('Cancelled', 'Shipping', 'Delivered', 'Processing'))
);

CREATE TABLE ordered_items (
    order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    asin VARCHAR(20) NOT NULL REFERENCES products(asin) ON DELETE SET NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    added_at TIMESTAMP DEFAULT NOW(),
    last_update TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (order_id, asin)
);


-- ============================================================================
-- ================= Customer Wishlist and Related Tables =====================
-- ============================================================================

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


-- ============================================================================
-- ======================== Customer Review Table =============================
-- ============================================================================

CREATE TABLE customer_reviews (
    review_id SERIAL PRIMARY KEY,
    asin VARCHAR(20) REFERENCES products(asin) ON DELETE CASCADE,
    customer_id INT REFERENCES customers(customer_id) ON DELETE CASCADE,
    rating NUMERIC(2,1) CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);


-- ============================================================================
-- ======================== User enqueries Table ==============================
-- ============================================================================
-- (User have question about the website or wants any help.)

CREATE TABLE user_enquiries (
    enquiry_id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('Guess', 'Customer', 'Seller')),
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female')),
    country VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    comment TEXT,
    badge VARCHAR(50) NOT NULL CHECK ( badge IN ('Priority', 'Regular')),
    enquiry_date DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ============================================================================
-- ===================== Become Seller Requests Table =========================
-- ============================================================================

-- (Customer Account that want to become a seller)
CREATE TABLE seller_requests (
    request_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    request_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) NOT NULL 
  DEFAULT 'pending' 
  CHECK (status IN ('pending', 'approved', 'rejected')),
    CONSTRAINT fk_customer
      FOREIGN KEY(customer_id)
        REFERENCES  customers(customer_id)
        ON DELETE CASCADE
);


-- ============================================================================
-- ===================== Website Admin account Table ==========================
-- ============================================================================

CREATE TABLE admin (
    admin_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    hashed_password TEXT NOT NULL
);
