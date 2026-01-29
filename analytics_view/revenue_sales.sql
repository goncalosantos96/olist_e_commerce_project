-- ========================================
-- REVENUE & SALES ANALYSIS
-- ========================================

-- MONTHLY REVENUE VIEW
create materialized view analytics.vw_monthly_revenue as
select 
	month,
	year,
	round(sum(total_value)::numeric, 2) as revenue
from analytics.vw_sales
where status = 'Delivered'
group by year, month


-- REVENUE BY CATEGORY
create materialized view analytics.vw_monthly_revenue_category as
select
	product_category,
	month,
	year,
	round(sum(price * quantity)::numeric, 2) as revenue
from analytics.vw_sales
where status = 'Delivered'
group by product_category, month, year


-- REVENUE BY CUSTOMER_STATE (Check where demand comes from)
create materialized view analytics.vw_monthly_revenue_customer_state as
select
	customer_state,
	month,
	year,
	round(sum(price * quantity)::numeric, 2) as revenue
from analytics.vw_sales
where status = 'Delivered'
group by customer_state, month, year


-- REVENUE BY SELLER_STATE (Check where offer comes from)
create materialized view analytics.vw_monthly_revenue_seller_state as
select
	seller_state,
	month,
	year,
	round(sum(price * quantity)::numeric, 2) as revenue
from analytics.vw_sales
where status = 'Delivered'
group by seller_state, month, year


-- AVERAGE TICKET BY CUSTOMER
create materialized view analytics.vw_avg_ticket_monthly as
select 
	month,
	year,
	round((sum(total_value) / count(distinct order_id))::numeric, 2) as avg_ticket
from analytics.vw_sales
where status = 'Delivered'
group by month, year

