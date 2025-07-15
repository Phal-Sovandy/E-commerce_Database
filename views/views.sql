
-- ****************************************************************************
-- ******************************* VIEWS **************************************
-- ****************************************************************************

-- =(12)=======================================================================
-- ======================= Top 5 Expensive Products ===========================
-- ============================================================================

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

