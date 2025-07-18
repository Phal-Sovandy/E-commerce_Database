-- ****************************************************************************
-- **************************** DATABASE ROLE *********************************
-- ****************************************************************************
CREATE ROLE administrators;
CREATE ROLE sellers;
CREATE ROLE customers;
CREATE ROLE guests;


-- ****************************************************************************
-- ***************************** PRIVILEGES ***********************************
-- ****************************************************************************

-- ============================================================================
-- =========================== ADMIN PRIVILEGES ===============================
-- ============================================================================
GRANT ALL PRIVILEGES ON DATABASE ecommercewebsite TO administrators;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO administrators;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO administrators;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL ON TABLES TO administrators;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL ON SEQUENCES TO administrators;


-- ============================================================================
-- ========================== SELLER PRIVILEGES ===============================
-- ============================================================================
-- Read products and categories
GRANT SELECT ON products, product_details, categories TO sellers;
-- Modify own seller profile
GRANT SELECT, UPDATE ON sellers, seller_detail, seller_locations TO sellers;
-- Insert products they sell
GRANT INSERT, SELECT, DELETE ON product_sellers TO sellers;
-- View orders
GRANT SELECT ON orders, ordered_items TO sellers;
-- Submit enquiries
GRANT INSERT ON user_enquiries TO sellers;


-- ============================================================================
-- ========================= CUSTOMER PRIVILEGES ==============================
-- ============================================================================
-- Browse products
GRANT SELECT ON products, product_details, pricing, media TO customers;
-- Wishlist and reviews
GRANT SELECT, INSERT, DELETE ON wishlists, wishlist_items, customer_reviews TO customers;
-- View and update their own profile
GRANT SELECT, UPDATE ON customers, customer_detail, customer_locations TO customers;
-- Place orders
GRANT INSERT, SELECT ON orders, ordered_items TO customers;
-- Submit enquiries
GRANT INSERT ON user_enquiries TO customers;


-- ============================================================================
-- =========================== GUEST PRIVILEGES ===============================
-- ============================================================================
-- Browse only public product info
GRANT SELECT ON products, pricing, media TO guests;
-- Submit enquiries
GRANT INSERT ON user_enquiries TO guests;


-- ============================================================================
-- ================= FUNCTIONS AND PROCEDURE PRIVILEGES =======================
-- ============================================================================
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO sellers;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO customers;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO guests;


-- ============================================================================
-- =========================== VIEWS PRIVILEGES ===============================
-- ============================================================================
GRANT SELECT ON top_10_expensive_products TO sellers, customers, guests;
GRANT SELECT ON products_with_no_orders TO sellers, customers, guests;



-- ****************************************************************************
-- ************************** ACTUAL USER ROLE ********************************
-- ****************************************************************************
CREATE ROLE big_admin LOGIN PASSWORD 'admin' IN ROLE administrators;
GRANT CREATEROLE TO big_admin;
CREATE ROLE sub_admin LOGIN PASSWORD 'admin' IN ROLE administrators;
CREATE ROLE seller_sreng LOGIN PASSWORD 'password' IN ROLE sellers;
CREATE ROLE customer_sith LOGIN PASSWORD 'password' IN ROLE customers;
CREATE ROLE guest_cheav LOGIN PASSWORD 'password' IN ROLE guests;
