
create view Summary_report as (
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
    ON t.product_id = p.product_id);




select *
from Summary_report