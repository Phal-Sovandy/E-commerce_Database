# Role Privileges Summary

| Role           | Can Login? | Role Management | Database Privileges              | Schema/Table Privileges                                                                                                                                               | Can Insert Enquiries? |
|----------------|------------|-----------------|--------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------|
| **administrators** | No         | No              | ALL on `ecommercewebsite`       | ALL on all tables & sequences in `public`, plus default privileges for future tables/sequences                                                                      | No                   |
| **sellers**        | No         | No              | None                           | - `SELECT` on `products`, `product_details`, `categories`<br>- `SELECT, UPDATE` on `sellers`, `seller_detail`, `seller_locations`<br>- `INSERT, SELECT, DELETE` on `product_sellers`<br>- `SELECT` on `orders`, `ordered_items` | Yes                  |
| **customers**      | No         | No              | None                           | - `SELECT` on `products`, `product_details`, `pricing`, `media`<br>- `SELECT, UPDATE` on `customers`, `customer_detail`, `customer_locations`<br>- `SELECT, INSERT, DELETE` on `wishlists`, `wishlist_items`, `customer_reviews`<br>- `INSERT, SELECT` on `orders`, `ordered_items` | Yes                  |
| **guests**         | No         | No              | None                           | - `SELECT` on `products`, `pricing`, `media`                                                                                                                        | Yes                  |

---

### Notes:
- Group roles **do not have login privileges**; actual users inherit these roles.
- `administrators` have full database and schema control.
- `sellers` can manage their profiles, list products, view orders, and submit enquiries.
- `customers` can browse products, manage wishlists and reviews, place orders, update their profiles, and submit enquiries.
- `guests` have read-only access to public product info and can submit enquiries.

