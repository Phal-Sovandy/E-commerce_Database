# 🛒 E-commerce Website Database

This project defines a comprehensive PostgreSQL schema for an e-commerce website, including product listings, sellers, customers, orders, and supporting metadata. It also includes SQL scripts for importing and normalizing product data from a CSV file.

---

## 📁 Project Structure

- **Database**: `ecommercewebsite`
- **Primary Source Table**: `rawData`
- **Normalized Tables**:
  - Products & Metadata: `products`, `product_details`, `pricing`, `rankings`, `features`, `variations`, `media`, `reviews`
  - Categories & Brands: `categories`, `brands`, `departments`, `manufacturers`
  - Sellers: `sellers`, `product_sellers`
  - Customers: `customers`, `customer_detail`, `customer_locations`
  - Orders: `orders`, `ordered_items`, `delivery_options`
  - Wishlist: `wishlists`, `wishlist_items`

---

## ⚙️ Setup Instructions

### 1. Create and Connect to the Database

```sql
CREATE DATABASE ecommercewebsite;
\c ecommercewebsite
```

### 2. Create the Schema

Run the SQL script provided in `database_doc.sql`. This script:

- Creates the `rawData` table.
- Defines normalized tables for product metadata, users, and transactions.
- Adds indexes and constraints.
- Includes scripts to populate data from the `rawData` table into normalized tables.

### 3. Import Raw CSV Data

Use the following `\copy` command in `psql`:

```bash
\copy rawData(timestamp, title, seller_name, brand, description, initial_price, final_price, currency, availability, reviews_count, categories, asin, root_bs_rank, image_url, item_weight, rating, product_dimensions, seller_id, date_first_available, discount, model_number, manufacturer, department, plus_content, top_review, variations, features, parent_asin, input_asin, ingredients, bought_past_month, bs_rank, badge, subcategory_rank, images) FROM '/path/to/data-products.csv' DELIMITER ',' CSV HEADER;
```

---

## 🧠 Features

- **Data Normalization**: Splits raw product data into normalized tables to minimize redundancy.
- **Relationships**: Handles complex relationships like product-variation, product-seller, product-category, wishlist, and orders.
- **Constraints & Validation**: Includes `CHECK`, `FOREIGN KEY`, `UNIQUE`, and `NOT NULL` constraints for data integrity.
- **Indexes**: Optimized querying with indexes on key columns (e.g., `asin`, `category_id`, `variation_id`).

---

## 📊 Use Cases

- Build scalable e-commerce apps with structured product, user, and order data.
- Analyze customer activity, product rankings, sales performance, and more.
- Connect to front-end applications or admin dashboards.

---

## 📌 Notes

- Ensure the `data-products.csv` file is properly formatted with correct encodings and escaped characters (especially for JSON and arrays).
- You can add additional fields like `answered_questions`, `payment_status`, or `shipment_tracking` to extend the database.

---

## 🧑‍💻 Author

Designed and implemented by **Phal Sovandy** for a full-stack e-commerce application project.

---

## 📂 Data Source
The dataset used in this project was obtained from the [eCommerce dataset samples by Luminati](https://github.com/luminati-io/eCommerce-dataset-samples.git).
