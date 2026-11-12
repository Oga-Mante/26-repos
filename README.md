# E-Commerce Sales and Campaign Analysis (SQL Server)

SQL analysis of three years of online sales: what drives revenue, whether discounts and campaigns pay off, and which customers matter most.

## Headline
Net revenue was $8.37M over 2021 to 2023 and is flat to slightly declining (down 1.7% from 2021 to 2023). Electronics and premium products drive most of it, discounts cost $373K without lifting basket size, and campaign tracking is too unreliable to justify moving budget.

## Dataset
Marketing & E-Commerce Analytics Dataset by geethasagarbonthu (Kaggle), CC0 1.0 Universal.
https://www.kaggle.com/datasets/geethasagarbonthu/marketing-and-e-commerce-analytics-dataset
The data is synthetic, so the findings demonstrate analysis technique and are not evidence of real business performance.

Tables used (in the Raw folder): customers (100,000 rows), products (2,000), campaigns (50), transactions (103,127).
The events table (2,000,000 rows) is too large for GitHub and is not used.

## Business Questions
1. How much revenue does the business make, and is it growing?
2. When do customers buy? Is there seasonality?
3. Which categories, products and countries drive revenue?
4. Do discounts increase what customers buy, or only reduce revenue?
5. Which marketing campaigns and channels perform best?
6. Which customers are most valuable, and how many come back?
7. How reliable is the data?

## Key Findings

Revenue and growth
- Net revenue was $8.37M: $8.63M from completed orders, less $256K from 2,704 refunded orders (2.9% of valid orders). Refunds are stored as negative revenue.
- Revenue by year: $2.82M (2021), $2.79M (2022, down 1.1%), $2.77M (2023, down 0.5%). Orders barely moved (31,105 to 30,912) and average order value held near $90, so growth would have to come from order volume.

Seasonality
- November and December bring 20.6% of annual revenue. December is the peak ($876K) and February the low ($623K).

Products and markets
- Electronics generate 41.2% of revenue, then Home (23.8%), Fashion (15.5%), Sports (11.5%), Beauty (4.4%) and Grocery (3.5%).
- Premium products make 77% of revenue from 50% of orders. Their average order is $139 against $42 for standard products.
- Grocery has more orders than Sports (14,431 against 10,168) but only 3.5% of revenue, because its average order is $20.
- The US brings 35.2% of revenue, India 20.1%, UK 10.1%, Brazil 10.0%, Canada 9.8%, Germany 7.8% and Australia 7.1%. Average order value is $89 to $92 in every country, so differences between countries come from order volume, not basket size.

Discounts
- 40% of orders carry a discount of 5% to 20%. Discounts cost $373K, which is 4.1% of list-price sales.
- Deeper discounts do not lift basket size. Units per order are about 1.38 at every discount level.
- Discounts are applied evenly across categories (4.1% on average) and between campaign and non-campaign orders.

Refunds
- The refund rate is steady at about 3% across categories (2.8% to 3.2%), countries (2.8% to 3.2%) and discount levels (2.9% to 3.1%), so no segment stands out as a refund problem.
- Electronics accounts for 40% of refunded value ($102K of $256K), because it is the largest category.

Campaigns
- 79.7% of orders carry a campaign. Their average order value ($90.46) and discount level are the same as orders with no campaign ($89.95).
- Revenue per campaign by channel: Affiliate $146K, Paid Search $139K, Display $135K, Email $123K, Social $122K. The gaps are small and the average order value is $90 to $91 in all of them.
- Orders per campaign follow the planned uplift. The five campaigns with the highest expected uplift average about 2,000 orders, against about 900 for the lowest five.

Customers
- 60% of customers have bought (60,091 of 100,000). 39,909 have never bought.
- 39% of buyers purchase more than once, and they bring 61% of revenue. The top 10% of buyers bring 34% of revenue, and the top 20% bring 52%.
- Most buyers are small spenders: 77% spent under $200 in net revenue over three years and bring 44% of revenue. The 2.8% who spent $500 to $1,000 and the 0.2% who spent over $1,000 together bring 14%.
- Gold and Platinum customers are more engaged than Bronze: 70% have bought against 56%, they place 1.7 orders per buyer against 1.5, and they spend $151 to $154 per buyer against $132.
- Acquisition channel makes little difference. Revenue per customer ranges only from $81 (Social) to $85 (Organic).

## Recommendations
1. Plan stock, staffing and marketing around November and December, and use February to run promotions that lift the low month.
2. Protect the premium and Electronics range, which drive three quarters of revenue. Cross-sell Home products to Electronics buyers.
3. Review the discount policy. $373K was given away with no visible rise in basket size. Cap discounts at 10% in a controlled test and compare units per order.
4. Fix campaign tracking before shifting budget. Attribute orders by date, then re-test Affiliate and Paid Search, which look strongest.
5. Convert the 39,909 customers who never bought with a first-purchase offer, and move Bronze customers up the loyalty tiers, since Gold and Platinum buy more often.
6. Investigate the 10% of orders with no product or revenue. That is a data capture problem with a direct financial impact.
7. Revenue is not growing and average order value is flat, so any growth has to come from more orders.

## Data Handling

Orders with no product
- 10,449 of 103,127 orders (10.1%) have no product and no revenue. They carry 14,426 units.
- Without a product there is no price, so revenue cannot be calculated. They are excluded from revenue, units, average order value, refund rates and all customer metrics, which use the 92,678 valid orders. They are still counted in the total order count.
- The gap looks random, not systematic. It is about 10% in every country (9.7% to 10.5%), every loyalty tier (9.8% to 10.3%), every discount level and every year, and these orders have the same campaign share (about 79%) and refund rate (about 3%) as the rest. Percentages and rankings are therefore unlikely to be distorted.
- Absolute revenue is understated. If these orders look like the rest, true net revenue would be roughly 11% higher. This is an estimate, not a measured figure.

Refunds
- Refunded orders are stored with negative revenue, so SUM(gross_revenue) is already net of refunds. Sales, refunds and net revenue are reported separately.

Other checks
- No duplicate orders, and no orders pointing to a missing customer, product or campaign.
- Revenue equals quantity x list price x (1 - discount) on every order, so the revenue column is internally consistent.
- 49% of valid orders are dated before the customer's signup date, so customer tenure and cohort analysis were not attempted.
- 95% of campaign orders fall outside their campaign's start and end dates, so campaign results are indicative only.

## Limitations
- Synthetic data. Real behaviour would differ.
- No cost data, so profit and margin cannot be measured.
- No control group, so discount and campaign effects cannot be proven causal.

## Repository Structure
Raw/    the four source CSV files, unchanged
sql/    numbered scripts, run in order
  01_data_quality_checks.sql
  02_kpis.sql
  03_discounts.sql
  04_refunds.sql
  05_campaigns.sql
  06_customers_retention.sql
  07_trends_over_time.sql
  08_cumulative_analysis.sql
  09_performance_vs_average.sql
  10_magnitude_analysis.sql
  11_part_to_whole.sql
  12_ranking.sql
  13_customer_segmentation.sql
  14_board_summary.sql
  15_supporting_findings.sql

## How to Run
1. Create a database in SQL Server 2022 or later (the scripts use DATETRUNC).
2. Import the four CSV files from the Raw folder as tables named customers, products, campaigns and transactions.
3. Run the scripts in the sql folder in numbered order.

## Tools
SQL Server, T-SQL: joins, CTEs, window functions (RANK, NTILE, LAG, running totals), CASE logic, data quality checks.

## Author
Obioma God'swill Nnaemeka, Data Analyst and Economist
LinkedIn: Obioma Nnaemeka
