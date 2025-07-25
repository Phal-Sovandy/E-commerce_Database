SELECT setval('manufacturers_manufacturer_id_seq', (SELECT COALESCE(MAX(manufacturer_id), 0) FROM manufacturers) + 1, false);

SELECT setval('departments_department_id_seq', (SELECT COALESCE(MAX(department_id), 0) FROM departments) + 1, false);

SELECT setval('brands_brand_id_seq', (SELECT COALESCE(MAX(brand_id), 0) FROM brands) + 1, false);

SELECT setval('categories_category_id_seq', (SELECT COALESCE(MAX(category_id), 0) FROM categories) + 1, false);

SELECT setval('delivery_options_delivery_id_seq', (SELECT COALESCE(MAX(delivery_id), 0) FROM delivery_options) + 1, false);

SELECT setval('customers_customer_id_seq', (SELECT COALESCE(MAX(customer_id), 0) FROM customers) + 1, false);

SELECT setval('orders_order_id_seq', (SELECT COALESCE(MAX(order_id), 0) FROM orders) + 1, false);

SELECT setval('wishlists_wishlist_id_seq', (SELECT COALESCE(MAX(wishlist_id), 0) FROM wishlists) + 1, false);

SELECT setval('customer_reviews_review_id_seq', (SELECT COALESCE(MAX(review_id), 0) FROM customer_reviews) + 1, false);

SELECT setval('user_enquiries_enquiry_id_seq', (SELECT COALESCE(MAX(enquiry_id), 0) FROM user_enquiries) + 1, false);

SELECT setval('seller_requests_request_id_seq', (SELECT COALESCE(MAX(request_id), 0) FROM seller_requests) + 1, false);

SELECT setval('admin_admin_id_seq', (SELECT COALESCE(MAX(admin_id), 0) FROM admin) + 1, false);