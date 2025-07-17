# Database Perfomance (Before & After applying indexes)

---

## 🕶️ View-Based Query Performance

| No. | Query Description                     | Index Used? | Execution Time (Before) | Execution Time (After) | 
| --- | ------------------------------------- | ----------- | ----------------------- | ---------------------- | 
| 1   | Top 10 Expensive Products (View)      | ✅     | `65.025 ms`             | `0.66 ms`              | 
| 2   | Products with No Orders (View)        | ✅     | `12.449 ms`             | `0.894 ms`             | 
| 3   | View: `top_sellers_by_total_sales`    | ✅     | `34.750 ms`             | `32.455 ms`            | 
| 4   | View: `products_priced_above_average` | ✅     | `58.274 ms`             | `24.45 ms`             |

---

## 🧮 Function-Based Query Performance

| No. | Query Description                      | Index Used? | Execution Time (Before) | Execution Time (After) | 
| --- | -------------------------------------- | ----------- | ----------------------- | ---------------------- | 
| 5   | `get_top_selling_products(10)`         | ✅     | `22.782 ms`             | `18.136 ms`            |
| 6   | `get_product_summary('ASIN')`          | ✅     | `1.011 ms`              | `0.191 ms`             | 
| 7   | `get_customer_order_history(1)`        | ✅     | `2.793 ms`              | `0.348 ms`             | 
| 8   | `get_products_by_category('Category')` | ✅     | `14.531 ms`             | `4.237 ms`            |

---

## 🧾 Raw SQL Queries Performance

| No. | Query Description                           | Index Used? | Execution Time (Before) | Execution Time (After) |
| --- | ------------------------------------------- | ----------- | ----------------------- | ---------------------- |
| 9   | `SELECT COUNT(*) FROM products`             | ❌         | `18.836 ms`             | _            |
| 10  | `SELECT COUNT(*) FROM orders`               | ❌          | `2.234 ms`              | _                | 
| 11  | `SELECT COUNT(*) FROM customers`            | ❌          | `2.320 ms`              | _                       | 
| 12  | Join: products + brands + pricing + details | ✅     | `75.575 ms`             | `74.895 ms`               | 
| 13  | Top Sellers with Total Sales and Orders     | ✅     | `47.307 ms`             | `43.002 ms`               | 
| 14  | Avg Product Rating per Department           | ✅     | `53.325 ms`             | `50.863 ms`               | 
| 15  | Top Customers: Last Order + Total Spent     | ✅     | `61.818 ms`             | `58.183 ms`               | 

---

## 🏎️ Index Usage & Optimization Testing

| No. | Query Description                        | Index Used? | Execution Time (Before) | Execution Time (After) | 
| --- | ---------------------------------------- | ----------- | ----------------------- | ---------------------- |
| 16  | Product by ASIN (`WHERE asin = '...'`)   | ✅     | `0.0667 ms`             | `0.045 ms`               | 
| 17  | Customer Orders sorted by time           | ✅     | `1.638 ms`              | `0.080 ms`               |
| 18  | JOIN + Filters + Sort (ANALYZE, BUFFERS) | ✅     | `34.720 ms`             | `0.407 ms`               |
