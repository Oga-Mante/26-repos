---Cummulative analysis
---Showing the progression of of our business over time without losing the impact of previous seasons


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