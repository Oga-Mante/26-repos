-------?? SQL Sales Data Integration and Analysis

----This project focuses on integrating and analyzing sales data from three relational tables: customers, products, and transactions. SQL joins were used to construct a consolidated dataset containing customer demographics, product attributes, and transaction-level revenue information.

----Data preparation steps included formatting numeric fields to standardized decimal precision and deriving new analytical features using CASE WHEN logic, such as customer age groups and revenue categories. The resulting dataset enables structured analysis of purchasing behavior, product performance, and revenue distribution across different customer segments.

-----This project demonstrates practical skills in relational database querying, data transformation, and analytical reporting using SQL.----------




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


-----Business key factors---------
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

---------Magnitude analysis
------Brand by category
select
    category,
    count(brand) Brand_count
from products
group by category
order by count(brand) desc 


-----Revenue by Country
select
    c.country,
    round(sum(t.gross_revenue),2) gross_revenue
from customers  c
    left join transactions t
    on c.customer_id = t.customer_id
    group by country
    order by count(gross_revenue) desc 




-----Revenue by category
SELECT
    p.category,
    ROUND(SUM(t.gross_revenue), 2) AS gross_revenue
FROM products p
LEFT JOIN transactions t
    ON p.product_id = t.product_id
GROUP BY p.category
ORDER BY SUM(t.gross_revenue) DESC;



-----Revenue by category
SELECT
    p.category,
    ROUND(SUM(t.gross_revenue), 2) AS gross_revenue
FROM products p
LEFT JOIN transactions t
    ON p.product_id = t.product_id
GROUP BY p.category
ORDER BY SUM(t.gross_revenue) DESC;


---Average revenue by category
SELECT
    p.category,
    ROUND(avg(t.gross_revenue), 2) AS avg_revenue
FROM products p
LEFT JOIN transactions t
    ON p.product_id = t.product_id
GROUP BY p.category
ORDER BY avg(t.gross_revenue) DESC;


--Order count by Countries
SELECT
    c.country,
    COUNT(t.transaction_id) AS order_count,
    CONCAT(
        CAST(100.0 * COUNT(t.transaction_id) / SUM(COUNT(t.transaction_id)) OVER () AS DECIMAL(5,2)),'%'
    ) AS order_percentage
FROM customers c
JOIN transactions t
    ON c.customer_id = t.customer_id
GROUP BY c.country
ORDER BY order_count DESC;



----Customer revenue with -tives
SELECT 
    c.customer_id,
    ROUND(SUM(t.gross_revenue), 2) AS gross_revenue
FROM customers c
LEFT JOIN transactions t
    ON c.customer_id = t.customer_id
    where gross_revenue is not null
GROUP BY c.customer_id
ORDER BY SUM(t.gross_revenue) DESC;



----Customer revenue fixed
SELECT
    c.customer_id,
    ROUND(SUM(COALESCE(CASE WHEN t.gross_revenue < 0 THEN 0 
       ELSE t.gross_revenue 
       END, 
 0)), 2) AS gross_revenue
FROM customers c
LEFT JOIN transactions t
    ON c.customer_id = t.customer_id
GROUP BY c.customer_id
ORDER BY SUM(
    COALESCE(CASE WHEN t.gross_revenue < 0 THEN 0 
            ELSE t.gross_revenue 
        END, 0)
) DESC;



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




-----Change over-time analysis

-----Revenue change over-time (Year)
----2021 was the best Year
select 
    year(timestamp) Order_year,
    round (sum(gross_revenue),2) Annual_rev
from transactions
group by year(timestamp)
order by Annual_rev desc


-----Revenue change over-time (Month)
---We can see that December generates the most revenue, which makes sense because of the festivities spending
SELECT 
    DATENAME(MONTH, [timestamp]) AS Order_month,
    count (distinct customer_id) as Total_customer,
    ROUND(SUM(gross_revenue), 2) AS Monthly_rev
FROM transactions
GROUP BY DATENAME(MONTH, [timestamp]), MONTH([timestamp])
ORDER BY 
    Monthly_rev DESC,
    Total_customer DESC;

--Revenue by Month,it can be seen that the company's revenue is usually high during year end which makes sense as there will likely be more purchases for the festivities--
SELECT
    FORMAT(DATETRUNC(month, t.[timestamp]), 'yyyy-MMM') AS transaction_month,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    sum (t.quantity) as total_quantity,
    CONCAT('$', CAST(SUM(t.gross_revenue) AS DECIMAL(12,2))) AS total_revenue
