-- ========================================
-- TIME & SEASONALITY
-- ========================================

-- WEEKDAY REVENUE & ORDERS
create materialized view analytics.vw_weekday_orders_revenue as
with agg_order_id as (

	select
		order_id,
		sum(total_value) as total_order
	from analytics.vw_sales
	where status = 'Delivered'
	group by order_id

)
select
	vl.day_name as weekday,
	sum(aoi.total_order) as total_revenue,
	count(aoi.order_id) as total_orders
from agg_order_id aoi
join analytics.vw_logistics vl
on aoi.order_id = vl.order_id
group by vl.day_name


-- NORMAL DAY VS HOLIDAY REVENUE & ORDERS
create materialized view analytics.vw_normal_holiday_orders_revenue as
with daily_sales AS (
    
    select
        vs.year,
        vs.month,
        vs.day_name,
        vs.is_holiday,
        count(distinct vs.order_id) as orders_per_day,
        sum(vs.total_value) as revenue_per_day
    from analytics.vw_sales vs
    where vs.status = 'Delivered'
    group by vs.year, vs.month, vs.day_name, vs.is_holiday
)
select
    case when is_holiday = 1 then 'Holiday' else 'Normal Day' end as day_type,
    round(avg(orders_per_day)::numeric, 2) AS avg_orders_per_day,
    round(avg(revenue_per_day)::numeric, 2) AS avg_revenue_per_day,
    round(avg(revenue_per_day / nullif(orders_per_day, 0))::numeric, 2) as avg_ticket_per_order
from daily_sales
group by is_holiday

