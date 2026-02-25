-----Change over-time analysis
-----This is very important because it helps Us to answer relevant business questions such as the most important and profitable seasons
----so as to help the top management team plan ahead of time to take advantge to market boom seasons.
-----It also helps answer questions such as why is this year more profitable than the other year and how or what can we do to increase our  returns 


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
