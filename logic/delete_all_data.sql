DELETE FROM ordered_items;
DELETE FROM customer_reviews;
DELETE FROM wishlist_items;
DELETE FROM product_categories;
DELETE FROM product_sellers;
DELETE FROM variations;
DELETE FROM top_review;
DELETE FROM media;
DELETE FROM rankings;
DELETE FROM pricing;
DELETE FROM product_details;
DELETE FROM seller_locations;
DELETE FROM seller_detail;
DELETE FROM customer_locations;
DELETE FROM customer_detail;
DELETE FROM seller_requests;
DELETE FROM orders;
DELETE FROM wishlists;
DELETE FROM user_enquiries;

-- Delete from parent tables
DELETE FROM products;
DELETE FROM categories;
DELETE FROM brands;
DELETE FROM manufacturers;
DELETE FROM departments;
DELETE FROM sellers;
DELETE FROM delivery_options;
DELETE FROM customers;
DELETE FROM admin; -- Admin table has no dependencies