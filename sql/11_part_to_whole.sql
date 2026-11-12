---------Part to whole analysis
----Contribution of each category's quantity and revenue to the total quantity and revenue
----Quantity = units sold on completed orders (refunded orders excluded). Revenue = net revenue (refunds subtracted).
----Orders without a product are excluded.
SELECT
    p.category,
    SUM(CASE WHEN t.refund_flag = 0 THEN t.quantity ELSE 0 END)                           AS category_quantity,
    CONCAT(CAST(100.0 * SUM(CASE WHEN t.refund_flag = 0 THEN t.quantity ELSE 0 END)
          / SUM(SUM(CASE WHEN t.refund_flag = 0 THEN t.quantity ELSE 0 END)) OVER () AS DECIMAL(10,2)), '%') AS pct_of_total_quantity,
    CAST(SUM(t.gross_revenue) AS DECIMAL(12,2))                                           AS category_net_revenue,
    CONCAT(CAST(100.0 * SUM(t.gross_revenue) / SUM(SUM(t.gross_revenue)) OVER () AS DECIMAL(10,2)), '%') AS pct_of_total_net_revenue
FROM products p
JOIN transactions t
    ON p.product_id = t.product_id
GROUP BY p.category
ORDER BY category_net_revenue DESC;


-----Customer classification based on net revenue
WITH customer_revenue AS (
    SELECT
        customer_id,
        CAST(SUM(gross_revenue) AS DECIMAL(12,2)) AS revenue_by_customer,
        CAST(MIN([timestamp]) AS DATE)            AS first_order_date,
        CAST(MAX([timestamp]) AS DATE)            AS last_order_date,
        DATEDIFF(MONTH, MIN([timestamp]), MAX([timestamp])) AS active_duration_months
    FROM transactions
    WHERE product_id IS NOT NULL
    GROUP BY customer_id
)
SELECT
    customer_id,
    revenue_by_customer,
    first_order_date,
    last_order_date,
    active_duration_months,
    CASE WHEN revenue_by_customer < 200  THEN 'Low'
         WHEN revenue_by_customer < 500  THEN 'Medium'
         WHEN revenue_by_customer < 1000 THEN 'High'
         ELSE 'Ultra-High'
    END AS customer_segment
FROM customer_revenue
ORDER BY revenue_by_customer DESC;
