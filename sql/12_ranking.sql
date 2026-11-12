-------Ranking analysis
-----This is used to rank or show the best or worst performing dimensions to know where to invest more and also know how to enter
----those markets more efficiently as well as know when and how best to cut down or expand, send loyalty bonuses and others...
-----Net revenue = SUM(gross_revenue), already after refunds (refunds are stored as negative revenue).
-----Orders without a product have no revenue and are excluded.

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


--Loyalty levels by number of customers
SELECT
    loyalty_tier,
    COUNT(*) AS total_customers
FROM customers
GROUP BY loyalty_tier
ORDER BY total_customers DESC;


---Top 10 customers by net revenue (refunds subtracted)
SELECT TOP 10
    c.customer_id,
    ROUND(SUM(t.gross_revenue), 2) AS net_revenue
FROM customers c
JOIN transactions t
    ON c.customer_id = t.customer_id
WHERE t.product_id IS NOT NULL
GROUP BY c.customer_id
ORDER BY SUM(t.gross_revenue) DESC;