FROM customers c
LEFT JOIN transactions t
    ON c.customer_id = t.customer_id
WHERE t.[timestamp] IS NOT NULL
  AND t.gross_revenue IS NOT NULL
GROUP BY FORMAT(DATETRUNC(month, t.[timestamp]), 'yyyy-MMM')
ORDER BY 
    SUM(t.gross_revenue) DESC,
    COUNT(DISTINCT c.customer_id) DESC,
    sum(t.quantity);




------Year
SELECT
    YEAR(t.[timestamp]) AS transaction_year,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    SUM(t.quantity) AS total_quantity,
    CONCAT('$', CAST(SUM(t.gross_revenue) AS DECIMAL(12,2))) AS total_revenue
FROM customers c
LEFT JOIN transactions t
    ON c.customer_id = t.customer_id
WHERE t.[timestamp] IS NOT NULL
  AND t.gross_revenue IS NOT NULL
GROUP BY YEAR(t.[timestamp])
ORDER BY 
    SUM(t.gross_revenue) DESC,
    COUNT(DISTINCT c.customer_id) DESC,
    SUM(t.quantity) DESC;


---Launch date (Month and year)
SELECT
    FORMAT(DATETRUNC(month, p.launch_date), 'yyyy-MMM') AS transaction_month,
    p.brand AS brand,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    SUM(t.quantity) AS total_quantity,
    CONCAT('$', CAST(SUM(t.gross_revenue) AS DECIMAL(12,2))) AS total_revenue
FROM customers c
LEFT JOIN transactions t
    ON c.customer_id = t.customer_id
LEFT JOIN products p
    ON t.product_id = p.product_id
WHERE p.launch_date IS NOT NULL
  AND t.gross_revenue IS NOT NULL
GROUP BY 
    FORMAT(DATETRUNC(month, p.launch_date), 'yyyy-MMM'),
    p.brand
ORDER BY 
    SUM(t.gross_revenue) DESC,
    COUNT(DISTINCT c.customer_id) DESC,
    SUM(t.quantity) DESC;


---Average revenue since launch(Months)
WITH monthly_brand_revenue AS (
    SELECT
        FORMAT(DATETRUNC(month, p.launch_date), 'yyyy-MMM') AS transaction_month,
        p.brand,
        SUM(t.gross_revenue) AS monthly_revenue
    FROM customers c
    LEFT JOIN transactions t
        ON c.customer_id = t.customer_id
    LEFT JOIN products p
        ON t.product_id = p.product_id
    WHERE p.launch_date IS NOT NULL
      AND t.gross_revenue IS NOT NULL
    GROUP BY 
        FORMAT(DATETRUNC(month, p.launch_date), 'yyyy-MMM'),
        p.brand
)

SELECT
    brand,
    MIN(transaction_month) AS launch_month,
    CONCAT('$', CAST(AVG(monthly_revenue) AS DECIMAL(12,2))) AS avg_monthly_revenue
FROM monthly_brand_revenue
GROUP BY brand
ORDER BY AVG(monthly_revenue) DESC;



---Average revenue since launch(Years)
WITH yearly_brand_revenue AS (
    SELECT
        YEAR(p.launch_date) AS transaction_year,
        p.brand,
        SUM(t.gross_revenue) AS yearly_revenue
    FROM customers c
    LEFT JOIN transactions t
        ON c.customer_id = t.customer_id
    LEFT JOIN products p
        ON t.product_id = p.product_id
    WHERE p.launch_date IS NOT NULL
      AND t.gross_revenue IS NOT NULL
    GROUP BY 
        YEAR(p.launch_date),
        p.brand
)

SELECT
    brand,
    MIN(transaction_year) AS launch_year,
    CONCAT('$', CAST(AVG(yearly_revenue) AS DECIMAL(12,2))) AS avg_yearly_revenue
FROM yearly_brand_revenue
GROUP BY brand
ORDER BY AVG(yearly_revenue) DESC;



---Cummulative analysis
------ Annual running revenue
SELECT
    YEAR([timestamp]) AS year,
    CAST(SUM(gross_revenue) AS DECIMAL(12,2)) AS yearly_revenue,
    CAST(SUM(SUM(gross_revenue)) OVER (ORDER BY YEAR([timestamp])) AS DECIMAL(12,2)) AS running_total_revenue
