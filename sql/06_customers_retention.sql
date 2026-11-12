-- 06 CUSTOMER AND RETENTION ANALYSIS
-- Valid orders only (orders with a product). Net revenue = SUM(gross_revenue).

-- 6.1 How many customers buy, and how many come back?
WITH customer_orders AS (
    SELECT customer_id, COUNT(*) AS orders, SUM(gross_revenue) AS revenue
    FROM transactions
    WHERE product_id IS NOT NULL
    GROUP BY customer_id
)
SELECT
    (SELECT COUNT(*) FROM customers)                                               AS registered_customers,
    COUNT(*)                                                                       AS buyers,
    (SELECT COUNT(*) FROM customers) - COUNT(*)                                    AS never_bought,
    SUM(CASE WHEN orders >= 2 THEN 1 ELSE 0 END)                                   AS repeat_buyers,
    CAST(100.0 * SUM(CASE WHEN orders >= 2 THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS repeat_buyer_pct,
    CAST(100.0 * SUM(CASE WHEN orders >= 2 THEN revenue END) / SUM(revenue) AS DECIMAL(5,1)) AS revenue_from_repeat_pct
FROM customer_orders;

-- 6.2 Revenue concentration: share of revenue from the top 10% and top 20% of buyers
WITH customer_revenue AS (
    SELECT customer_id, SUM(gross_revenue) AS revenue
    FROM transactions
    WHERE product_id IS NOT NULL
    GROUP BY customer_id
),
ranked AS (
    SELECT revenue, NTILE(10) OVER (ORDER BY revenue DESC) AS decile
    FROM customer_revenue
)
SELECT
    CAST(100.0 * SUM(CASE WHEN decile = 1 THEN revenue END) / SUM(revenue) AS DECIMAL(5,1))  AS top10_pct_share,
    CAST(100.0 * SUM(CASE WHEN decile <= 2 THEN revenue END) / SUM(revenue) AS DECIMAL(5,1)) AS top20_pct_share
FROM ranked;

-- 6.3 Loyalty tiers: who buys, how often, how much
SELECT
    c.loyalty_tier,
    COUNT(DISTINCT c.customer_id)                                                  AS registered_customers,
    COUNT(DISTINCT t.customer_id)                                                  AS buyers,
    CAST(100.0 * COUNT(DISTINCT t.customer_id) / COUNT(DISTINCT c.customer_id) AS DECIMAL(5,1)) AS buyer_rate_pct,
    CAST(1.0 * COUNT(t.transaction_id) / COUNT(DISTINCT t.customer_id) AS DECIMAL(5,2))         AS orders_per_buyer,
    CAST(SUM(t.gross_revenue) / COUNT(DISTINCT t.customer_id) AS DECIMAL(10,2))                 AS revenue_per_buyer,
    CAST(SUM(t.gross_revenue) AS DECIMAL(14,2))                                                 AS net_revenue
FROM customers c
LEFT JOIN transactions t
       ON t.customer_id = c.customer_id AND t.product_id IS NOT NULL
GROUP BY c.loyalty_tier
ORDER BY revenue_per_buyer DESC;

-- 6.4 Acquisition channel: revenue per registered customer
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id)                                                  AS registered_customers,
    CAST(SUM(t.gross_revenue) AS DECIMAL(14,2))                                    AS net_revenue,
    CAST(SUM(t.gross_revenue) / COUNT(DISTINCT c.customer_id) AS DECIMAL(10,2))    AS revenue_per_customer
FROM customers c
LEFT JOIN transactions t
       ON t.customer_id = c.customer_id AND t.product_id IS NOT NULL
GROUP BY c.acquisition_channel
ORDER BY revenue_per_customer DESC;
