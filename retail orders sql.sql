-- find top 10 highest revenue generating products 
select top 10 
product_id,
sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc



-- find top 5 highest selling products in each region
WITH cte AS (
  SELECT
    product_id,
    region,
    SUM(sale_price) AS sales,
    ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(sale_price) DESC) AS rank
  FROM df_orders
  GROUP BY region, product_id
)
SELECT *
FROM cte
WHERE rank <= 5
ORDER BY region, sales DESC;




-- find month over month growth comparison for 2022 and 2023 sales. E.g. Jan 2022 vs Jan 2023
with cte as (
select
year(order_date) as order_year,
month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by year(order_date), month(order_date)
)
select 
order_month,
sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month



--for each category which month had the highest sales
with cte as (
select 
category,
format(order_date, 'yyyyMM') as order_year_month,
sum(sale_price) as sales,
ROW_NUMBER() OVER (PARTITION BY category ORDER BY sum(sale_price) DESC) AS rank
from df_orders
group by category, format(order_date, 'yyyyMM')
)
select *
from cte
where rank =1




--which sub category had the highest growth by profit in 2023 compared to 2022
with cte as (
select
sub_category,
year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category, year(order_date)
), 
cte2 as (
select 
sub_category,
sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
select top 1 *,
(sales_2023 - sales_2022)*100/sales_2022 as growth_pct
from cte2
order by growth_pct desc
