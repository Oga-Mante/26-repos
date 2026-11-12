-- 05 CAMPAIGN ANALYSIS
-- campaign_id = 0 means the order is not linked to a campaign.
-- Net revenue = SUM(gross_revenue), already after refunds. Valid orders only.

-- 5.1 Orders with a campaign vs without
SELECT
    CASE WHEN campaign_id > 0 THEN 'With campaign' ELSE 'No campaign' END          AS order_type,
    COUNT(*)                                                                       AS orders,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,1))                 AS pct_of_orders,
    CAST(AVG(gross_revenue) AS DECIMAL(10,2))                                      AS avg_order_value,
    CAST(AVG(discount_applied) * 100 AS DECIMAL(5,2))                              AS avg_discount_pct
FROM transactions
WHERE product_id IS NOT NULL
GROUP BY CASE WHEN campaign_id > 0 THEN 'With campaign' ELSE 'No campaign' END;

-- 5.2 Performance by channel
SELECT
    c.channel,
    COUNT(DISTINCT c.campaign_id)                                                  AS campaigns,
    COUNT(*)                                                                       AS orders,
    CAST(SUM(t.gross_revenue) AS DECIMAL(14,2))                                    AS net_revenue,
    CAST(SUM(t.gross_revenue) / COUNT(DISTINCT c.campaign_id) AS DECIMAL(14,2))    AS revenue_per_campaign,
    CAST(AVG(t.gross_revenue) AS DECIMAL(10,2))                                    AS avg_order_value
FROM transactions t
JOIN campaigns c ON c.campaign_id = t.campaign_id
WHERE t.product_id IS NOT NULL
GROUP BY c.channel
ORDER BY revenue_per_campaign DESC;

-- 5.3 Performance by objective
SELECT
    c.objective,
    COUNT(DISTINCT c.campaign_id)                                                  AS campaigns,
    COUNT(*)                                                                       AS orders,
    CAST(SUM(t.gross_revenue) AS DECIMAL(14,2))                                    AS net_revenue,
    CAST(SUM(t.gross_revenue) / COUNT(DISTINCT c.campaign_id) AS DECIMAL(14,2))    AS revenue_per_campaign
FROM transactions t
JOIN campaigns c ON c.campaign_id = t.campaign_id
WHERE t.product_id IS NOT NULL
GROUP BY c.objective
ORDER BY revenue_per_campaign DESC;

-- 5.4 Campaign ranking with planned uplift
WITH campaign_results AS (
    SELECT
        c.campaign_id, c.channel, c.objective, c.target_segment, c.expected_uplift,
        COUNT(*)                                                                   AS orders,
        SUM(t.gross_revenue)                                                       AS net_revenue
    FROM transactions t
    JOIN campaigns c ON c.campaign_id = t.campaign_id
    WHERE t.product_id IS NOT NULL
    GROUP BY c.campaign_id, c.channel, c.objective, c.target_segment, c.expected_uplift
)
SELECT
    RANK() OVER (ORDER BY net_revenue DESC)                                        AS revenue_rank,
    campaign_id, channel, objective, target_segment, expected_uplift,
    orders,
    CAST(net_revenue AS DECIMAL(14,2))                                             AS net_revenue
FROM campaign_results
ORDER BY revenue_rank;

-- 5.5 Do orders per campaign follow the planned uplift? (top 5 vs bottom 5)
WITH campaign_orders AS (
    SELECT c.campaign_id, c.expected_uplift, COUNT(*) AS orders
    FROM transactions t
    JOIN campaigns c ON c.campaign_id = t.campaign_id
    WHERE t.product_id IS NOT NULL
    GROUP BY c.campaign_id, c.expected_uplift
),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY expected_uplift DESC) AS rn_high,
           ROW_NUMBER() OVER (ORDER BY expected_uplift ASC)  AS rn_low
    FROM campaign_orders
)
SELECT
    CAST(AVG(CASE WHEN rn_high <= 5 THEN CAST(orders AS FLOAT) END) AS DECIMAL(10,0)) AS avg_orders_top5_uplift,
    CAST(AVG(CASE WHEN rn_low  <= 5 THEN CAST(orders AS FLOAT) END) AS DECIMAL(10,0)) AS avg_orders_bottom5_uplift
FROM ranked;

-- 5.6 Data check: campaign orders dated outside the campaign start and end dates
SELECT
    COUNT(*)                                                                       AS campaign_orders,
    SUM(CASE WHEN t.[timestamp] < c.start_date
              OR t.[timestamp] >= DATEADD(DAY, 1, c.end_date) THEN 1 ELSE 0 END)   AS outside_window,
    CAST(100.0 * SUM(CASE WHEN t.[timestamp] < c.start_date
              OR t.[timestamp] >= DATEADD(DAY, 1, c.end_date) THEN 1 ELSE 0 END)
         / COUNT(*) AS DECIMAL(5,1))                                               AS pct_outside_window
FROM transactions t
JOIN campaigns c ON c.campaign_id = t.campaign_id
WHERE t.product_id IS NOT NULL;
