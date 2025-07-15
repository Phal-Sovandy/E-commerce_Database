
-- ****************************************************************************
-- ***************************** PROCEDURES ***********************************
-- ****************************************************************************

-- =(1)========================================================================
-- ============================ Add New Product ===============================
-- ============================================================================

CREATE OR REPLACE PROCEDURE add_new_product(
    p_asin VARCHAR,
    p_title TEXT,
    p_brand TEXT,
    p_manufacturer TEXT,
    p_price NUMERIC,
    p_rating NUMERIC,
    p_currency VARCHAR,
    p_description TEXT,
    p_department TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    brand_id_val INT;
    manufacturer_id_val INT;
    department_id_val INT;
BEGIN
    -- Get or insert brand
    SELECT brand_id INTO brand_id_val FROM brands WHERE name = p_brand;
    IF brand_id_val IS NULL THEN
        INSERT INTO brands(name) VALUES (p_brand) RETURNING brand_id INTO brand_id_val;
    END IF;

    -- Get or insert manufacturer
    SELECT manufacturer_id INTO manufacturer_id_val FROM manufacturers WHERE name = p_manufacturer;
    IF manufacturer_id_val IS NULL THEN
        INSERT INTO manufacturers(name) VALUES (p_manufacturer) RETURNING manufacturer_id INTO manufacturer_id_val;
    END IF;

    -- Get or insert department
    IF p_department IS NOT NULL THEN
        SELECT department_id INTO department_id_val FROM departments WHERE name = p_department;
        IF department_id_val IS NULL THEN
            INSERT INTO departments(name) VALUES (p_department) RETURNING department_id INTO department_id_val;
        END IF;
    END IF;

    INSERT INTO products(asin, title, brand_id, manufacturer_id)
    VALUES (p_asin, p_title, brand_id_val, manufacturer_id_val);

    INSERT INTO pricing(asin, final_price, currency)
    VALUES (p_asin, p_price, p_currency);

    INSERT INTO product_details(asin, rating, description, department_id)
    VALUES (p_asin, p_rating, p_description, department_id_val);
END;
$$;

-- =(2)========================================================================
-- ============================= Place Order ==================================
-- ============================================================================

CREATE OR REPLACE PROCEDURE place_order(
    IN p_customer_id INT,
    IN p_seller_id TEXT,
    IN p_delivery_id INT,
    IN p_items JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    new_order_id INT;
    item JSONB;
BEGIN
    INSERT INTO orders (customer_id, seller_id, delivery_id)
    VALUES (p_customer_id, p_seller_id, p_delivery_id)
    RETURNING order_id INTO new_order_id;

    FOR item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        INSERT INTO ordered_items (order_id, asin, quantity)
        VALUES (
            new_order_id,
            item->>'asin',
            (item->>'quantity')::INT
        );
    END LOOP;
END;
$$;

-- =(3)========================================================================
-- ======================= Update Product Price ===============================
-- ============================================================================

CREATE OR REPLACE PROCEDURE update_product_price(
    p_asin VARCHAR,
    p_new_price NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE pricing
    SET final_price = p_new_price,
        updated_at = NOW()
    WHERE asin = p_asin;
END;
$$;

-- =(4)========================================================================
-- ======================= Add Customer Review ================================
-- ============================================================================

CREATE OR REPLACE PROCEDURE add_customer_review(
    p_asin VARCHAR,
    p_customer_id INT,
    p_rating NUMERIC,
    p_comment TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO customer_reviews (asin, customer_id, rating, comment)
    VALUES (p_asin, p_customer_id, p_rating, p_comment);
END;
$$;

-- =(5)========================================================================
-- ================== Accept Customer to be a Seller ==========================
-- ============================================================================

CREATE OR REPLACE PROCEDURE accept_customer_to_seller(p_customer_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    customer_username TEXT;
    customer_email TEXT;
    customer_password TEXT;
    customer_fullname TEXT;
    customer_phone TEXT;
    customer_status BOOLEAN;
    customer_profile_picture TEXT;
    customer_login_method TEXT;
    seller_id TEXT := 'S_' || p_customer_id;
BEGIN
    -- Get customer info
    SELECT 
        c.username,
        cd.email,
        cd.password_hash,
        CONCAT(cd.first_name, ' ', cd.last_name),
        cd.phone,
        cd.status,
        cd.profile_picture,
        cd.login_method
    INTO 
        customer_username,
        customer_email,
        customer_password,
        customer_fullname,
        customer_phone,
        customer_status,
        customer_profile_picture,
        customer_login_method
    FROM customers c
    JOIN customer_detail cd ON c.customer_id = cd.customer_id
    WHERE c.customer_id = p_customer_id;

    -- Deactivate customer account
    UPDATE customer_detail SET status = false WHERE customer_id = p_customer_id;

    -- Insert into sellers
    INSERT INTO sellers (seller_id, seller_name)
    VALUES (seller_id, customer_username);

    -- Insert into seller_detail
    INSERT INTO seller_detail (
        seller_id, email, password_hash, contact_person, phone,
        profile_picture, login_method, status
    )
    VALUES (
        seller_id, customer_email, customer_password, customer_fullname, customer_phone,
        customer_profile_picture, customer_login_method, true
    );

    -- Copy customer location to seller location
    INSERT INTO seller_locations (
        seller_id, country, city, state, zipcode, address_line1, address_line2
    )
    SELECT 
        seller_id, country, city, state, zipcode, address_line1, address_line2
    FROM customer_locations
    WHERE customer_id = p_customer_id;

    -- Update seller_requests table
    UPDATE seller_requests
    SET status = 'approved'
    WHERE customer_id = p_customer_id;

END;
$$;

-- =(6)========================================================================
-- ============ Active and Deactivate Customer/Seller Account =================
-- ============================================================================

CREATE OR REPLACE PROCEDURE toggle_user_role_activation(
    p_email VARCHAR,
    p_role VARCHAR  -- 'customer' or 'seller'
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Normalize role
    IF p_role NOT IN ('customer', 'seller') THEN
        RAISE EXCEPTION 'Invalid role: %, must be eiter "customer" or "seller"', p_role;
    END IF;

    -- Activate customer and deactivate seller
    IF p_role = 'customer' THEN
        -- Activate customer
        UPDATE customer_detail
        SET status = true
        WHERE email = p_email;

        -- Deactivate seller if exists
        UPDATE seller_detail
        SET status = false
        WHERE email = p_email;

    -- Activate seller and deactivate customer
    ELSIF p_role = 'seller' THEN
        -- Activate seller
        UPDATE seller_detail
        SET status = true
        WHERE email = p_email;

        -- Deactivate customer if exists
        UPDATE customer_detail
        SET status = false
        WHERE email = p_email;
    END IF;
END;
$$;



