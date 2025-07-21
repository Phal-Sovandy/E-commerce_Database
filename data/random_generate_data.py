import uuid
import random
from datetime import datetime, timedelta, date
from faker import Faker
import json

# Initialize Faker
fake = Faker()

# Configuration for Data Generation
NUM_MANUFACTURERS = 10000
NUM_DEPARTMENTS = 1000
NUM_BRANDS = 2000
NUM_SELLERS = 15000
NUM_DELIVERY_OPTIONS = 5
NUM_CUSTOMERS = 10000
NUM_PRODUCTS = 100000
NUM_ORDERS = 10000
NUM_CATEGORIES = 5000
NUM_WISHLISTS = 3000
NUM_CUSTOMER_REVIEWS = 50000
NUM_USER_ENQUIRIES = 10000
NUM_ADMINS = 50
NUM_SELLER_REQUESTS = 50000

# List of real image URLs that work
REAL_IMAGE_URLS = [
    "https://images.unsplash.com/photo-1542291026-7eec264c27ff",
    "https://images.unsplash.com/photo-1523275335684-37898b6baf30",
    "https://images.unsplash.com/photo-1572635196237-14b3f281503f",
    "https://images.unsplash.com/photo-1585386959984-a4155224a1ad",
    "https://images.unsplash.com/photo-1584917865442-de89df76afd3",
    "https://images.unsplash.com/photo-1546868871-7041f2a55e12",
    "https://images.unsplash.com/photo-1560343090-f0409e92791a",
    "https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f",
    "https://images.unsplash.com/photo-1556228453-efd6c1ff04f6",
    "https://images.unsplash.com/photo-1491553895911-0055eca6402d",
    "https://images.unsplash.com/photo-1544947950-fa07a98d237f",
    "https://images.unsplash.com/photo-1581235720704-06d3acfcb36f",
    "https://images.unsplash.com/photo-1505740420928-5e560c06d30e",
    "https://images.unsplash.com/photo-1563903530908-afdd155d057a",
    "https://images.unsplash.com/photo-1515955656352-a1fa3ffcd111",
    "https://images.unsplash.com/photo-1503602642458-232111445657",
    "https://images.unsplash.com/photo-1513112300738-bbbf7b1b3c15",
    "https://images.unsplash.com/photo-1517487881594-2787fef5ebf7",
    "https://images.unsplash.com/photo-1517686469429-8bdb88b9f907",
    "https://images.unsplash.com/photo-1505740420928-5e560c06d30e"
]

# --- Helper Functions for Data Generation ---

def generate_asin():
    """Generates a fake ASIN (Amazon Standard Identification Number)."""
    return ''.join(random.choices('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', k=10))

def generate_phone_number():
    """Generates a fake phone number."""
    return fake.phone_number()[:20]

def generate_password_hash():
    """Generates a simple fake password hash."""
    return fake.sha256(raw_output=False)

def generate_random_date(start_date, end_date):
    """Generates a random date between two dates."""
    return fake.date_between(start_date=start_date, end_date=end_date)

def generate_random_datetime(start_date, end_date):
    """Generates a random datetime between two datetimes."""
    return fake.date_time_between(start_date=start_date, end_date=end_date)

def generate_jsonb_variations():
    """Generates a list of dictionaries for product variations."""
    num_variations = random.randint(1, 5)
    variations = []
    # Use a set to ensure unique ASINs within a single product's variations
    generated_asins = set() 
    for _ in range(num_variations):
        # Generate a unique ASIN for each variation
        var_asin = generate_asin()
        while var_asin in generated_asins:
            var_asin = generate_asin()
        generated_asins.add(var_asin)

        # Generate a descriptive name for the variation
        name_parts = [
            fake.word().capitalize(),
            random.choice(['Color', 'Size', 'Style', 'Capacity']),
            f"{random.randint(8, 20)} {random.choice(['Ounce', 'Liter', 'Pack'])}",
            f"(Pack of {random.randint(1, 4)})"
        ]
        var_name = " ".join(name_parts)
        
        variations.append({
            "asin": var_asin,
            "name": var_name
        })
    return json.dumps(variations)

def generate_jsonb_subcategory_rank():
    """Generates a simple JSONB structure for subcategory rank."""
    num_ranks = random.randint(1, 3)
    ranks = {}
    for _ in range(num_ranks):
        category = fake.word()
        rank = random.randint(1, 1000)
        ranks[category] = rank
    return json.dumps(ranks)

