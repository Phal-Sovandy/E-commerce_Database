
-- ****************************************************************************
-- ***************************** FUNCTIONS ************************************
-- ****************************************************************************

-- =(8)========================================================================
-- ======================= Get Top Selling Products ===========================
-- ============================================================================

CREATE OR REPLACE FUNCTION get_top_selling_products(limit_count INT)
RETURNS TABLE (
    asin VARCHAR,
    total_quantity BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT asin, SUM(quantity) AS total_quantity
    FROM ordered_items
    GROUP BY asin
    ORDER BY total_quantity DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- =(9)========================================================================
-- ======================= Get A Product Summary ==============================
-- ============================================================================

CREATE OR REPLACE FUNCTION get_product_summary(p_asin TEXT)
RETURNS TABLE (
    title TEXT,
    brand TEXT,
    manufacturer TEXT,
    price NUMERIC,
    rating NUMERIC,
    description TEXT,
    image_url TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.title,
        b.name,
        m.name,
        pr.final_price,
        pd.rating,        
        pd.description,
        md.image_url 
    FROM products p
    LEFT JOIN brands b ON p.brand_id = b.brand_id
    LEFT JOIN manufacturers m ON p.manufacturer_id = m.manufacturer_id
    LEFT JOIN pricing pr ON p.asin = pr.asin
    LEFT JOIN product_details pd ON p.asin = pd.asin
    LEFT JOIN media md ON p.asin = md.asin
    WHERE p.asin = p_asin;
END;
$$ LANGUAGE plpgsql;

-- =(10)=======================================================================
-- ======================= Get A Customer History =============================
-- ============================================================================

CREATE OR REPLACE FUNCTION get_customer_order_history(p_customer_id INT)
RETURNS TABLE (
    order_id INT,
    order_date TIMESTAMP,
    seller_name TEXT,
    delivery_option TEXT,
    total_items BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.order_id,
        o.created_at AS order_date,
        s.seller_name,
        dopt.option_name AS delivery_option,
        SUM(oi.quantity) AS total_items
    FROM orders o
    JOIN sellers s ON o.seller_id = s.seller_id
    JOIN delivery_options dopt ON o.delivery_id = dopt.delivery_id
    JOIN ordered_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = p_customer_id
    GROUP BY o.order_id, o.created_at, s.seller_name, dopt.option_name
    ORDER BY o.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- =(11)=======================================================================
-- ====================== Get A Product By Category ===========================
-- ============================================================================

CREATE OR REPLACE FUNCTION get_products_by_category(p_category_name TEXT)
RETURNS TABLE (
    asin VARCHAR,
    title TEXT,
    brand_name TEXT,
    final_price NUMERIC,
    rating NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.asin,
        p.title,
        b.name AS brand_name,
        pr.final_price,
        pd.rating
    FROM products p
    JOIN product_categories pc ON p.asin = pc.asin
    JOIN categories c ON pc.category_id = c.category_id
    LEFT JOIN brands b ON p.brand_id = b.brand_id
    LEFT JOIN pricing pr ON p.asin = pr.asin
    LEFT JOIN product_details pd ON p.asin = pd.asin
    WHERE c.name ILIKE p_category_name;
END;
$$ LANGUAGE plpgsql;
