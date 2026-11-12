-- 01 DATA QUALITY CHECKS
-- Run before the analysis. Findings and how they are handled are documented in the README.

-- 1.1 Table sizes
SELECT 'customers'    AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'products',     COUNT(*) FROM products
UNION ALL SELECT 'campaigns',    COUNT(*) FROM campaigns
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions;

-- 1.2 Orders with no product (and therefore no revenue)
-- Handling: kept in the total order count, excluded from revenue, units, average order value and customer metrics.
SELECT
    COUNT(*)                                                                       AS total_orders,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END)                            AS orders_missing_product,
    CAST(100.0 * SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS pct_missing,
    SUM(CASE WHEN product_id IS NULL THEN quantity ELSE 0 END)                     AS units_on_missing_orders,
    SUM(CASE WHEN product_id IS NULL AND gross_revenue IS NOT NULL THEN 1 ELSE 0 END) AS missing_product_but_has_revenue,
    SUM(CASE WHEN product_id IS NOT NULL AND gross_revenue IS NULL THEN 1 ELSE 0 END) AS has_product_but_no_revenue
FROM transactions;

-- 1.3 Is the missing data spread evenly? (by year, with campaign and refund share)
SELECT
    YEAR([timestamp])                                                              AS order_year,
    COUNT(*)                                                                       AS orders_missing_product,
    CAST(100.0 * SUM(CASE WHEN campaign_id > 0 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS pct_with_campaign,
    CAST(100.0 * SUM(refund_flag) / COUNT(*) AS DECIMAL(5,1))                      AS pct_refund_flag
FROM transactions
WHERE product_id IS NULL
GROUP BY YEAR([timestamp])
ORDER BY order_year;

-- 1.4 Duplicate order ids
SELECT COUNT(*) - COUNT(DISTINCT transaction_id) AS duplicate_transaction_ids
FROM transactions;

-- 1.5 Orphan keys (orders pointing to rows that do not exist). Campaign 0 means no campaign.
SELECT
    (SELECT COUNT(*) FROM transactions t
      WHERE NOT EXISTS (SELECT 1 FROM customers c WHERE c.customer_id = t.customer_id))   AS orphan_customers,
    (SELECT COUNT(*) FROM transactions t
      WHERE t.product_id IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM products p WHERE p.product_id = t.product_id))      AS orphan_products,
    (SELECT COUNT(*) FROM transactions t
      WHERE t.campaign_id > 0
        AND NOT EXISTS (SELECT 1 FROM campaigns k WHERE k.campaign_id = t.campaign_id))   AS orphan_campaigns;

-- 1.6 Revenue rule: non-refunded revenue = quantity x list price x (1 - discount); refunds are the same amount, negative
SELECT
    SUM(CASE WHEN t.refund_flag = 0 AND t.gross_revenue < 0 THEN 1 ELSE 0 END)     AS negative_revenue_not_refunded,
    SUM(CASE WHEN t.refund_flag = 1 AND t.gross_revenue >= 0 THEN 1 ELSE 0 END)    AS refunded_but_not_negative,
    SUM(CASE WHEN ABS(ABS(t.gross_revenue) - t.quantity * p.base_price * (1 - t.discount_applied)) > 0.01
             THEN 1 ELSE 0 END)                                                    AS rows_not_matching_price_rule
FROM transactions t
JOIN products p ON p.product_id = t.product_id;

-- 1.7 Orders dated before the customer signed up
SELECT
    COUNT(*)                                                                       AS valid_orders,
    SUM(CASE WHEN t.[timestamp] < c.signup_date THEN 1 ELSE 0 END)                 AS orders_before_signup,
    CAST(100.0 * SUM(CASE WHEN t.[timestamp] < c.signup_date THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS pct_before_signup
FROM transactions t
JOIN customers c ON c.customer_id = t.customer_id
WHERE t.product_id IS NOT NULL;

-- 1.8 Campaign orders dated outside the campaign start and end dates is checked in 05_campaigns.sql (query 5.6).
