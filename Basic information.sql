--Average price per category
select 
    CAST(avg(base_price) AS DECIMAL(10,2)) AS avg_price,
    category
from products
group by category
ORDER BY avg_price DESC


--Total price by category
select 
    CAST(sum(base_price) AS DECIMAL(10,2)) AS total_price,
    category
from products
group by category
ORDER BY total_price DESC


--Purchase methods by customers
select 
    c.customer_id,
    c.country,
    e.event_type
from events as e
    left join customers as c
    on c.customer_id = e.customer_id


--CUSTOMER COUNTRY
SELECT 
    c.customer_id,
    c.country,
    e.event_type
FROM customers AS c          
    LEFT JOIN events AS e
    ON c.customer_id = e.customer_id


--Order count by Countries
 SELECT 
    c.country,
    COUNT(DISTINCT c.customer_id) AS customer_count
FROM customers AS c
    LEFT JOIN events AS e
    ON c.customer_id = e.customer_id
WHERE e.customer_id IS NOT NULL
GROUP BY c.country
order by customer_count desc



WITH customer_products AS (
    SELECT
        e.customer_id,
        p.category,
        p.base_price
    FROM events e
    JOIN products p
        ON e.product_id = p.product_id
)
SELECT
    c.customer_id,
    c.country,
    cp.category,
    cp.base_price
FROM customers c
LEFT JOIN customer_products cp
    ON c.customer_id = cp.customer_id


    --Basic info
SELECT
    c.customer_id,
    c.country,
    c.age,
    p.category,
    p.base_price
FROM customers c
LEFT JOIN events e
    ON c.customer_id = e.customer_id
LEFT JOIN products p
    ON e.product_id = p.product_id

---Customer gender distribution without 'others'
select
    gender,
    count(customer_id) as customers_gender
from customers
where gender != 'other'
group by gender
order by customers_gender desc


---Customer gender distribution 
select
    gender,
    count(customer_id) as customers_gender
from customers
group by gender
order by customers_gender desc



--Loyalty levels by numbers
SELECT 
    loyalty_tier,
    COUNT(*) AS total_customers
FROM customers
GROUP BY loyalty_tier
ORDER BY total_customers DESC


select 
  FORMAT(DATETRUNC(month, [timestamp]), 'yyyy-MMM-dd') transaction_time
from transactions


--Revenue by Month,it can be seen that the company's revenue is usually high during year end which makes sense as there will likely be more purchases for the festivities--
SELECT
    FORMAT(DATETRUNC(month, t.[timestamp]), 'yyyy-MMM') AS transaction_month,
    CONCAT('$', CAST(SUM(t.gross_revenue) AS DECIMAL(12,2))) AS total_revenue
FROM customers c
LEFT JOIN transactions t
    ON c.customer_id = t.customer_id
WHERE t.[timestamp] IS NOT NULL
  AND t.gross_revenue IS NOT NULL
GROUP BY FORMAT(DATETRUNC(month, t.[timestamp]), 'yyyy-MMM')
ORDER BY CAST(SUM(t.gross_revenue) AS DECIMAL(12,2)) DESC



--Business lifespan insightselect *
SELECT 
    CONVERT(date, MIN([timestamp])) AS FirstOrder,
    CONVERT(date, MAX([timestamp])) AS LastOrder,
    DATEDIFF(MONTH, MIN([timestamp]), MAX([timestamp])) AS [Busiess age]
FROM transactions;