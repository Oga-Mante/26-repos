----------------------
-----Performance anaylsis 
---Use to compare the current to a target set maybe the average or max or min of a set or general report

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