FROM transactions
GROUP BY YEAR([timestamp])
ORDER BY year;


------ Monthly running revenue
WITH monthly_revenue AS (
    SELECT
        DATETRUNC(month, [timestamp]) AS revenue_month,
        SUM(gross_revenue) AS monthly_revenue
    FROM transactions
    WHERE gross_revenue IS NOT NULL
    GROUP BY DATETRUNC(month, [timestamp])
)
SELECT
    FORMAT(revenue_month, 'yyyy-MMM') AS revenue_month,
    CAST(monthly_revenue AS DECIMAL(12,2)) AS monthly_revenue,
    CAST(SUM(monthly_revenue) OVER ( ORDER BY revenue_month
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS DECIMAL(12,2)) AS running_total_revenue
FROM monthly_revenue
ORDER BY revenue_month;


---Annual moving Total (By Month)
WITH monthly_revenue AS (
    SELECT
        DATETRUNC(month, [timestamp]) AS revenue_month,
        SUM(gross_revenue) AS monthly_revenue
    FROM transactions
    WHERE gross_revenue IS NOT NULL
    GROUP BY DATETRUNC(month, [timestamp])
)
SELECT
    FORMAT(revenue_month, 'yyyy-MMM') AS revenue_month,
    CAST(monthly_revenue AS DECIMAL(12,2)) AS monthly_revenue,
    CAST(SUM(monthly_revenue) OVER (PARTITION BY YEAR(revenue_month)ORDER BY MONTH(revenue_month)   
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS DECIMAL(12,2)) AS running_total_revenue
FROM monthly_revenue
ORDER BY 
    YEAR(revenue_month),
    MONTH(revenue_month);  



----------------------
-----Performance anaylsis 
----(Monthly average deviation,Partitioned by Year)
WITH monthly_revenue AS (
    SELECT
        DATETRUNC(month, [timestamp]) AS revenue_month,
        SUM(gross_revenue) AS monthly_revenue
    FROM transactions
    WHERE gross_revenue IS NOT NULL
    GROUP BY DATETRUNC(month, [timestamp])
)
SELECT
    FORMAT(revenue_month, 'yyyy-MMM') AS revenue_month,
    CAST(monthly_revenue AS DECIMAL(12,2)) AS monthly_revenue,

 -- Yearly average of monthly revenue
    CAST(AVG(monthly_revenue) OVER (PARTITION BY YEAR(revenue_month))AS DECIMAL(12,2)) AS avg_monthly_revenue_in_year,

 -- Difference from yearly average
    CAST(monthly_revenue - AVG(monthly_revenue) OVER (PARTITION BY YEAR(revenue_month))AS DECIMAL(12,2)) AS diff_from_year_avg,

 -- Percentage vs yearly average (with % suffix)
    CONCAT(CAST( (monthly_revenue * 1.0 / AVG(monthly_revenue) OVER (PARTITION BY YEAR(revenue_month)) - 1) * 100AS DECIMAL(12,2) ), '%') AS pct_vs_year_avg,

 -- High / Low compared to yearly average
    CASE WHEN monthly_revenue > AVG(monthly_revenue) OVER (PARTITION BY YEAR(revenue_month)) THEN 'High' ELSE 'Low'
    END AS revenue_level
FROM monthly_revenue
ORDER BY 
    YEAR(revenue_month),
    MONTH(revenue_month);



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



-------Summarized Board-room table
SELECT 
    c.customer_id,
    t.transaction_id,
    p.product_id,
    c.age,
    c.country,
    c.gender,
    p.launch_date,
    p.category,
    p.brand,
    CAST(p.base_price AS DECIMAL(10,2)) AS base_price,
    t.quantity,
    CAST(t.gross_revenue AS DECIMAL(12,2)) AS gross_revenue,

    -- CASE WHEN conditions
    CASE 
        WHEN c.age < 25 THEN 'Young'
        WHEN c.age BETWEEN 25 AND 40 THEN 'Adult'
        ELSE 'Senior'
    END AS age_group,

    CASE 
        WHEN t.gross_revenue < 100 THEN 'Low Revenue'
        WHEN t.gross_revenue BETWEEN 100 AND 500 THEN 'Medium Revenue'
        ELSE 'High Revenue'
    END AS revenue_category,

    c.loyalty_tier

FROM customers c
JOIN transactions t
    ON c.customer_id = t.customer_id
JOIN products p
    ON t.product_id = p.product_id;



