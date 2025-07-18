-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-- ============================================================================
--                  🛒 E-Commerce Management System Database                  
-- ============================================================================
-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

-- ============================================================================
-- Prepare sample data
-- ============================================================================
INSERT INTO customers(username)
VALUES ('yoink_123');

INSERT INTO customer_detail(customer_id, email)
VALUES(1, 'customer1@example.com');

INSERT INTO seller_requests(customer_id)
VALUES (1);

INSERT INTO delivery_options (option_name, delivery_days, price)
VALUES ('Standard Shipping', 5, 4.99);

-- ============================================================================
-- Add Sample Products
-- ============================================================================
CALL add_new_product(
    'TEST123ASIN', 'Sample Product', 'SampleBrand', 'SampleManufacturer',
    499.99, 4.5, 'USD', 'A sample product description.', 'Electronics'
);
-- Verify
SELECT * FROM products WHERE asin = 'TEST123ASIN';

-- ============================================================================
-- Place an Order
-- ============================================================================
-- Step 1: Call with correct status casing
CALL place_order(1, 'A105EAKJYOP8OP', 1, 'Processing', 1);

SELECT * FROM orders ORDER BY created_at DESC;

-- Step 2: Add item
CALL add_order_item(11, 'TEST123ASIN', 2);

-- Verify
SELECT * FROM orders AS o INNER JOIN ordered_items AS oi ON o.order_id = oi.order_id;

-- ============================================================================
-- Add a Review
-- ============================================================================
CALL add_customer_review('TEST123ASIN', 1, 4.8, 'Excellent quality!');

-- Verify
SELECT * FROM customer_reviews WHERE asin = 'TEST123ASIN' AND customer_id = 1;

-- ============================================================================
-- Update Price
-- ============================================================================
CALL update_product_price('TEST123ASIN', 599.99);

-- Verify
SELECT * FROM pricing AS p INNER JOIN products AS pr ON p.asin = pr.asin WHERE p.asin = 'TEST123ASIN'; 

-- ============================================================================
-- Promote Customer to Seller
-- ============================================================================
CALL accept_customer_to_seller('1');

-- Verify
SELECT * FROM sellers WHERE seller_id = 'S_1';

-- ============================================================================
-- Toggle Role
-- ============================================================================
CALL toggle_user_role_activation('customer1@example.com', 'customer');

-- Verify
SELECT * FROM customer_detail WHERE email = 'customer1@example.com';
SELECT * FROM seller_detail WHERE email = 'customer1@example.com';

-- ============================================================================
-- Use Functions
-- ============================================================================
-- Top 5 Selling Products
SELECT * FROM get_top_selling_products(5);

-- Product Summary
SELECT * FROM get_product_summary('TEST123ASIN');

-- Customer Order History
SELECT * FROM get_customer_order_history(1);

-- Products by Category
SELECT * FROM get_products_by_category('Electronics');

-- ============================================================================
-- Query Views
-- ============================================================================
SELECT * FROM products_with_no_orders;
SELECT * FROM top_10_expensive_products;
SELECT * FROM top_customers_by_orders;
SELECT * FROM top_sellers_by_product_count;
SELECT * FROM products_priced_above_average;
SELECT * FROM products_with_lowest_prices;
SELECT * FROM products_lowest_total_sales;
SELECT * FROM top_sellers_by_total_sales;