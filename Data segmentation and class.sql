
----Data segmentation and class 
--used to divide the total data set to a sets
---Customer count by segment
SELECT
    customer_segment,
    COUNT(*) AS total_customers
FROM (
    SELECT 
        customer_id,
        CASE WHEN SUM(CASE WHEN gross_revenue < 0 THEN 0
      ELSE COALESCE(gross_revenue, 0)
  END) < 200 THEN 'Low'
 WHEN SUM(CASE WHEN gross_revenue < 0 THEN 0
        ELSE COALESCE(gross_revenue, 0)
   END) BETWEEN 200 AND 500 THEN 'Medium'
 WHEN SUM(CASE 
 WHEN gross_revenue < 0 THEN 0
        ELSE COALESCE(gross_revenue, 0)
   END) BETWEEN 501 AND 1000 THEN 'High'
        ELSE 'Ultra-High'
   END AS customer_segment
FROM transactions
GROUP BY customer_id
) t
GROUP BY customer_segment
order by total_customers desc
