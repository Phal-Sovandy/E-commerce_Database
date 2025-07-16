# E-COMMERCE DATABASE

## Table of Contents

1.  [Introduction](#1-introduction)
2.  [Features](#2-features)
3.  [Repository Structure](#3-repository-structure)
4.  [Prerequisites](#4-prerequisites)
5.  [Database Setup Guide](#5-database-setup-guide)
    * [5.1. Schema Initialization](#51-schema-initialization)
    * [5.2. Database Logic Deployment](#52-database-logic-deployment)
    * [5.3. View Creation](#53-view-creation)
    * [5.4. Data Population](#54-data-population)
6.  [Database Schema Overview](#6-database-schema-overview)
    * [6.1. Product and Related Tables](#61-product-and-related-tables)
    * [6.2. Seller and Related Tables](#62-seller-and-related-tables)
    * [6.3. Delivery Option Tables](#63-delivery-option-tables)
    * [6.4. Customer and Related Tables](#64-customer-and-related-tables)
    * [6.5. Order and Related Tables](#65-order-and-related-tables)
    * [6.6. Customer Wishlist and Related Tables](#66-customer-wishlist-and-related-tables)
    * [6.7. Customer Review Table](#67-customer-review-table)
    * [6.8. User Enquiries Table](#68-user-enquiries-table)
    * [6.9. Become Seller Requests Table](#69-become-seller-requests-table)
    * [6.10. Website Admin Account Table](#610-website-admin-account-table)
7.  [Contributing](#7-contributing)
8.  [License](#8-license)

---

## 1. Introduction

This project provides a comprehensive database schema and associated scripts for an e-commerce platform. It is designed to manage various aspects of an online store, including product information, seller details, customer accounts, orders, reviews, and administrative functionalities. The database is built using PostgreSQL and includes robust features such as foreign key constraints, default values, and data integrity checks.

## 2. Features

* **Product Management**: Comprehensive tables for product details, pricing, media, categories, brands, manufacturers, and rankings.
* **User Management**: Dedicated sections for customer and seller accounts, including detailed profiles, locations, and authentication fields.
* **Order Processing**: Structured tables for managing orders, order items, and delivery options.
* **Customer Engagement**: Features for customer reviews and wishlists.
* **Administrative Tools**: Tables for user enquiries, seller requests, and administrator accounts.
* **Data Flexibility**: Utilizes `JSONB` data type for flexible storage of `subcategory_rank` and `variations`.

## 3. Repository Structure

The project is organized into several directories to logically separate different components of the database setup and data management.
```bash
.
├── backups/
|   ├── base/                    # Store the .backup files from the pg_dump
|   ├── BACKUP_RESTORE.md        # Guide on how to backup and restore the database
|
├── data/
│   ├── data-products.csv        # Raw CSV data for product import
│   ├── import_raw_csv.sql       # SQL script to import data from CSV into rawData table, then to main tables
│   └── random_generate_data.py  # Python script to generate random data
├── logic/
│   ├── functions.sql            # SQL scripts for database functions
│   ├── procedures.sql           # SQL scripts for database stored procedures
│   ├── triggers.sql             # SQL scripts for database triggers
│   └── delete_all_data.sql      # SQL script for clearing all data (use with caution)
├── schema/
│   ├── create_tables.sql        # SQL script for creating all database tables
│   └── constraint_indexes.sql   # SQL script for adding primary keys, foreign keys, and indexes
├── views/
│   └── views.sql                # SQL script for creating database views
├── .gitignore                   # Specifies intentionally untracked files to ignore
├── LICENSE                      # This repository license
└── README.md                    # This README file
```

### Directory Breakdown:

* **`data/`**: Contains scripts and files related to populating the database with initial or test data.
* **`logic/`**: Houses SQL scripts that implement the business logic of the database, such as functions, procedures, and triggers.
* **`schema/`**: Contains the core SQL scripts for defining the database structure (tables, constraints, and indexes).
* **`views/`**: Stores SQL scripts for creating database views, which simplify data retrieval.


## 4. Prerequisites

Before setting up the database, ensure you have the following installed:

* **PostgreSQL**: The database management system. You can download it from [PostgreSQL Official Website](https://www.postgresql.org/download/).
* **PostgreSQL Client**: A client tool to execute SQL scripts. `pgAdmin4` is recommended for its comprehensive GUI features. You can download it from [pgAdmin Official Website](https://www.pgadmin.org/download/).
* **Python 3**: Required if you choose to generate random data.
    * For macOS: Typically pre-installed or can be installed via Homebrew.
    * For Windows: Download from [Python Official Website](https://www.python.org/downloads/).
* **`Faker` Python Library**: Only if using the random data generation script.
    * Install via pip for Windows:
        ```bash
        pip install Faker
        ```
    * Install via pip3 for macOS:
        ```bash
        pip3 install Faker
        ```

## 5. Database Setup Guide

Follow these steps meticulously to set up and populate your e-commerce database. Each step involves executing SQL scripts using your PostgreSQL client (e.g., pgAdmin4).

### 5.1. Schema Initialization

This step involves creating all necessary tables and defining their structural integrity.

1.  **Create Database and Tables**:
    * Open the script located at `./schema/create_tables.sql`.
    * Copy the entire content of the file.
    * Paste and execute it in your PostgreSQL client. This script will first attempt to drop the `ecommercewebsite` database if it exists, then create it, and finally define all the tables within it.

2.  **Apply Constraints and Indexes**:
    * Open the script located at `./schema/constraint_indexes.sql`.
    * Copy its content.
    * Paste and execute it in your PostgreSQL client. This script will apply primary keys, foreign keys, and other constraints and indexes that optimize database performance and enforce data integrity.

### 5.2. Database Logic Deployment

This phase involves deploying stored procedures, functions, and triggers that implement core business logic.

1.  Navigate to the `logic` directory.
2.  **Execute Logic Scripts**: For each of the following files, open them, copy their content, and execute them sequentially in your PostgreSQL client:
    * `./logic/functions.sql`
    * `./logic/procedures.sql`
    * `./logic/triggers.sql`

    **Important**: Do **NOT** run `delete_all_data.sql` at this stage, as it is intended for database cleanup.

### 5.3. View Creation

Views provide simplified and often customized representations of the data from one or more tables.

1.  **Create Views**:
    * Open the script located at `./views/views.sql`.
    * Copy its content.
    * Paste and execute it in your PostgreSQL client. This will create various predefined views for easier data retrieval and reporting.

### 5.4. Data Population

You have two distinct methods to populate the database with data. Choose **only one** option.

#### Option A: Import Data from Provided CSV

This method is suitable if you have a `data-products.csv` file and prefer to import pre-existing data.

1.  **Address CSV Encoding Issue (Windows Users)**:
    If you encounter an `ERROR: character with byte sequence 0x9d in encoding "WIN1252" has no equivalent in encoding "UTF8"`, it means your `data-products.csv` file is likely saved with Windows-1252 encoding, but PostgreSQL expects UTF-8. You need to convert the CSV file to UTF-8.

    * **Method 1: Using Notepad (for simpler files)**
        1.  Open `data-products.csv` in Notepad.
        2.  Go to `File` > `Save As...`.
        3.  In the "Save As" dialog, select `UTF-8` from the "Encoding" dropdown at the bottom.
        4.  Save and overwrite the original file.
    * **Method 2: Using a Text Editor (Recommended: e.g., Notepad++, VS Code)**
        1.  Open `data-products.csv` in your preferred text editor.
        2.  Look for an "Encoding" or "Format" option (often in the bottom bar or under a `File` or `Encoding` menu).
        3.  Select `Convert to UTF-8` or `Encode in UTF-8`.
        4.  Save the file.
    * **Method 3: Using Python (for programmatic conversion)**
        Create a Python script (e.g., `convert_encoding.py`) with the following code and run it:
        ```python
        import codecs

        input_file = 'D:/data-products.csv'  # Adjust to your original file path
        output_file = 'D:/data-products-utf8.csv' # New UTF-8 file path

        with codecs.open(input_file, 'r', encoding='windows-1252') as f_in:
            content = f_in.read()

        with codecs.open(output_file, 'w', encoding='utf-8') as f_out:
            f_out.write(content)

        print(f"File '{input_file}' successfully converted to UTF-8 as '{output_file}'")
        ```
        After conversion, **use the path to the newly created UTF-8 file** (e.g., `D:/data-products-utf8.csv`) in the next step.

2.  **Prepare the `rawData` Table**:
    * Open the script located at `./data/import_raw_csv.sql`.
    * Copy **ONLY** the `CREATE TABLE rawData (...)` statement from the beginning of this file.
    * Paste and execute this `CREATE TABLE` statement in your PostgreSQL client (e.g., pgAdmin4). This creates a temporary staging table for the raw CSV data.

3.  **Import Data into `rawData` Table using `psql`**:
    * **Locate your `data-products.csv` file (or the newly converted `data-products-utf8.csv`).**
    * Open your terminal or command prompt (Windows: `cmd` or PowerShell).
    * Connect to your `ecommercewebsite` database using the `psql` command-line client. You'll typically need to provide your PostgreSQL username and the database name:
        ```bash
        psql -U your_postgres_username -d ecommercewebsite
        ```
        (e.g., `psql -U postgres -d ecommercewebsite`)
    * Once connected (the prompt will change, e.g., `ecommercewebsite=#`), execute the `\copy` command. **You must replace `/YOUR/ACTUAL/PATH/TO/data-products.csv` with the full, absolute path to your CSV file.**

        ```sql
        \copy rawData(timestamp, title, seller_name, brand, description, initial_price, final_price, currency, availability, categories, asin, root_bs_rank, image_url, item_weight, rating, product_dimensions, seller_id, date_first_available, discount, model_number, manufacturer, department, top_review, variations, features, ingredients, bs_rank, badge, subcategory_rank, images) FROM '/YOUR/ACTUAL/PATH/TO/data-products.csv' DELIMITER ',' CSV HEADER;
        ```
        **Example for Windows:**
        ```sql
        \copy rawData(timestamp, title, seller_name, brand, description, initial_price, final_price, currency, availability, categories, asin, root_bs_rank, image_url, item_weight, rating, product_dimensions, seller_id, date_first_available, discount, model_number, manufacturer, department, top_review, variations, features, ingredients, bs_rank, badge, subcategory_rank, images) FROM 'D:/data-products-utf8.csv' DELIMITER ',' CSV HEADER;
        ```
        **Note**: The `\copy` command is a `psql` meta-command and must be executed directly within the `psql` terminal, not in pgAdmin's query tool. It's designed for efficient bulk data loading.

4.  **Populate Main Tables from `rawData`**:
    * Return to your PostgreSQL client (e.g., pgAdmin4).
    * Open the `./data/import_raw_csv.sql` file again.
    * Copy **all** the `INSERT INTO ... SELECT ...` statements (starting from `INSERT INTO manufacturers (...)` down to the end of the file).
    * Paste and execute these `INSERT` statements in your PostgreSQL client. These queries will transfer the data from the `rawData` staging table into the appropriate structured tables of your `ecommercewebsite` database.
    * *(Optional)* Once data is successfully moved and verified, you can clean up the temporary `rawData` table by executing:
        ```sql
        DROP TABLE rawData;
        ```

#### Option B: Generate Random Data with Python (Images not work)

This method is ideal for quickly populating the database with synthetic data for testing or development purposes.

1.  **Ensure `Faker` is Installed**:
    * Verify that the `Faker` Python library is installed (refer to [Prerequisites](#3-prerequisites)).

2.  **Run Data Generation Script**:
    * Open your terminal or command prompt.
    * Navigate to the root directory of this project.
    * Execute the Python script:
        ```bash
        python3 ./data/random_generate_data.py
        ```
        (For Windows users, you might need to use `python` instead of `python3`.)

## 6. Database Schema Overview

The `ecommercewebsite` database is structured to support a wide range of e-commerce operations. Below is a detailed breakdown of the major table groups:

### 6.1. Product and Related Tables

These tables are central to managing product inventory and attributes.

* **`manufacturers`**: Stores unique manufacturer names, identified by `manufacturer_id`.
* **`departments`**: Stores unique department names, identified by `department_id`.
* **`brands`**: Stores unique brand names, identified by `brand_id`.
* **`products`**: The core product table, holding basic product information such as ASIN (Primary Key), title, and foreign keys to `brands` and `manufacturers`. It includes `updated_at` and `created_at` timestamps.
* **`product_details`**: Provides in-depth information about products, including description, model number, `date_first_available`, `rating` (numeric with a `CHECK` constraint `(rating >= 0 AND rating <= 5)`), `item_weight`, `product_dimensions`, `ingredients`, and `features` (as a text array). It references `products` by `asin`.
* **`rankings`**: Stores various ranking metrics for products, such as `root_bs_rank`, `bs_rank`, `subcategory_rank` (stored as `JSONB`), and `badge`.
* **`pricing`**: Manages product pricing, including `initial_price`, `final_price`, `currency`, and `discount`.
* **`media`**: Contains URLs for product images, including a primary `image_url` and an array of `images`.
* **`top_review`**: Stores a summary of the most prominent review for a product.
* **`categories`**: Defines product categories, with a unique `category_id` and `name`.
* **`product_categories`**: A junction table that establishes a many-to-many relationship between `products` and `categories`.
* **`variations`**: Stores product variations in a flexible `JSONB` format.

### 6.2. Seller and Related Tables

These tables manage information pertaining to sellers on the platform.

* **`sellers`**: Basic seller profiles with a `seller_id` (Primary Key) and `seller_name`.
* **`seller_detail`**: Detailed seller information, including `email`, `password_hash`, `contact_person`, `bio`, `phone`, `profile_picture`, `login_method`, `status`, and `registration_date`. It has a foreign key to `sellers`.
* **`seller_locations`**: Stores geographical address details for sellers, including `country`, `city`, `state`, `zipcode`, `address_line1`, and `address_line2`. It also references `seller_detail` with a foreign key constraint.
* **`product_sellers`**: Links `products` to `sellers`, indicating which products are offered by which sellers. It has a unique constraint ensuring that each product-seller combination is distinct.

### 6.3. Delivery Option Tables

Manages the various shipping and delivery options available.

* **`delivery_options`**: Defines different delivery methods, including `option_name`, `delivery_days`, and `price`.

### 6.4. Customer and Related Tables

These tables handle customer accounts and their personal information.

* **`customers`**: Core customer accounts with `customer_id` (Primary Key) and `username`.
* **`customer_detail`**: Extensive customer details, such as `email`, `password_hash`, `first_name`, `last_name`, `phone`, `birth_date`, `gender`, `country`, `profile_picture`, `status`, `login_method`, and `registration_date`. It has a foreign key to `customers`.
* **`customer_locations`**: Stores address details for customers.

### 6.5. Order and Related Tables

These tables track customer orders and the items within them.

* **`orders`**: Records order information, linking a `customer_id`, `seller_id`, and `delivery_id`. Includes `created_at` and `status`, with `status` restricted to 'Cancelled', 'Shipping', 'Delivered', or 'Processing'.
* **`ordered_items`**: Details the specific products (`asin`) and their `quantity` for each `order_id`.

### 6.6. Customer Wishlist and Related Tables

Manages customer wishlists and their contents.

* **`wishlists`**: Stores basic wishlist information, including the associated `customer_id`.
* **`wishlist_items`**: Links specific `products` (`asin`) to `wishlists`.

### 6.7. Customer Review Table

Dedicated to storing customer feedback on products.

* **`customer_reviews`**: Captures product reviews, including `rating` (with a `CHECK` constraint `(rating >= 1 AND rating <= 5)`), `comment`, and references to `asin` and `customer_id`.

### 6.8. User Enquiries Table

Handles general inquiries from website users.

* **`user_enquiries`**: Stores details of inquiries, including `full_name`, `role` (constrained to 'Guess', 'Customer', 'Seller'), `gender`, `country`, `region`, `email`, `phone`, `comment`, `badge` (constrained to 'Priority', 'Regular'), and `enquiry_date`.

### 6.9. Become Seller Requests Table

Manages requests from customers who wish to transition to a seller role.

* **`seller_requests`**: Tracks `customer_id`s requesting to become sellers, their `request_date`, and `status` (constrained to 'pending', 'approved', 'rejected').

### 6.10. Website Admin Account Table

Manages administrative access to the platform.

* **`admin`**: Stores `admin_id`, `email`, `phone`, and a `hashed_password` for website administrators.

## 7. Contributing

Contributions are welcome! If you have suggestions for improvements, new features, or bug fixes, please open an issue or submit a pull request.

## 8. License

This project is open-source and available under the [MIT License](LICENSE).
