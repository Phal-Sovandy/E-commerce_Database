-- ****************************************************************************
-- ******************************* VIEWS **************************************
-- ****************************************************************************

-- =(12)=======================================================================
-- ======================= Products with No Orders ============================
-- ============================================================================

CREATE OR REPLACE VIEW products_with_no_orders AS
SELECT
    p.asin,
    p.title,
    p.availability,
    pr.final_price
FROM products p
LEFT JOIN pricing pr ON p.asin = pr.asin
LEFT JOIN ordered_items oi ON p.asin = oi.asin
WHERE oi.asin IS NULL;


-- =(13)=======================================================================
-- ======================= Top 5 Expensive Products ===========================
-- ============================================================================

CREATE OR REPLACE VIEW top_10_expensive_products AS
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
LIMIT 10;


-- =(14)=======================================================================
-- ===================== Top Customers by Order Count =========================
-- ============================================================================

CREATE OR REPLACE VIEW top_customers_by_orders AS
SELECT
    c.customer_id,
    c.username,
    COUNT(o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_items_ordered
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN ordered_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.username
ORDER BY total_orders DESC
LIMIT 10;


-- =(15)=======================================================================
-- ===================== Products with Highest Average Rating =================
-- ============================================================================

CREATE OR REPLACE VIEW products_highest_avg_rating AS
SELECT
    p.asin,
    p.title,
    AVG(cr.rating) AS avg_rating,
    COUNT(cr.review_id) AS review_count
FROM products p
JOIN customer_reviews cr ON p.asin = cr.asin
GROUP BY p.asin, p.title
HAVING COUNT(cr.review_id) > 5
ORDER BY avg_rating DESC, review_count DESC
LIMIT 10;


-- =(16)=======================================================================
-- ======================= Sellers with Most Products =========================
-- ============================================================================

CREATE OR REPLACE VIEW top_sellers_by_product_count AS
SELECT
    s.seller_id,
    s.seller_name,
    COUNT(ps.asin) AS product_count
FROM sellers s
JOIN product_sellers ps ON s.seller_id = ps.seller_id
GROUP BY s.seller_id, s.seller_name
ORDER BY product_count DESC
LIMIT 10;


-- =(17)=======================================================================
-- ===================== Products Priced Above Average =======================
-- ============================================================================

CREATE OR REPLACE VIEW products_priced_above_average AS
SELECT
    p.asin,
    p.title,
    pr.final_price,
    pr.currency
FROM products p
JOIN pricing pr ON p.asin = pr.asin
WHERE pr.final_price > (
    SELECT AVG(final_price) FROM pricing
)
ORDER BY pr.final_price DESC;


-- =(18)=======================================================================
-- ===================== Products with Lowest Prices ==========================
-- ============================================================================

CREATE OR REPLACE VIEW products_with_lowest_prices AS
SELECT
    p.asin,
    p.title,
    pr.final_price,
    pr.currency
FROM products p
JOIN pricing pr ON p.asin = pr.asin
ORDER BY pr.final_price ASC
LIMIT 10;


-- =(19)=======================================================================
-- ===================== Products with Lowest Total Sales =====================
-- ============================================================================

CREATE OR REPLACE VIEW products_lowest_total_sales AS
SELECT
    p.asin,
    p.title,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity_sold
FROM products p
LEFT JOIN ordered_items oi ON p.asin = oi.asin
GROUP BY p.asin, p.title
ORDER BY total_quantity_sold ASC
LIMIT 10;


-- =(20)=======================================================================
-- ======================== Top Sellers by Total Sales ========================
-- ============================================================================

CREATE OR REPLACE VIEW top_sellers_by_total_sales AS
SELECT
    s.seller_id,
    s.seller_name,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity_sold
FROM sellers s
JOIN orders o ON s.seller_id = o.seller_id
JOIN ordered_items oi ON o.order_id = oi.order_id
GROUP BY s.seller_id, s.seller_name
ORDER BY total_quantity_sold DESC
LIMIT 10;
