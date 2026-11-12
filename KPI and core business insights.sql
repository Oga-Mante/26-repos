-- KPI SUMMARY
-- Definitions:
--   Refunded orders are stored as NEGATIVE revenue, so SUM(gross_revenue) is already net of refunds.
--   "Valid orders" = orders that have a product (10,449 orders have no product or revenue).

-- 1. Revenue
SELECT
    CAST(SUM(CASE WHEN refund_flag = 0 THEN gross_revenue END) AS DECIMAL(14,2)) AS sales_before_refunds,
    CAST(SUM(CASE WHEN refund_flag = 1 THEN gross_revenue END) AS DECIMAL(14,2)) AS refunds,
    CAST(SUM(gross_revenue) AS DECIMAL(14,2))                                   AS net_revenue
FROM transactions
WHERE product_id IS NOT NULL;

-- 2. Orders
SELECT
    COUNT(*)                                                                    AS total_orders,
    SUM(CASE WHEN product_id IS NOT NULL THEN 1 ELSE 0 END)                     AS valid_orders,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END)                         AS orders_missing_product,
    SUM(CASE WHEN product_id IS NOT NULL AND refund_flag = 1 THEN 1 ELSE 0 END) AS refunded_orders,
    CAST(100.0 * SUM(CASE WHEN product_id IS NOT NULL THEN refund_flag END)
         / NULLIF(SUM(CASE WHEN product_id IS NOT NULL THEN 1 END), 0) AS DECIMAL(5,2)) AS refund_rate_pct
FROM transactions;

-- 3. Customers and catalogue
SELECT
    (SELECT COUNT(*) FROM customers)                                             AS registered_customers,
    (SELECT COUNT(DISTINCT customer_id) FROM transactions
      WHERE product_id IS NOT NULL)                                              AS active_customers,
    (SELECT COUNT(*) FROM products)                                              AS products,
    (SELECT COUNT(DISTINCT category) FROM products)                              AS categories;

-- 4. Units, average selling price and average order value
SELECT
    SUM(CASE WHEN t.refund_flag = 0 THEN t.quantity END)                         AS units_sold,
    CAST(SUM(CASE WHEN t.refund_flag = 0 THEN t.gross_revenue END)
         / NULLIF(SUM(CASE WHEN t.refund_flag = 0 THEN t.quantity END), 0)
         AS DECIMAL(10,2))                                                       AS avg_selling_price_per_unit,
    CAST(AVG(p.base_price) AS DECIMAL(10,2))                                     AS avg_list_price_catalogue,
    CAST(SUM(t.gross_revenue) / COUNT(*) AS DECIMAL(10,2))                       AS avg_order_value_net
FROM transactions t
JOIN products p ON p.product_id = t.product_id;

-- 5. Cost of discounts (list price minus price paid, completed orders only)
SELECT
    CAST(SUM(t.quantity * p.base_price - t.gross_revenue) AS DECIMAL(14,2))      AS discount_cost,
    CAST(100.0 * SUM(t.quantity * p.base_price - t.gross_revenue)
         / SUM(t.quantity * p.base_price) AS DECIMAL(5,2))                       AS discount_pct_of_list
FROM transactions t
JOIN products p ON p.product_id = t.product_id
WHERE t.refund_flag = 0;-----
