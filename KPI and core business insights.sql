-----Business key factors and KPI indicators---------
----Total revenue---
Select 
    sum (gross_revenue) Total_revenue
from transactions

---Items sold
select 
    distinct (category)
from products

---Average selling price by category
select
    category,
    avg(base_price)
from products
group by category


---Average selling price 
select
    avg(base_price) avg_price
from products



---Total transaction (orders)
select
    count(transaction_id) Total_orders,
    count(distinct transaction_id) Total_orders
from transactions

---Total quantity
select 
    sum(quantity) Total_quantity
from transactions


---Total number of customers
select 
    count (customer_id) All_customers,
    count (distinct customer_id) All_customers
from customers



---Total number of customers
select 
    count (customer_id) [Active customers] 
from transactions



---Key insights summarized--
SELECT 'Total_revenue' AS measure_name, CONCAT('$', CAST(SUM(gross_revenue) AS DECIMAL(18,2))) AS measure_value FROM transactions
UNION ALL
SELECT 'Total nr of category' AS measure_name, CAST(COUNT(DISTINCT category) AS VARCHAR(50)) AS measure_value FROM products
UNION ALL
SELECT 'Average price' AS measure_name, CONCAT('$', CAST(ROUND(AVG(base_price), 2) AS DECIMAL(18,2))) AS measure_value FROM products
UNION ALL
SELECT 'Total order' AS measure_name, CAST(COUNT(transaction_id) AS VARCHAR(50)) AS measure_value FROM transactions
UNION ALL 
SELECT 'Total_qtny' AS measure_name, CAST(SUM(quantity) AS VARCHAR(50)) AS measure_value FROM transactions
UNION ALL
SELECT 'Nr of Customers' AS measure_name, CAST(COUNT(DISTINCT customer_id) AS VARCHAR(50)) AS measure_value FROM customers
UNION ALL
SELECT 'Active customers' AS measure_name, CAST(COUNT(customer_id) AS VARCHAR(50)) AS measure_value FROM transactions;
---------------------------------------------------
