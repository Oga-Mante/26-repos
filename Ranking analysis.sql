
-------Ranking analysis
-----This is usde to rank or show the best or worst performing dmensions to know where to invest more and aalso know how to enter 
----those markets more efficiently as well as know when and how best to cut down or expand, send loyalty bonuses and others... 

-----Revenue by Country
select top 3
    c.country,
    round(sum(t.gross_revenue),2) gross_revenue
from customers  c
    left join transactions t
    on c.customer_id = t.customer_id
    group by country
    order by count(gross_revenue) desc 

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
