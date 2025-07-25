-- ****************************************************************************
-- ********************** CONSTRAINTS & RELATIONSHIPS *************************
-- ****************************************************************************

-- products
ALTER TABLE products ADD FOREIGN KEY (brand_id) REFERENCES brands(brand_id) ON DELETE SET NULL;
ALTER TABLE products ADD FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id) ON DELETE SET NULL;

-- product_details
ALTER TABLE product_details ADD FOREIGN KEY (asin) REFERENCES products(asin) ON DELETE CASCADE;
ALTER TABLE product_details ADD FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL;
ALTER TABLE product_details ADD CONSTRAINT rating_range CHECK (rating >= 0 AND rating <= 5);

-- rankings, pricing, media, top_review, variations
ALTER TABLE rankings ADD FOREIGN KEY (asin) REFERENCES products(asin) ON DELETE CASCADE;
ALTER TABLE pricing ADD FOREIGN KEY (asin) REFERENCES products(asin) ON DELETE CASCADE;
ALTER TABLE media ADD FOREIGN KEY (asin) REFERENCES products(asin) ON DELETE CASCADE;
ALTER TABLE top_review ADD FOREIGN KEY (asin) REFERENCES products(asin) ON DELETE CASCADE;
ALTER TABLE variations ADD FOREIGN KEY (asin) REFERENCES products(asin) ON DELETE CASCADE;

-- product_categories
ALTER TABLE product_categories ADD FOREIGN KEY (asin) REFERENCES products(asin) ON DELETE CASCADE;
ALTER TABLE product_categories ADD FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE;

-- seller_detail, seller_locations
ALTER TABLE seller_detail ADD FOREIGN KEY (seller_id) REFERENCES sellers(seller_id) ON DELETE CASCADE;
ALTER TABLE seller_locations ADD FOREIGN KEY (seller_id) REFERENCES seller_detail(seller_id) ON DELETE CASCADE;

-- product_sellers
ALTER TABLE product_sellers ADD FOREIGN KEY (asin) REFERENCES products(asin) ON DELETE CASCADE;
ALTER TABLE product_sellers ADD FOREIGN KEY (seller_id) REFERENCES sellers(seller_id) ON DELETE CASCADE;
ALTER TABLE product_sellers ADD CONSTRAINT unique_product UNIQUE (asin);

-- customer_detail, customer_locations
ALTER TABLE customer_detail ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE;
ALTER TABLE customer_locations ADD FOREIGN KEY (customer_id) REFERENCES customer_detail(customer_id) ON DELETE CASCADE;

-- orders, ordered_items
ALTER TABLE orders ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE;
ALTER TABLE orders ADD FOREIGN KEY (seller_id) REFERENCES sellers(seller_id) ON DELETE SET NULL;
ALTER TABLE orders ADD FOREIGN KEY (delivery_id) REFERENCES delivery_options(delivery_id) ON DELETE SET NULL;
ALTER TABLE ordered_items ADD FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE;
ALTER TABLE ordered_items ADD FOREIGN KEY (asin) REFERENCES products(asin) ON DELETE CASCADE;

-- wishlists, wishlist_items
ALTER TABLE wishlists ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE;
ALTER TABLE wishlist_items ADD FOREIGN KEY (wishlist_id) REFERENCES wishlists(wishlist_id) ON DELETE CASCADE;
ALTER TABLE wishlist_items ADD FOREIGN KEY (asin) REFERENCES products(asin) ON DELETE CASCADE;

-- customer_reviews
ALTER TABLE customer_reviews ADD FOREIGN KEY (asin) REFERENCES products(asin) ON DELETE CASCADE;
ALTER TABLE customer_reviews ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE;
ALTER TABLE customer_reviews ADD CONSTRAINT rating_range CHECK (rating >= 1 AND rating <= 5);

-- user_enquiries
ALTER TABLE user_enquiries ADD CONSTRAINT role_check CHECK (role IN ('Guess', 'Customer', 'Seller'));
ALTER TABLE user_enquiries ADD CONSTRAINT gender_check CHECK (gender IN ('Male', 'Female'));
ALTER TABLE user_enquiries ADD CONSTRAINT badge_check CHECK (badge IN ('Priority', 'Regular'));

