---------Part to whole analysis
----Contribution of each category quantity and revenue to the total quantity and revenue
SELECT
    p.category,
    SUM(t.quantity) AS category_quantity,
    CONCAT(CAST(SUM(t.quantity) * 1.0 / SUM(SUM(t.quantity)) OVER () * 100 AS DECIMAL(10,2)),'%') AS pct_of_total_quantity,
    CAST(SUM(t.gross_revenue) AS DECIMAL(12,2)) AS category_gross_revenue,
    CONCAT(CAST(SUM(t.gross_revenue) * 1.0/ SUM(SUM(t.gross_revenue)) OVER () * 100 AS DECIMAL(10,2)), '%') AS pct_of_total_gross_revenue
FROM products p
JOIN transactions t
    ON p.product_id = t.product_id
GROUP BY p.category
ORDER BY category_gross_revenue DESC;



-----Customer classification based on revenue generated
WITH customer_revenue AS (
SELECT 
customer_id,
    CAST(SUM(CASE WHEN gross_revenue < 0 THEN 0
   ELSE COALESCE(gross_revenue, 0)
 END) AS DECIMAL(12,2)) AS revenue_by_customer,
    CAST(MIN([timestamp]) AS DATE) AS first_order_date,
    CAST(MAX([timestamp]) AS DATE) AS last_order_date,
    DATEDIFF( month, MIN([timestamp]), MAX([timestamp])) AS active_duration_months
FROM transactions
GROUP BY customer_id
)
SELECT
    customer_id,
    revenue_by_customer,
    first_order_date,
    last_order_date,
    active_duration_months,
 CASE 
        WHEN revenue_by_customer < 200 THEN 'Low'
        WHEN revenue_by_customer BETWEEN 200 AND 500 THEN 'Medium'
        WHEN revenue_by_customer BETWEEN 501 AND 1000 THEN 'High'
        ELSE 'Ultra-High'
    END AS customer_segment
FROM customer_revenue
ORDER BY revenue_by_customer DESC;
