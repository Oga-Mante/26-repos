-- 15 SUPPORTING FINDINGS
-- Queries behind README figures that are not covered by the other scripts.
-- Net revenue = SUM(gross_revenue), already after refunds. Valid orders only (orders with a product).

-- 15.1 Revenue and orders by year, with year-on-year change
WITH yearly AS (
    SELECT
        YEAR([timestamp])                  AS order_year,
        COUNT(*)                           AS orders,
        SUM(gross_revenue)                 AS net_revenue
    FROM transactions
    WHERE product_id IS NOT NULL
    GROUP BY YEAR([timestamp])
)
SELECT
    order_year,
    orders,
    CAST(net_revenue AS DECIMAL(14,2))                                             AS net_revenue,
    CAST(100.0 * (net_revenue - LAG(net_revenue) OVER (ORDER BY order_year))
         / LAG(net_revenue) OVER (ORDER BY order_year) AS DECIMAL(5,2))            AS revenue_change_pct,
    CAST(net_revenue / orders AS DECIMAL(10,2))                                    AS avg_order_value
FROM yearly
ORDER BY order_year;

-- 15.2 Seasonality: share of annual revenue from November and December, and the best and worst months
WITH monthly AS (
    SELECT MONTH([timestamp]) AS month_no, SUM(gross_revenue) AS net_revenue
    FROM transactions
    WHERE product_id IS NOT NULL
    GROUP BY MONTH([timestamp])
)
SELECT
    CAST(100.0 * SUM(CASE WHEN month_no IN (11, 12) THEN net_revenue END) / SUM(net_revenue) AS DECIMAL(5,1)) AS nov_dec_pct_of_revenue,
    MAX(CASE WHEN month_no = 12 THEN CAST(net_revenue AS DECIMAL(14,0)) END)       AS december_revenue,
    MAX(CASE WHEN month_no = 2  THEN CAST(net_revenue AS DECIMAL(14,0)) END)       AS february_revenue
FROM monthly;

-- 15.3 Premium vs standard products
SELECT
    CASE WHEN p.is_premium = 1 THEN 'Premium' ELSE 'Standard' END                  AS product_type,
    COUNT(*)                                                                       AS orders,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,1))                 AS pct_of_orders,
    CAST(SUM(t.gross_revenue) AS DECIMAL(14,2))                                    AS net_revenue,
    CAST(100.0 * SUM(t.gross_revenue) / SUM(SUM(t.gross_revenue)) OVER () AS DECIMAL(5,1)) AS pct_of_revenue,
    CAST(AVG(t.gross_revenue) AS DECIMAL(10,2))                                    AS avg_order_value
FROM transactions t
JOIN products p ON p.product_id = t.product_id
GROUP BY CASE WHEN p.is_premium = 1 THEN 'Premium' ELSE 'Standard' END;

-- 15.4 Orders and average order value by category
SELECT
    p.category,
    COUNT(*)                                                                       AS orders,
    CAST(AVG(t.gross_revenue) AS DECIMAL(10,2))                                    AS avg_order_value
FROM transactions t
JOIN products p ON p.product_id = t.product_id
GROUP BY p.category
ORDER BY orders DESC;

-- 15.5 Orders, revenue share and average order value by country
SELECT
    c.country,
    COUNT(*)                                                                       AS orders,
    CAST(100.0 * SUM(t.gross_revenue) / SUM(SUM(t.gross_revenue)) OVER () AS DECIMAL(5,1)) AS pct_of_revenue,
    CAST(AVG(t.gross_revenue) AS DECIMAL(10,2))                                    AS avg_order_value
FROM transactions t
JOIN customers c ON c.customer_id = t.customer_id
WHERE t.product_id IS NOT NULL
GROUP BY c.country
ORDER BY pct_of_revenue DESC;
