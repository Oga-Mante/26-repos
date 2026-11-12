-- 03 DISCOUNT ANALYSIS
-- Question: do discounts increase what customers buy, or only reduce revenue?
-- Completed orders only (refund_flag = 0). Revenue = quantity x list price x (1 - discount).

-- 3.1 Orders, basket size and revenue by discount level
SELECT
    ROUND(t.discount_applied * 100, 0)                                             AS discount_pct,
    COUNT(*)                                                                       AS orders,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,1))                 AS pct_of_orders,
    CAST(AVG(CAST(t.quantity AS FLOAT)) AS DECIMAL(5,3))                           AS avg_units_per_order,
    CAST(AVG(t.gross_revenue) AS DECIMAL(10,2))                                    AS avg_order_value,
    CAST(SUM(t.quantity * p.base_price - t.gross_revenue) AS DECIMAL(14,2))        AS discount_cost
FROM transactions t
JOIN products p ON p.product_id = t.product_id
WHERE t.refund_flag = 0
GROUP BY ROUND(t.discount_applied * 100, 0)
ORDER BY discount_pct;

-- 3.2 Total cost of discounts
SELECT
    CAST(SUM(t.quantity * p.base_price - t.gross_revenue) AS DECIMAL(14,2))        AS total_discount_cost,
    CAST(100.0 * SUM(t.quantity * p.base_price - t.gross_revenue)
         / SUM(t.quantity * p.base_price) AS DECIMAL(5,2))                         AS pct_of_list_value
FROM transactions t
JOIN products p ON p.product_id = t.product_id
WHERE t.refund_flag = 0;

-- 3.3 Is discounting targeted? Average discount by category
SELECT
    p.category,
    CAST(AVG(t.discount_applied) * 100 AS DECIMAL(5,2))                            AS avg_discount_pct
FROM transactions t
JOIN products p ON p.product_id = t.product_id
WHERE t.refund_flag = 0
GROUP BY p.category
ORDER BY avg_discount_pct DESC;
