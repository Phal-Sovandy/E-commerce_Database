-- ****************************************************************************
-- ***************************** OVERALL **************************************
-- ****************************************************************************

-- ============================================================================
-- Database current performance stats
-- ============================================================================
SELECT * FROM pg_stat_activity;

-- ============================================================================
-- Database current disk space usage 
-- ============================================================================
SELECT pg_size_pretty(pg_database_size('ecommercewebsite'));

-- ============================================================================
-- Update the statistics of the database (Deleting deleted and updated rows)
-- ============================================================================
VACUUM ANALYZE;


-- ****************************************************************************
-- ************************* VIEW PERFORMANCE *********************************
-- ****************************************************************************

-- =(1)========================================================================
-- Get Top 10 Expensive Products (View)
-- ============================================================================
EXPLAIN ANALYZE
SELECT * FROM top_10_expensive_products;

-- =(2)========================================================================
-- Products with No Orders (View)
-- ============================================================================
EXPLAIN ANALYZE
SELECT * FROM products_with_no_orders LIMIT 100;

-- =(3)========================================================================
-- top_sellers_by_total_sales (view)
-- ============================================================================
EXPLAIN ANALYZE
SELECT * FROM top_sellers_by_total_sales LIMIT 10;

-- =(4)========================================================================
-- products_priced_above_average (view)
-- ============================================================================
EXPLAIN ANALYZE
SELECT * FROM products_priced_above_average LIMIT 10;



-- ****************************************************************************
-- ************************ FUNCTIONS PERFORMANCE *****************************
-- ****************************************************************************

-- =(5)========================================================================
-- Get Top 10 Selling Products (Function)
-- ============================================================================
EXPLAIN ANALYZE
SELECT * FROM get_top_selling_products(10);

-- =(6)========================================================================
-- Get Product Summary for a specific ASIN (Function)
-- ============================================================================
EXPLAIN ANALYZE
SELECT * FROM get_product_summary('B08F5C9Q1Z');

-- =(7)========================================================================
-- Get Customer Order History (Function)
-- ============================================================================
EXPLAIN ANALYZE
SELECT * FROM get_customer_order_history(1);

-- =(8)========================================================================
-- Get Products by Category (Function)
-- ============================================================================
EXPLAIN ANALYZE
SELECT * FROM get_products_by_category('Electronics Category 1');


-- ****************************************************************************
-- ************************* RAW QUERIES PERFORMANCE **************************
-- ****************************************************************************

-- =(9)========================================================================
-- Count All Products
-- ============================================================================
EXPLAIN ANALYZE
SELECT COUNT(*) FROM products;

-- =(10)=======================================================================
-- Count All Orders
-- ============================================================================
EXPLAIN ANALYZE
SELECT COUNT(*) FROM orders;

-- =(11)========================================================================
-- Count All Customers
-- ============================================================================
EXPLAIN ANALYZE
SELECT COUNT(*) FROM customers;

-- =(12)=======================================================================
--  Join Products with Pricing and Brands
-- ============================================================================
EXPLAIN ANALYZE
SELECT
    p.asin,
    p.title,
    b.name AS brand_name,
    pr.final_price,
    pd.rating
FROM products p
LEFT JOIN brands b ON p.brand_id = b.brand_id
LEFT JOIN pricing pr ON p.asin = pr.asin
LEFT JOIN product_details pd ON p.asin = pd.asin
ORDER BY pd.rating DESC, pr.final_price DESC
LIMIT 100;

-- =(13)=======================================================================
-- Top Sellers with Total Sales and Number of Orders
-- ============================================================================
EXPLAIN ANALYZE
SELECT
    s.seller_id,
    s.seller_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity_sold
FROM sellers s
LEFT JOIN orders o ON s.seller_id = o.seller_id
LEFT JOIN ordered_items oi ON o.order_id = oi.order_id
GROUP BY s.seller_id, s.seller_name
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- =(14)=======================================================================
-- Average Product Rating per Department
-- ============================================================================
EXPLAIN ANALYZE
SELECT
    d.name AS department_name,
    AVG(pd.rating) AS avg_rating,
    COUNT(pd.asin) AS product_count
FROM departments d
LEFT JOIN product_details pd ON d.department_id = pd.department_id
GROUP BY d.name
ORDER BY avg_rating DESC NULLS LAST;

-- =(15)=======================================================================
-- Top Customers with Recent Order Dates and Total Spent
-- ============================================================================
EXPLAIN ANALYZE
SELECT
    c.customer_id,
    c.username,
    MAX(o.created_at) AS last_order_date,
    SUM(oi.quantity * pr.final_price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN ordered_items oi ON o.order_id = oi.order_id
JOIN pricing pr ON oi.asin = pr.asin
GROUP BY c.customer_id, c.username
ORDER BY total_spent DESC
LIMIT 10;

-- =(16)========================================================================
-- Index Usage Check
-- ============================================================================
EXPLAIN ANALYZE
SELECT * FROM products WHERE asin = 'B08F5C9Q1Z';

EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 1 ORDER BY created_at DESC LIMIT 5;


-- ****************************************************************************
-- ************************* INDEX PERFORMANCE ********************************
-- ****************************************************************************

-- ==(17)======================================================================
-- Analyze Table and Index Stats
-- ============================================================================
SELECT
    relname AS table_name,
    indexrelname AS index_name,
    idx_scan AS times_used
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC
LIMIT 20;

-- ==(18)======================================================================
-- ANALYZE with VERBOSE & BUFFERS 
-- ============================================================================
EXPLAIN (ANALYZE, VERBOSE, BUFFERS)
SELECT
    p.asin,
    p.title,
    pr.final_price,
    pd.rating
FROM products p
JOIN pricing pr ON p.asin = pr.asin
JOIN product_details pd ON p.asin = pd.asin
WHERE pr.final_price > 100
ORDER BY pd.rating DESC
LIMIT 20;
