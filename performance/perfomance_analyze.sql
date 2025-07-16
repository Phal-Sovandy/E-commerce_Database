-- ============================================================================
-- Database current performance stats
-- ============================================================================
SELECT * FROM pg_stat_activity;

-- ============================================================================
-- Database current disk space usage 
-- ============================================================================
SELECT pg_size_prety(pg_database_size('ecommercewebsite');

-- ============================================================================
-- Long run query
-- ============================================================================
CREATE EXTENSION pg_stat_statements;
SELECT * FROM pg_stat_statements WHERE total_time > 1000;

-- ============================================================================
-- Update the statistics of the database (Deleting deleted and updated row)
-- ============================================================================
VACUUM ANALYZE ecommercewebsite;


-- ****************************************************************************
-- ============================================================================
-- Example 1: Get Top 5 Expensive Products (View)
-- ============================================================================
EXPLAIN ANALYZE
SELECT * FROM top_5_expensive_products;


-- ============================================================================
-- Example 2: Products with No Orders (View)
-- ============================================================================
EXPLAIN ANALYZE
SELECT * FROM products_with_no_orders LIMIT 100;


-- ============================================================================
-- Example 3: Get Top 10 Selling Products (Function)
-- ============================================================================
EXPLAIN ANALYZE
SELECT * FROM get_top_selling_products(10);


-- ============================================================================
-- Example 4: Get Product Summary for a specific ASIN (Function)
-- ============================================================================
EXPLAIN ANALYZE
SELECT * FROM get_product_summary('B08F5C9Q1Z');


-- ============================================================================
-- Example 5: Get Customer Order History (Function)
-- ============================================================================
EXPLAIN ANALYZE
SELECT * FROM get_customer_order_history(1);


-- ============================================================================
-- Example 6: Get Products by Category (Function)
-- ============================================================================
EXPLAIN ANALYZE
SELECT * FROM get_products_by_category('Electronics Category 1');


-- ============================================================================
-- Example 7: Count All Products
-- ============================================================================
EXPLAIN ANALYZE
SELECT COUNT(*) FROM products;


-- ============================================================================
-- Example 8: Count All Orders
-- ============================================================================
EXPLAIN ANALYZE
SELECT COUNT(*) FROM orders;


-- ============================================================================
-- Example 9: Count All Customers
-- ============================================================================
EXPLAIN ANALYZE
SELECT COUNT(*) FROM customers;


-- ============================================================================
-- Example 10: Join Products with Pricing and Brands (Complex Query)
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


-- ============================================================================
-- Tips for Interpreting EXPLAIN ANALYZE Output:
-- - Look for "Seq Scan" on large tables: This often indicates missing indexes.
-- - High "Cost": A higher cost means the planner estimates it will take more resources.
-- - "Actual Time": The real time taken. Compare "loops" and "rows" to understand efficiency.
-- - "Buffers": Indicates disk I/O. High values suggest data isn't in memory.
-- - "Planning Time": How long the database took to decide on the execution plan.
-- - "Execution Time": How long the query actually ran.
-- - Consider adding VERBOSE, BUFFERS, WAL, COSTS, etc., to EXPLAIN for more details:
--   EXPLAIN (ANALYZE, VERBOSE, BUFFERS) SELECT * FROM products;
-- ============================================================================