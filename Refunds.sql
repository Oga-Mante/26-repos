-- 04 REFUND ANALYSIS
-- Refunded orders are stored with refund_flag = 1 and NEGATIVE revenue.
-- Orders without a product (no revenue) are excluded.

-- 4.1 Overall refund rate and value
SELECT
    COUNT(*)                                                                       AS valid_orders,
    SUM(refund_flag)                                                               AS refunded_orders,
    CAST(100.0 * SUM(refund_flag) / COUNT(*) AS DECIMAL(5,2))                      AS refund_rate_pct,
    CAST(SUM(CASE WHEN refund_flag = 1 THEN gross_revenue END) AS DECIMAL(14,2))   AS refund_value
FROM transactions
WHERE product_id IS NOT NULL;

-- 4.2 Refund rate by category
SELECT
    p.category,
    COUNT(*)                                                                       AS orders,
    SUM(t.refund_flag)                                                             AS refunded_orders,
    CAST(100.0 * SUM(t.refund_flag) / COUNT(*) AS DECIMAL(5,2))                    AS refund_rate_pct,
    CAST(SUM(CASE WHEN t.refund_flag = 1 THEN t.gross_revenue END) AS DECIMAL(14,2)) AS refund_value
FROM transactions t
JOIN products p ON p.product_id = t.product_id
GROUP BY p.category
ORDER BY refund_value;

-- 4.3 Refund rate by country
SELECT
    c.country,
    COUNT(*)                                                                       AS orders,
    CAST(100.0 * SUM(t.refund_flag) / COUNT(*) AS DECIMAL(5,2))                    AS refund_rate_pct
FROM transactions t
JOIN customers c ON c.customer_id = t.customer_id
WHERE t.product_id IS NOT NULL
GROUP BY c.country
ORDER BY refund_rate_pct DESC;

-- 4.4 Refund rate by discount level (do discounted orders come back more often?)
SELECT
    ROUND(discount_applied * 100, 0)                                               AS discount_pct,
    COUNT(*)                                                                       AS orders,
    CAST(100.0 * SUM(refund_flag) / COUNT(*) AS DECIMAL(5,2))                      AS refund_rate_pct
FROM transactions
WHERE product_id IS NOT NULL
GROUP BY ROUND(discount_applied * 100, 0)
ORDER BY discount_pct;
