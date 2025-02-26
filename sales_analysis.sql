select * from df_orders
-- top 10 highest revenue generating products
select top 10 product_id, sum(sales_price) as Total_sales from df_orders group by product_id order by sum(sales_price) desc 
-- top 5 highest selling products in each region
with cte_table as(
select region, product_id , sum(sales_price) as sales, rank() over(partition by region order by sum(sales_price) desc ) as ranking from df_orders group by region, product_id)
select * from cte_table where ranking < 6

--find month over months growth comparison e.g. jan 2022 vs jan 2023

select datename(month, order_date) as months, 
sum( case when year(order_date) = 2022 then sales_price else 0 end) as sales_2022,
sum( case when year(order_date) = 2023 then sales_price else 0 end) as sales_2023
from df_orders
--where year(order_date) in (2022,2023) -- could be skipped 
group by datename(month, order_date),
month(order_date) 
order by month(order_date)
-- for each category which month has highest sales
--select distinct category from df_orders
with cte_table as(
select category, format(order_date,'yyyyMM') as highest_sale_month, sum(sales_price) as high_sales,
row_number() over(partition by category order by sum(sales_price) desc) as rn from df_orders group by category, format(order_date,'yyyyMM')
--order by category, high_sales desc -- need to remove for cte table 
)
select cte_table.category, cte_table.highest_sale_month, cte_table.high_sales from cte_table where cte_table.rn = 1 order by high_sales desc

-- which subcategory has highest growth by profit in 2023 compared to 2022 by value 
with cte_table as(
select sub_category, 
sum(case when year(order_date) = 2023 then sales_price else 0 end) as profit_2023,
sum(case when year(order_date) = 2022 then sales_price else 0 end) as profit_2022
from df_orders group by sub_category
) 
select top 1 *, profit_2023-profit_2022 as max_profit from cte_table order by profit_2023-profit_2022 desc
-- which subcategory has highest growth by profit in 2023 compared to 2022 by %
with cte_table as(
select sub_category, 
sum(case when year(order_date) = 2023 then sales_price else 0 end) as profit_2023,
sum(case when year(order_date) = 2022 then sales_price else 0 end) as profit_2022
from df_orders group by sub_category
) 
select top 1 *, (profit_2023-profit_2022)*100/profit_2022 as max_profit from cte_table order by (profit_2023-profit_2022)*100/profit_2022 desc