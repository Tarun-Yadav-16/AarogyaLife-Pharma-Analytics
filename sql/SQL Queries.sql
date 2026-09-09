-- =============================================================
-- AAROGYALIFE PHARMACEUTICALS: SQL PORTFOLIO ANALYSIS
-- MySQL 8+ | Synthetic data | Author: Tarun Yadav
-- =============================================================
USE aarogyalife_pharma;

-- Q1. Executive company performance
SELECT ROUND(SUM(net_sales_inr), 0) AS total_net_sales,
       ROUND(SUM(gross_profit_inr), 0) AS total_gross_profit,
       SUM(quantity_units) AS total_units_sold,
       SUM(units_returned) AS total_units_returned,
       ROUND(100 * SUM(gross_profit_inr) / NULLIF(SUM(net_sales_inr), 0), 2) AS gross_margin_pct,
       ROUND(100 * SUM(units_returned) / NULLIF(SUM(quantity_units), 0), 2) AS return_rate_pct,
       ROUND(100 * SUM(CASE WHEN on_time_payment = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS on_time_payment_pct
FROM fact_sales;

-- Q2. Year-wise growth and margin
WITH yearly_performance AS (
    SELECT YEAR(invoice_date) AS sales_year,
           SUM(net_sales_inr) AS net_sales,
           SUM(gross_profit_inr) AS gross_profit
    FROM fact_sales
    GROUP BY YEAR(invoice_date)
), previous_year AS (
    SELECT sales_year, net_sales, gross_profit,
           LAG(net_sales) OVER (ORDER BY sales_year) AS previous_year_sales
    FROM yearly_performance
)
SELECT sales_year, ROUND(net_sales, 0) AS net_sales,
       ROUND(gross_profit, 0) AS gross_profit,
       ROUND(100 * gross_profit / NULLIF(net_sales, 0), 2) AS gross_margin_pct,
       ROUND(100 * (net_sales - previous_year_sales) / NULLIF(previous_year_sales, 0), 2) AS yoy_sales_growth_pct
FROM previous_year;

-- Q3. Region performance ranking
WITH region_performance AS (
    SELECT region, SUM(net_sales_inr) AS net_sales,
           SUM(gross_profit_inr) AS gross_profit,
           SUM(quantity_units) AS units_sold
    FROM fact_sales
    GROUP BY region
)
SELECT region, ROUND(net_sales, 0) AS net_sales,
       ROUND(gross_profit, 0) AS gross_profit, units_sold,
       ROUND(100 * gross_profit / NULLIF(net_sales, 0), 2) AS gross_margin_pct,
       DENSE_RANK() OVER (ORDER BY net_sales DESC) AS sales_rank
FROM region_performance
ORDER BY sales_rank;

-- Q4. Region annual target achievement
WITH region_sales AS (
    SELECT YEAR(invoice_date) AS sales_year, region,
           SUM(net_sales_inr) AS actual_net_sales
    FROM fact_sales
    GROUP BY YEAR(invoice_date), region
)
SELECT region_sales.sales_year, region_sales.region,
       ROUND(region_sales.actual_net_sales, 0) AS actual_net_sales,
       targets.sales_target_inr,
       ROUND(100 * region_sales.actual_net_sales / NULLIF(targets.sales_target_inr, 0), 2) AS target_achievement_pct,
       ROUND(region_sales.actual_net_sales - targets.sales_target_inr, 0) AS target_variance_inr,
       CASE WHEN region_sales.actual_net_sales >= targets.sales_target_inr
            THEN 'Achieved' ELSE 'Not Achieved' END AS target_status
FROM region_sales
INNER JOIN targets ON region_sales.sales_year = targets.year
                  AND region_sales.region = targets.region
ORDER BY region_sales.sales_year, target_achievement_pct DESC;

-- Q5. Channel profitability, returns, and collections
SELECT channel, COUNT(DISTINCT sale_id) AS total_orders,
       ROUND(SUM(net_sales_inr), 0) AS net_sales,
       ROUND(SUM(gross_profit_inr), 0) AS gross_profit,
       ROUND(100 * SUM(gross_profit_inr) / NULLIF(SUM(net_sales_inr), 0), 2) AS gross_margin_pct,
       ROUND(100 * SUM(discount_inr) / NULLIF(SUM(gross_sales_inr), 0), 2) AS discount_pct,
       ROUND(100 * SUM(units_returned) / NULLIF(SUM(quantity_units), 0), 2) AS return_rate_pct,
       ROUND(AVG(payment_days), 2) AS average_payment_days,
       ROUND(100 * SUM(CASE WHEN on_time_payment = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS on_time_payment_pct
FROM fact_sales
GROUP BY channel
ORDER BY net_sales DESC;

-- Q6. Therapy-area performance
SELECT dim_product.therapy_area,
       COUNT(DISTINCT dim_product.product_id) AS total_products,
       ROUND(SUM(fact_sales.net_sales_inr), 0) AS net_sales,
       ROUND(SUM(fact_sales.gross_profit_inr), 0) AS gross_profit,
       ROUND(100 * SUM(fact_sales.gross_profit_inr) / NULLIF(SUM(fact_sales.net_sales_inr), 0), 2) AS gross_margin_pct,
       SUM(fact_sales.quantity_units) AS units_sold
FROM fact_sales
INNER JOIN dim_product ON fact_sales.product_id = dim_product.product_id
GROUP BY dim_product.therapy_area
ORDER BY net_sales DESC;

-- Q7. Top 10 products by sales
SELECT dim_product.product_id, dim_product.brand_name,
       dim_product.generic_name, dim_product.therapy_area,
       ROUND(SUM(fact_sales.net_sales_inr), 0) AS net_sales,
       ROUND(SUM(fact_sales.gross_profit_inr), 0) AS gross_profit,
       SUM(fact_sales.quantity_units) AS units_sold,
       SUM(fact_sales.units_returned) AS units_returned,
       ROUND(100 * SUM(fact_sales.units_returned) / NULLIF(SUM(fact_sales.quantity_units), 0), 2) AS return_rate_pct
FROM fact_sales
INNER JOIN dim_product ON fact_sales.product_id = dim_product.product_id
GROUP BY dim_product.product_id, dim_product.brand_name,
         dim_product.generic_name, dim_product.therapy_area
ORDER BY net_sales DESC
LIMIT 10;

-- Q8. Highest-profit product within every therapy area
WITH product_profit AS (
    SELECT dim_product.therapy_area, dim_product.product_id,
           dim_product.brand_name,
           SUM(fact_sales.gross_profit_inr) AS total_profit
    FROM fact_sales
    INNER JOIN dim_product ON fact_sales.product_id = dim_product.product_id
    GROUP BY dim_product.therapy_area, dim_product.product_id,
             dim_product.brand_name
), ranked_products AS (
    SELECT therapy_area, product_id, brand_name, total_profit,
           DENSE_RANK() OVER (
               PARTITION BY therapy_area ORDER BY total_profit DESC
           ) AS profit_rank
    FROM product_profit
)
SELECT therapy_area, product_id, brand_name,
       ROUND(total_profit, 0) AS total_profit, profit_rank
FROM ranked_products
WHERE profit_rank = 1
ORDER BY total_profit DESC;

-- Q9. Products with return rate above company average
WITH company_rate AS (
    SELECT SUM(units_returned) / NULLIF(SUM(quantity_units), 0) AS return_rate
    FROM fact_sales
), product_rates AS (
    SELECT product_id, SUM(quantity_units) AS units_sold,
           SUM(units_returned) AS units_returned,
           SUM(units_returned) / NULLIF(SUM(quantity_units), 0) AS return_rate
    FROM fact_sales
    GROUP BY product_id
)
SELECT product_rates.product_id, dim_product.brand_name,
       dim_product.therapy_area, product_rates.units_sold,
       product_rates.units_returned,
       ROUND(100 * product_rates.return_rate, 2) AS product_return_rate_pct,
       ROUND(100 * company_rate.return_rate, 2) AS company_return_rate_pct
FROM product_rates
CROSS JOIN company_rate
INNER JOIN dim_product ON product_rates.product_id = dim_product.product_id
WHERE product_rates.return_rate > company_rate.return_rate
ORDER BY product_return_rate_pct DESC;

-- Q10. Distributor payment-risk analysis
SELECT dim_distributor.distributor_id,
       dim_distributor.distributor_name,
       dim_distributor.region, dim_distributor.channel,
       dim_distributor.credit_terms_days,
       ROUND(AVG(fact_sales.payment_days), 2) AS average_payment_days,
       ROUND(AVG(fact_sales.payment_days) - dim_distributor.credit_terms_days, 2) AS delay_days,
       ROUND(SUM(fact_sales.net_sales_inr), 0) AS net_sales,
       COUNT(*) AS total_orders
FROM fact_sales
INNER JOIN dim_distributor
    ON fact_sales.distributor_id = dim_distributor.distributor_id
GROUP BY dim_distributor.distributor_id,
         dim_distributor.distributor_name,
         dim_distributor.region, dim_distributor.channel,
         dim_distributor.credit_terms_days
HAVING AVG(fact_sales.payment_days) > dim_distributor.credit_terms_days
ORDER BY delay_days DESC, net_sales DESC;

-- Q11. Monthly sales growth with LAG
WITH monthly_sales AS (
    SELECT YEAR(invoice_date) AS sales_year,
           MONTH(invoice_date) AS month_number,
           DATE_FORMAT(invoice_date, '%Y-%m') AS year_month,
           SUM(net_sales_inr) AS current_month_sales
    FROM fact_sales
    GROUP BY YEAR(invoice_date), MONTH(invoice_date),
             DATE_FORMAT(invoice_date, '%Y-%m')
), sales_with_previous AS (
    SELECT *, LAG(current_month_sales) OVER (
        ORDER BY sales_year, month_number
    ) AS previous_month_sales
    FROM monthly_sales
)
SELECT sales_year, month_number, year_month,
       ROUND(current_month_sales, 0) AS current_month_sales,
       ROUND(previous_month_sales, 0) AS previous_month_sales,
       ROUND(current_month_sales - previous_month_sales, 0) AS sales_difference,
       ROUND(100 * (current_month_sales - previous_month_sales)
             / NULLIF(previous_month_sales, 0), 2) AS mom_growth_pct
FROM sales_with_previous
ORDER BY sales_year, month_number;

-- Q12. Warehouse inventory-risk summary
SELECT warehouse_id, warehouse_city, region,
       SUM(closing_stock_units) AS closing_stock_units,
       ROUND(SUM(inventory_value_inr), 0) AS inventory_value_inr,
       SUM(stockout_days) AS stockout_days,
       SUM(near_expiry_units_90d) AS near_expiry_units,
       SUM(damaged_units) AS damaged_units,
       DENSE_RANK() OVER (ORDER BY SUM(stockout_days) DESC) AS stockout_risk_rank
FROM fact_inventory
GROUP BY warehouse_id, warehouse_city, region
ORDER BY stockout_risk_rank;

-- Q13. High-sales products suffering stock-outs
WITH product_sales AS (
    SELECT product_id, SUM(net_sales_inr) AS net_sales,
           SUM(quantity_units) AS units_sold
    FROM fact_sales GROUP BY product_id
), product_inventory AS (
    SELECT product_id, SUM(stockout_days) AS stockout_days
    FROM fact_inventory GROUP BY product_id
), combined AS (
    SELECT product_sales.product_id, product_sales.net_sales,
           product_sales.units_sold, product_inventory.stockout_days,
           DENSE_RANK() OVER (ORDER BY product_sales.net_sales DESC) AS sales_rank,
           DENSE_RANK() OVER (ORDER BY product_inventory.stockout_days DESC) AS stockout_rank
    FROM product_sales
    INNER JOIN product_inventory
        ON product_sales.product_id = product_inventory.product_id
)
SELECT combined.product_id, dim_product.brand_name,
       dim_product.therapy_area, ROUND(combined.net_sales, 0) AS net_sales,
       combined.units_sold, combined.stockout_days,
       combined.sales_rank, combined.stockout_rank
FROM combined
INNER JOIN dim_product ON combined.product_id = dim_product.product_id
WHERE combined.sales_rank <= 10 AND combined.stockout_days > 0
ORDER BY combined.sales_rank;

-- Q14. Adverse-event operational workload
SELECT COUNT(*) AS total_cases,
       SUM(CASE WHEN event_seriousness = 'Serious' THEN 1 ELSE 0 END) AS serious_cases,
       SUM(CASE WHEN case_status = 'Under Review' THEN 1 ELSE 0 END) AS open_cases,
       ROUND(AVG(days_to_report), 2) AS average_reporting_days,
       ROUND(100 * SUM(CASE WHEN event_seriousness = 'Serious' THEN 1 ELSE 0 END)
             / COUNT(*), 2) AS serious_case_pct
FROM fact_adverse_events;

-- Q15. Product reporting volume per 100,000 units sold
-- This is a reporting-volume metric, not clinical incidence.
WITH product_exposure AS (
    SELECT product_id, SUM(quantity_units) AS total_units_sold
    FROM fact_sales GROUP BY product_id
), product_cases AS (
    SELECT product_id, COUNT(*) AS total_ae_cases,
           SUM(CASE WHEN event_seriousness = 'Serious' THEN 1 ELSE 0 END) AS serious_cases
    FROM fact_adverse_events GROUP BY product_id
)
SELECT product_exposure.product_id, dim_product.brand_name,
       product_exposure.total_units_sold,
       COALESCE(product_cases.total_ae_cases, 0) AS total_ae_cases,
       COALESCE(product_cases.serious_cases, 0) AS serious_cases,
       ROUND(100000 * COALESCE(product_cases.total_ae_cases, 0)
             / NULLIF(product_exposure.total_units_sold, 0), 2) AS reporting_rate_per_100000_units
FROM product_exposure
LEFT JOIN product_cases ON product_exposure.product_id = product_cases.product_id
INNER JOIN dim_product ON product_exposure.product_id = dim_product.product_id
ORDER BY reporting_rate_per_100000_units DESC;

