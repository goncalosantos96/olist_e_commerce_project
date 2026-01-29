-- ========================================
-- CUSTOMERS & SATISFACTION
-- ========================================

-- MONTHLY REVIEW AVERAGE
create materialized view analytics.vw_monthly_review_average as
select 
	month,
	year,
	round(avg(review_score)::numeric, 2) as avg_review,
	count(distinct order_id) as total_orders
from analytics.vw_logistics
where status = 'Delivered'
group by month, year


-- MONTHLY REVIEW AVERAGE VS DELAYED ORDERS
create materialized view analytics.vw_monthly_review_average_delayed_orders as
select
	month,
	year,
	round(avg(case when delivery_delay_days > 0 then review_score end)::numeric, 2) as avg_review_delayed_orders
from analytics.vw_logistics
where status = 'Delivered'
group by month, year

-- MONTHLY ACTIVE CUSTOMERS
create materialized view analytics.vw_monthly_active_customers as
select
	month,
	year,
	count(distinct customer_unique_id) as num_customers_active
from analytics.vw_logistics
where status = 'Delivered'
group by month, year

-- MONTHLY NEW CUSTOMERS
create materialized view analytics.vw_monthly_new_customers as
with first_clients_purchase as (
	select 
		customer_unique_id,
		min(make_date(year, month, 1)) as first_purchase
	from analytics.vw_logistics
	where status = 'Delivered'
	group by customer_unique_id
)
select
	extract(year from first_purchase) as year,
	extract(month from first_purchase) as month,
	count(customer_unique_id) as num_new_customers
from first_clients_purchase
group by extract(month from first_purchase), extract(year from first_purchase)

-- MONTHLY PERCENTAGE OF RETAINED CUSTOMERS
create materialized view analytics.vw_monthly_percent_retained_customers as
with active_customers as 
(
	select 
		distinct
			customer_unique_id,
			make_date(year, month, 1) as year_month
	from analytics.vw_logistics
	where status = 'Delivered'
), monthly_active_customers as (
	select 
		year_month,
		count(customer_unique_id) as active_customers
	from active_customers
	group by year_month
), retained_customers as (
	select
		prev.year_month as previous_month,
		curr.year_month as curr_month,
		count(distinct curr.customer_unique_id) as retained_customers
	from active_customers prev
	join active_customers curr
	on prev.customer_unique_id = curr.customer_unique_id
	and curr.year_month = prev.year_month + interval '1 month'
	group by prev.year_month, curr.year_month
)
select
	extract(month from rc.previous_month) as month,
	extract(year from rc.previous_month) as year,
	rc.retained_customers,
	mac.active_customers,
	round((rc.retained_customers::numeric / mac.active_customers) * 100, 2) as retention_rate
from retained_customers rc
join monthly_active_customers mac
on rc.previous_month = mac.year_month

-- MONTHLY RECURRENT CUSTOMERS
create materialized view analytics.vw_monthly_recurrent_clients as
with monthly_active as (

	select 
		distinct 
			customer_unique_id,
			make_date(year, month, 1) as year_month
	from analytics.vw_logistics
	where status = 'Delivered'
), 
first_customers_purchase as 
(
	select 
		customer_unique_id,
		min(year_month) as first_purchase_month
	from monthly_active
	group by customer_unique_id
)
select
	extract(month from year_month) as month,
	extract(year from year_month) as year,
	count(ma.customer_unique_id) as num_recurrent_customers
from monthly_active ma
join first_customers_purchase fcp
on ma.customer_unique_id = fcp.customer_unique_id 
and ma.year_month >= fcp.first_purchase_month 
group by extract(month from year_month), extract(year from year_month)
order by year, month
