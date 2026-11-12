# E-Commerce Sales and Campaign Analysis (SQL Server)

## Objective
Analyse three years of online sales (2021 to 2023) to find out what drives revenue, whether discounts and marketing campaigns pay off, and which customers matter most.

## Dataset
Marketing & E-Commerce Analytics Dataset (Kaggle, geethasagarbonthu), CC0 licence. Synthetic data, so the findings demonstrate analysis technique and are not evidence of real business performance.
Tables used: customers (100,000), products (2,000), campaigns (50), transactions (103,127).

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
- Revenue was $8.37M after refunds: $8.63M from completed orders, less $256K from 2,704 refunded orders (2.9% of orders). Refunds are stored as negative revenue.
- Revenue is flat to slightly declining: $2.82M (2021), $2.79M (2022, down 1.1%), $2.77M (2023, down 0.5%). Orders barely moved (31,105 to 30,912), and average order value held near $90.

Seasonality
- November and December bring 20.6% of annual revenue. December is the peak ($876K) and February the low ($623K).

Products and markets
- Electronics generate 41.2% of revenue, then Home (23.8%), Fashion (15.5%), Sports (11.5%), Beauty (4.4%) and Grocery (3.5%).
- Premium products make 77% of revenue from 50% of orders. Their average order is $139 against $42 for the rest.
- Grocery has more orders than Sports but only 3.5% of revenue, because its average order is $20.
- The US brings 35.2% of revenue, India 20.1%, UK 10.1%, Brazil 10.0%, Canada 9.8%, Germany 7.8% and Australia 7.1%. Average order value is $89 to $92 in every country, so differences between countries come from order volume, not basket size.

Discounts
- 40% of orders carry a discount of 5% to 20%. Discounts cost $373K, which is 4.1% of list-price sales.
- Deeper discounts do not lift basket size. Units per order are about 1.38 at every discount level, and refund rates stay near 3%.
- Discounts are applied evenly across categories and between campaign and non-campaign orders.

Campaigns
- 79.7% of orders carry a campaign. Their average order value ($90.46) and discount level are the same as orders with no campaign ($89.95).
- Revenue per campaign by channel: Affiliate $146K, Paid Search $139K, Display $135K, Email $123K, Social $122K. The gaps are small, and the average order value is $90 to $91 in all of them.
- Orders per campaign follow the planned uplift closely (correlation 0.996). The five campaigns with the highest expected uplift average about 2,000 orders, against about 900 for the lowest five.

Customers
- 60% of customers have bought (60,091 of 100,000). 39,909 have never bought.
- 39% of buyers purchase more than once, and they bring 61% of revenue. The top 10% of buyers bring 34% of revenue, and the top 20% bring 52%.
- Gold and Platinum customers are more engaged than Bronze: 70% have bought against 56%, they place 1.7 orders per buyer against 1.5, and they spend $151 to $154 per buyer against $132.
- Acquisition channel makes little difference. Revenue per customer ranges only from $81 (Social) to $85 (Organic).

Data quality
- 10,449 orders (10.1%) have no product and no revenue. They are excluded from revenue figures, so true revenue is probably understated.
- 49% of orders are dated before the customer's signup date, so customer tenure and cohort analysis would be unreliable.
- 95% of campaign-tagged orders fall outside the campaign's start and end dates, so the campaign figures show tendencies only.

## Recommendations
1. Plan stock, staffing and marketing around November and December, and use February to run promotions that lift the low month.
2. Protect the premium and Electronics range, which drive three quarters of revenue. Cross-sell Home products to Electronics buyers.
3. Review the discount policy. $373K was given away with no visible rise in basket size. Cap discounts at 10% in a controlled test and compare units per order.
4. Fix campaign tracking before shifting budget. Attribute orders by date, then re-test Affiliate and Paid Search, which look strongest.
5. Convert the 39,909 customers who never bought with a first-purchase offer, and move Bronze customers up the loyalty tiers, since Gold and Platinum buy more often.
6. Investigate the 10% of orders with no product or revenue. That is a data capture problem with a direct financial impact.
7. Revenue is not growing. Growth has to come from more orders, because average order value is flat.

## Limitations
- Synthetic data. Real behaviour would differ.
- No cost data, so profit and margin cannot be measured.
- The dataset has no control group, so discount and campaign effects cannot be proven causal.
- The events table (2,000,000 rows) is not used in these results.

## Tools
SQL Server, T-SQL (joins, CTEs, window functions, CASE logic)
