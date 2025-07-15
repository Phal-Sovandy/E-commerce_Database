
-- ****************************************************************************
-- ******************************* INDEXES ************************************
-- ****************************************************************************

CREATE INDEX idx_variations_asin ON variations(asin);
CREATE INDEX idx_product_categories_category_id ON product_categories(category_id);
CREATE INDEX idx_rankings_asin ON rankings(asin);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_ordered_items_asin ON ordered_items(asin);
CREATE INDEX idx_products_asin ON products(asin);
CREATE INDEX idx_product_sellers_seller_id ON product_sellers(seller_id);
CREATE INDEX idx_products_brand_id ON products(brand_id);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_products_title ON products(title);
CREATE INDEX idx_pricing_final_price ON pricing(final_price DESC);
CREATE INDEX idx_customer_detail_email ON customer_detail(email);
CREATE INDEX idx_categories_name ON categories(name);
CREATE INDEX idx_product_details_department_id ON product_details(department_id);
CREATE INDEX idx_media_asin ON media(asin);
CREATE INDEX idx_customer_reviews_customer_product ON customer_reviews(customer_id, asin);