-- seller_requests
ALTER TABLE seller_requests ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE;
ALTER TABLE seller_requests ADD CONSTRAINT status_check CHECK (status IN ('pending', 'approved', 'rejected'));

-- orders
ALTER TABLE orders ADD CONSTRAINT status_check CHECK (status IN ('Cancelled', 'Shipping', 'Delivered', 'Processing'));

-- customer_detail
ALTER TABLE customer_detail ADD CONSTRAINT gender_check CHECK (gender IN ('Male', 'Female'));


-- ****************************************************************************
-- ******************************* INDEXES ************************************
-- ****************************************************************************

-- ============================================================================
-- Products & Related Tables
-- ============================================================================
CREATE INDEX idx_products_asin ON products(asin); 
CREATE INDEX idx_products_brand_id ON products(brand_id);
CREATE INDEX idx_products_title ON products(title);
CREATE INDEX idx_products_manufacturer_id ON products(manufacturer_id);

CREATE INDEX idx_product_details_department_id ON product_details(department_id);
CREATE INDEX idx_product_details_model_number ON product_details(model_number);
CREATE INDEX idx_product_details_rating ON product_details(rating);

CREATE INDEX idx_media_asin ON media(asin);
CREATE INDEX idx_rankings_asin ON rankings(asin); 
CREATE INDEX idx_pricing_final_price ON pricing(final_price DESC);

CREATE INDEX idx_categories_name ON categories(name);
CREATE INDEX idx_product_categories_category_id ON product_categories(category_id);
CREATE INDEX idx_product_categories_asin ON product_categories(asin);

CREATE INDEX idx_product_sellers_seller_id ON product_sellers(seller_id);
CREATE INDEX idx_product_sellers_asin ON product_sellers(asin);


-- ============================================================================
-- Orders & Items
-- ============================================================================
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_orders_status ON orders(status);

CREATE INDEX idx_ordered_items_asin ON ordered_items(asin);
CREATE INDEX idx_ordered_items_order_id ON ordered_items(order_id);


-- ============================================================================
-- Customers & Details
-- ============================================================================
CREATE INDEX idx_customers_username ON customers(username);
CREATE INDEX idx_customers_created_at ON customers(created_at);

CREATE INDEX idx_customer_detail_email ON customer_detail(email);
CREATE INDEX idx_customer_detail_password_hash ON customer_detail(password_hash);
CREATE INDEX idx_customer_detail_status ON customer_detail(status);

CREATE INDEX idx_customer_reviews_customer_id ON customer_reviews(customer_id);
CREATE INDEX idx_customer_reviews_product ON customer_reviews(asin);
CREATE INDEX idx_customer_reviews_customer_product ON customer_reviews(customer_id, asin);


-- ============================================================================
-- Sellers & Details
-- ============================================================================
CREATE INDEX idx_sellers_created_at ON sellers(created_at);

CREATE INDEX idx_seller_detail_email ON seller_detail(email);
CREATE INDEX idx_seller_detail_password_hash ON seller_detail(password_hash);
CREATE INDEX idx_seller_detail_status ON seller_detail(status);

CREATE INDEX idx_seller_requests_customer_id ON seller_requests(customer_id);
CREATE INDEX idx_seller_requests_status ON seller_requests(status);


-- ============================================================================
-- Wishlists
-- ============================================================================
CREATE INDEX idx_wishlist_items_asin ON wishlist_items(asin);
CREATE INDEX idx_wishlist_items_wishlist_id ON wishlist_items(wishlist_id);


-- ============================================================================
-- User Enquiries
-- ============================================================================
CREATE INDEX idx_user_enquiries_email ON user_enquiries(email);
CREATE INDEX idx_user_enquiries_country ON user_enquiries(country);
CREATE INDEX idx_user_enquiries_enquiry_date ON user_enquiries(enquiry_date);


-- ============================================================================
-- Admin
-- ============================================================================
CREATE INDEX idx_admin_email ON admin(email);
CREATE INDEX idx_admin_phone ON admin(phone);
CREATE INDEX idx_admin_password ON admin(hashed_password);