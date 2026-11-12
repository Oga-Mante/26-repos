----Data segmentation and class
--used to divide the total data set into groups
--Segments use each customer's net revenue (refunds subtracted). Orders without a product are excluded.
--Boundaries: Low < 200, Medium 200 to under 500, High 500 to under 1000, Ultra-High 1000 and above.

---Customer count and revenue by segment
WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(gross_revenue) AS net_revenue
    FROM transactions
    WHERE product_id IS NOT NULL
    GROUP BY customer_id
),
segmented AS (
    SELECT
        customer_id,
        net_revenue,
        CASE WHEN net_revenue < 200  THEN 'Low'
             WHEN net_revenue < 500  THEN 'Medium'
             WHEN net_revenue < 1000 THEN 'High'
             ELSE 'Ultra-High'
        END AS customer_segment
    FROM customer_revenue
)
SELECT
    customer_segment,
    COUNT(*)                                                                AS total_customers,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,1))          AS pct_of_buyers,
    CAST(SUM(net_revenue) AS DECIMAL(14,2))                                 AS net_revenue,
    CAST(100.0 * SUM(net_revenue) / SUM(SUM(net_revenue)) OVER () AS DECIMAL(5,1)) AS pct_of_revenue
FROM segmented
GROUP BY customer_segment
ORDER BY total_customers DESC;