def generate_text_array(min_items=1, max_items=5):
    """Generates a PostgreSQL TEXT[] compatible string of random features"""
    items = [f'"{fake.sentence(nb_words=3).strip(".")}"' for _ in range(random.randint(min_items, max_items))]
    return '{' + ','.join(items) + '}'

def get_random_image_url():
    """Returns a random working image URL from our list"""
    return random.choice(REAL_IMAGE_URLS)

def generate_image_url_array(min_items=1, max_items=5):
    """Generates a PostgreSQL TEXT[] compatible string of image URLs"""
    items = [f'"{get_random_image_url()}"' for _ in range(random.randint(min_items, max_items))]
    return '{' + ','.join(items) + '}'

# --- Data Storage ---
manufacturers_data = []
departments_data = []
brands_data = []
sellers_data = []
delivery_options_data = []
customers_data = []
products_data = []
categories_data = []
orders_data = []
wishlists_data = []

# --- SQL INSERT Statement Generator ---
def generate_insert_statement(table_name, columns, values):
    """Generates a SQL INSERT statement."""
    cols_str = ', '.join(columns)
    formatted_values = []
    for v in values:
        if isinstance(v, datetime):
            formatted_values.append(f"'{v.strftime('%Y-%m-%d %H:%M:%S.%f')}'")
        elif isinstance(v, date):
            formatted_values.append(f"'{v.strftime('%Y-%m-%d')}'")
        elif isinstance(v, str):
            # Escape single quotes for SQL insertion
            formatted_values.append(f"'{v.replace("'", "''")}'")
        elif v is None:
            formatted_values.append('NULL')
        else:
            formatted_values.append(str(v))
    vals_str = ', '.join(formatted_values)
    return f"INSERT INTO {table_name} ({cols_str}) VALUES ({vals_str});"

# --- Main Data Generation Logic ---

def generate_data():
    sql_statements = []

    # 1. manufacturers
    for i in range(NUM_MANUFACTURERS):
        manufacturer_id = i + 1
        name = f"{fake.company()} {i+1}"
        manufacturers_data.append({'manufacturer_id': manufacturer_id, 'name': name})
        sql_statements.append(generate_insert_statement('manufacturers', ['manufacturer_id', 'name'], [manufacturer_id, name]))

    # 2. departments
    for i in range(NUM_DEPARTMENTS):
        department_id = i + 1
        name = f"{fake.word().capitalize()} Department {i+1}"
        departments_data.append({'department_id': department_id, 'name': name})
        sql_statements.append(generate_insert_statement('departments', ['department_id', 'name'], [department_id, name]))

    # 3. brands
    for i in range(NUM_BRANDS):
        brand_id = i + 1
        name = f"{fake.company()} Brand {i+1}"
        brands_data.append({'brand_id': brand_id, 'name': name})
        sql_statements.append(generate_insert_statement('brands', ['brand_id', 'name'], [brand_id, name]))

    # 4. sellers
    for i in range(NUM_SELLERS):
        seller_id = f"SEL_{uuid.uuid4().hex[:8].upper()}"
        seller_name = fake.unique.company()
        sellers_data.append({'seller_id': seller_id, 'seller_name': seller_name})
        sql_statements.append(generate_insert_statement('sellers', ['seller_id', 'seller_name'], [seller_id, seller_name]))

    # 5. delivery_options
    delivery_names = ['Standard', 'Express', 'Next Day', 'Same Day', 'Economy']
    for i in range(NUM_DELIVERY_OPTIONS):
        delivery_id = i + 1
        option_name = delivery_names[i % len(delivery_names)]
        delivery_days = random.randint(1, 10)
        price = round(random.uniform(2.0, 25.0), 2)
        delivery_options_data.append({'delivery_id': delivery_id, 'option_name': option_name, 'delivery_days': delivery_days, 'price': price})
        sql_statements.append(generate_insert_statement('delivery_options', ['delivery_id', 'option_name', 'delivery_days', 'price'], [delivery_id, option_name, delivery_days, price]))

    # 6. customers
    for i in range(NUM_CUSTOMERS):
        customer_id = i + 1
        username = fake.unique.user_name()
        customers_data.append({'customer_id': customer_id, 'username': username})
        sql_statements.append(generate_insert_statement('customers', ['customer_id', 'username'], [customer_id, username]))

    # 7. products - assign each product to one seller during creation
    for i in range(NUM_PRODUCTS):
        asin = generate_asin()
        title = fake.catch_phrase() + ' ' + fake.word().capitalize()
        brand_id = random.choice(brands_data)['brand_id'] if brands_data else None
        manufacturer_id = random.choice(manufacturers_data)['manufacturer_id'] if manufacturers_data else None
        availability = random.choice(['In Stock', 'Out of Stock', 'Pre-order'])
        seller_id = random.choice(sellers_data)['seller_id'] if sellers_data else None
        
        products_data.append({
            'asin': asin, 
            'title': title, 
            'brand_id': brand_id, 
            'manufacturer_id': manufacturer_id, 
            'availability': availability,
            'seller_id': seller_id
        })
        
        sql_statements.append(generate_insert_statement('products', 
            ['asin', 'title', 'brand_id', 'manufacturer_id', 'availability'], 
            [asin, title, brand_id, manufacturer_id, availability]
        ))

    # 8. product_details
    for product in products_data:
        asin = product['asin']
        description = fake.paragraph(nb_sentences=3)
        model_number = fake.bothify(text='MDL-####-???')
        date_first_available = generate_random_date(datetime(2020, 1, 1), datetime.now())
        rating = round(random.uniform(1.0, 5.0), 1)
        item_weight = f"{random.randint(50, 5000)}g"
        product_dimensions = f"{random.randint(10, 100)}x{random.randint(10, 100)}x{random.randint(10, 100)}cm"
        department_id = random.choice(departments_data)['department_id'] if departments_data else None
        ingredients = fake.sentence(nb_words=10) if random.random() > 0.5 else None
        features = generate_text_array()

        sql_statements.append(generate_insert_statement('product_details',
            ['asin', 'description', 'model_number', 'date_first_available', 'rating', 'item_weight', 'product_dimensions', 'department_id', 'ingredients', 'features'],
            [asin, description, model_number, date_first_available, rating, item_weight, product_dimensions, department_id, ingredients, features]
        ))

    # 9. pricing
    for product in products_data:
        asin = product['asin']
        initial_price = round(random.uniform(10.0, 1000.0), 2)
        final_price = round(initial_price * random.uniform(0.7, 1.0), 2)
        currency = 'USD'
        discount = f"{random.randint(0, 30)}%" if random.random() > 0.3 else None
        sql_statements.append(generate_insert_statement('pricing',
            ['asin', 'initial_price', 'final_price', 'currency', 'discount'],
            [asin, initial_price, final_price, currency, discount]
        ))

    # 10. rankings
    for product in products_data:
        asin = product['asin']
        root_bs_rank = random.randint(1, 10000)
        bs_rank = random.randint(1, 5000)
        subcategory_rank = generate_jsonb_subcategory_rank()
        badge = random.choice(['#1 Best Seller', 'Amazon\'s Choice', '#1 New Release', None])
        sql_statements.append(generate_insert_statement('rankings',
            ['asin', 'root_bs_rank', 'bs_rank', 'subcategory_rank', 'badge'],
            [asin, root_bs_rank, bs_rank, subcategory_rank, badge]
        ))

    # 11. media - use real image URLs
    for product in products_data:
        asin = product['asin']
        image_url = get_random_image_url()
        images = generate_image_url_array(min_items=1, max_items=5)
        # Count the items by splitting the PostgreSQL array string
        images_count = len(images[1:-1].split(','))  # Remove {} and split by commas
        sql_statements.append(generate_insert_statement('media',
            ['asin', 'image_url', 'images', 'images_count'],
            [asin, image_url, images, images_count]
        ))

    # 12. top_review
    for product in products_data:
        asin = product['asin']
        top_review = fake.paragraph(nb_sentences=2)
        sql_statements.append(generate_insert_statement('top_review', ['asin', 'top_review'], [asin, top_review]))

    # 13. categories
    for i in range(NUM_CATEGORIES):
        category_id = i + 1
        name = f"{fake.word().capitalize()} Category {i+1}"
        categories_data.append({'category_id': category_id, 'name': name})
        sql_statements.append(generate_insert_statement('categories', ['category_id', 'name'], [category_id, name]))

    # 14. product_categories
    for product in products_data:
        asin = product['asin']
        num_categories = random.randint(1, min(3, len(categories_data)))
        assigned_category_ids = random.sample([c['category_id'] for c in categories_data], num_categories)
        for category_id in assigned_category_ids:
            sql_statements.append(generate_insert_statement('product_categories', ['asin', 'category_id'], [asin, category_id]))

    # 15. variations
    # This section now uses the updated generate_jsonb_variations function
    for product in products_data:
        if random.random() < 0.3: # ~30% of products will have variations
            asin = product['asin']
            variations_json = generate_jsonb_variations()
            sql_statements.append(generate_insert_statement('variations', ['asin', 'variations'], [asin, variations_json]))

    # 16. product_sellers - now each product has exactly one seller
    for product in products_data:
        asin = product['asin']
        seller_id = product['seller_id']
        if seller_id:
            sql_statements.append(generate_insert_statement('product_sellers', ['asin', 'seller_id'], [asin, seller_id]))

    # 17. seller_detail
    for seller in sellers_data:
        seller_id = seller['seller_id']
        email = fake.unique.email()
        password_hash = generate_password_hash()
        contact_person = fake.name()
        phone = generate_phone_number()
        profile_picture = fake.image_url()
        login_method = random.choice(['email', 'google', 'facebook'])
        status = fake.boolean(chance_of_getting_true=90)
        registration_date = generate_random_date(datetime(2018, 1, 1), datetime.now())
        sql_statements.append(generate_insert_statement('seller_detail',
            ['seller_id', 'email', 'password_hash', 'contact_person', 'phone', 'profile_picture', 'login_method', 'status', 'registration_date'],
            [seller_id, email, password_hash, contact_person, phone, profile_picture, login_method, status, registration_date]
        ))

    # 18. seller_locations
    for seller in sellers_data:
        seller_id = seller['seller_id']
        country = fake.country()
        city = fake.city()
        state = fake.state()
        zipcode = fake.postcode()
        address_line1 = fake.street_address()
        address_line2 = fake.secondary_address() if random.random() > 0.5 else None
        sql_statements.append(generate_insert_statement('seller_locations',
            ['seller_id', 'country', 'city', 'state', 'zipcode', 'address_line1', 'address_line2'],
            [seller_id, country, city, state, zipcode, address_line1, address_line2]
        ))

    # 19. customer_detail
    for customer in customers_data:
        customer_id = customer['customer_id']
        email = fake.unique.email()
        password_hash = generate_password_hash()
        first_name = fake.first_name()
        last_name = fake.last_name()
        phone = generate_phone_number()
        birth_date = generate_random_date(datetime(1950, 1, 1), datetime(2005, 12, 31))
        gender = random.choice(['Male', 'Female'])
        country = fake.country()
        profile_picture = fake.image_url()
        status = fake.boolean(chance_of_getting_true=95)
        login_method = random.choice(['email', 'google', 'facebook'])
        registration_date = generate_random_date(datetime(2018, 1, 1), datetime.now())
        sql_statements.append(generate_insert_statement('customer_detail',
            ['customer_id', 'email', 'password_hash', 'first_name', 'last_name', 'phone', 'birth_date', 'gender', 'country', 'profile_picture', 'status', 'login_method', 'registration_date'],
            [customer_id, email, password_hash, first_name, last_name, phone, birth_date, gender, country, profile_picture, status, login_method, registration_date]
        ))

    # 20. customer_locations
    for customer in customers_data:
        customer_id = customer['customer_id']
        country = fake.country()
        city = fake.city()
        state = fake.state()
        zipcode = fake.postcode()
        address_line1 = fake.street_address()
        address_line2 = fake.secondary_address() if random.random() > 0.5 else None
        sql_statements.append(generate_insert_statement('customer_locations',
            ['customer_id', 'country', 'city', 'state', 'zipcode', 'address_line1', 'address_line2'],
            [customer_id, country, city, state, zipcode, address_line1, address_line2]
        ))

    # 21. orders
    for i in range(NUM_ORDERS):
        order_id = i + 1
        customer_id = random.choice(customers_data)['customer_id']
        # Ensure a product with an assigned seller exists for the order
        product = random.choice([p for p in products_data if p['seller_id'] is not None])
        seller_id = product['seller_id']
        delivery_id = random.choice(delivery_options_data)['delivery_id']
        created_at_dt = generate_random_datetime(datetime(2023, 1, 1), datetime.now())
        status = random.choice(['Processing', 'Shipping', 'Delivered', 'Cancelled'])
        
        orders_data.append({'order_id': order_id, 'customer_id': customer_id, 'seller_id': seller_id, 'delivery_id': delivery_id, 'created_at': created_at_dt, 'status': status})
        
        sql_statements.append(generate_insert_statement('orders',
            ['order_id', 'customer_id', 'seller_id', 'delivery_id', 'created_at', 'status'],
            [order_id, customer_id, seller_id, delivery_id, created_at_dt, status]
        ))

    # 22. ordered_items
    for order in orders_data:
        order_id = order['order_id']
        seller_id = order['seller_id']
        
        seller_products = [p for p in products_data if p['seller_id'] == seller_id]
        if not seller_products:
            continue
            
        num_items_for_order = random.randint(1, min(5, len(seller_products)))
        selected_asins = random.sample([p['asin'] for p in seller_products], num_items_for_order)

        for asin in selected_asins:
            quantity = random.randint(1, 3)
            added_at_dt = order['created_at'] + timedelta(minutes=random.randint(1, 60))
            last_update_dt = added_at_dt + timedelta(minutes=random.randint(0, 30))
            
            sql_statements.append(generate_insert_statement('ordered_items',
                ['order_id', 'asin', 'quantity', 'added_at', 'last_update'],
                [order_id, asin, quantity, added_at_dt, last_update_dt]
            ))

    # 23. wishlists
    for i in range(NUM_WISHLISTS):
        wishlist_id = i + 1
        customer_id = random.choice(customers_data)['customer_id']
        created_at = generate_random_datetime(datetime(2023, 1, 1), datetime.now())
        wishlists_data.append({'wishlist_id': wishlist_id, 'customer_id': customer_id})
        sql_statements.append(generate_insert_statement('wishlists', ['wishlist_id', 'customer_id', 'created_at'], [wishlist_id, customer_id, created_at]))

    # 24. wishlist_items
    for wishlist in wishlists_data:
        wishlist_id = wishlist['wishlist_id']
        num_items = random.randint(1, min(10, len(products_data)))
        selected_asins = random.sample([p['asin'] for p in products_data], num_items)
        
        for asin in selected_asins:
            added_at = generate_random_datetime(datetime(2023, 1, 1), datetime.now())
            sql_statements.append(generate_insert_statement('wishlist_items', ['wishlist_id', 'asin', 'added_at'], [wishlist_id, asin, added_at]))

    # 25. customer_reviews
    for i in range(NUM_CUSTOMER_REVIEWS):
        asin = random.choice(products_data)['asin']
        customer_id = random.choice(customers_data)['customer_id']
        rating = round(random.uniform(1.0, 5.0), 1)
        comment = fake.paragraph(nb_sentences=random.randint(1, 3)) if random.random() > 0.2 else None
        created_at = generate_random_datetime(datetime(2023, 1, 1), datetime.now())
        sql_statements.append(generate_insert_statement('customer_reviews',
            ['asin', 'customer_id', 'rating', 'comment', 'created_at'],
            [asin, customer_id, rating, comment, created_at]
        ))

    # 26. user_enquiries
    roles = ['Guess', 'Customer', 'Seller']
    genders = ['Male', 'Female']
    badges = ['Priority', 'Regular']
    for i in range(NUM_USER_ENQUIRIES):
        full_name = fake.name()
        role = random.choice(roles)
        gender = random.choice(genders)
        country = fake.country()
        region = fake.state()
        email = fake.unique.email()
        phone = generate_phone_number()
        comment = fake.paragraph(nb_sentences=2)
        badge = random.choice(badges)
        enquiry_date = generate_random_date(datetime(2023, 1, 1), datetime.now())
        sql_statements.append(generate_insert_statement('user_enquiries',
            ['full_name', 'role', 'gender', 'country', 'region', 'email', 'phone', 'comment', 'badge', 'enquiry_date'],
            [full_name, role, gender, country, region, email, phone, comment, badge, enquiry_date]
        ))

    # 27. seller_requests
    customer_ids_for_requests = random.sample([c['customer_id'] for c in customers_data], min(NUM_SELLER_REQUESTS, len(customers_data)))
    for customer_id in customer_ids_for_requests:
        request_date = generate_random_date(datetime(2023, 1, 1), datetime.now())
        status = random.choice(['pending', 'approved', 'rejected'])
        sql_statements.append(generate_insert_statement('seller_requests',
            ['customer_id', 'request_date', 'status'],
            [customer_id, request_date, status]
        ))

    # 28. admin
    for i in range(NUM_ADMINS):
        admin_id = i + 1
        email = fake.unique.email()
        phone = generate_phone_number()
        hashed_password = generate_password_hash()
        sql_statements.append(generate_insert_statement('admin',
            ['admin_id', 'email', 'phone', 'hashed_password'],
            [admin_id, email, phone, hashed_password]
        ))

    return "\n".join(sql_statements)

if __name__ == "__main__":
    print("Generating SQL INSERT statements...")
    sql_inserts = generate_data()
    with open("./data/generated_data.sql", "w") as f:
        f.write(sql_inserts)
    print("Data generation complete. Check './data/generated_data.sql' for the output.")