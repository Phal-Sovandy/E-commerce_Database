-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-- ============================================================================
--                  🛒 E-Commerce Management System Database                  
-- ============================================================================
-- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


-- ============================================================================
-- Add Sample Products
-- ============================================================================
CALL add_new_product(
    'TEST123ASIN', 'Sample Product', 'SampleBrand', 'SampleManufacturer',
    499.99, 4.5, 'USD', 'A sample product description.', 'Electronics'
);

-- ============================================================================
-- Place an Order
-- ============================================================================
DO $$
DECLARE
    items JSONB := '[{"asin": "TEST123ASIN", "quantity": 2}]';
BEGIN
    CALL place_order(1, 'S_1', 1, items);
END$$;

-- ============================================================================
-- Toggle Role
-- ============================================================================
CALL toggle_user_role_activation('customer1@example.com', 'seller');

-- ============================================================================
-- Add a Review
-- ============================================================================
CALL add_customer_review('TEST123ASIN', 1, 4.8, 'Excellent quality!');

-- ============================================================================
-- Update Price
-- ============================================================================
CALL update_product_price('TEST123ASIN', 599.99);

-- ============================================================================
-- Promote Customer to Seller
-- ============================================================================
CALL accept_customer_to_seller(1);

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
SELECT * FROM products_highest_avg_rating;
SELECT * FROM top_sellers_by_product_count;
SELECT * FROM products_priced_above_average;
SELECT * FROM products_with_lowest_prices;
SELECT * FROM products_lowest_total_sales;
SELECT * FROM top_sellers_by_total_sales;