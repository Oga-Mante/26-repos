
-------Ranking analysis
-----This is usde to rank or show the best or worst performing dmensions to know where to invest more and aalso know how to enter 
----those markets more efficiently as well as know when and how best to cut down or expand, send loyalty bonuses and others... 

-----Top 3 countries by net revenue
SELECT TOP 3
    c.country,
    ROUND(SUM(t.gross_revenue), 2) AS net_revenue
FROM customers c
JOIN transactions t
    ON c.customer_id = t.customer_id
WHERE t.product_id IS NOT NULL
GROUP BY c.country
ORDER BY SUM(t.gross_revenue) DESC;

--Loyalty levels by numbers
SELECT top 3
    loyalty_tier,
    COUNT(*) AS total_customers
FROM customers
GROUP BY loyalty_tier
ORDER BY total_customers DESC


---Most loyal customers
SELECT top 10
    c.customer_id,
    ROUND(SUM(COALESCE(CASE WHEN t.gross_revenue < 0 THEN 0 ELSE t.gross_revenue END, 0)), 2) AS gross_revenue
FROM customers c
LEFT JOIN transactions t
    ON c.customer_id = t.customer_id
GROUP BY c.customer_id
ORDER BY SUM(COALESCE(CASE WHEN t.gross_revenue < 0 THEN 0 ELSE t.gross_revenue END, 0)) DESC;
