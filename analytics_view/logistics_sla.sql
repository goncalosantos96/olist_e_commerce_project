-- ========================================
-- LOGISTICS & SLA
-- ========================================

-- MONTHLY SLA DELIVERIES ON TIME
create materialized view analytics.vw_monthly_sla_deliveries_on_time as
select
    month,
    year,
    round(
        sum(case when delivery_delay_days = 0 then 1 else 0 end)::numeric
        / count(distinct order_id) * 100,
        2
    ) as sla_deliveries_on_time
from analytics.vw_logistics
where status = 'Delivered'
group by month, year

select *
from analytics.vw_monthly_sla_deliveries_on_time
order by year, month


-- MONTHLY SLA DELIVERIES ON TIME BY STATE
create materialized view analytics.vw_monthly_sla_deliveries_on_time_by_state as
select
    month,
    year,
    customer_state,
    round(
        sum(case when delivery_delay_days = 0 then 1 else 0 end)::numeric
        / count(distinct order_id) * 100,
        2
    ) as sla_deliveries_on_time,
    count(distinct order_id) as total_orders
from analytics.vw_logistics
where status = 'Delivered'
group by customer_state, month, year


-- MONTHLY AVERAGE/MEDIAN DELAYS
create materialized view analytics.vw_monthly_average_delays as
select 
	month,
	year,
	round(sum(case when delivery_delay_days > 0 then delivery_delay_days else 0 end)::numeric
	/
	nullif(sum(case when delivery_delay_days > 0 then 1 else 0 end), 0), 2) as avg_delays_on_delayed_orders,
	percentile_cont(0.5) within group (order by delivery_delay_days) filter (where delivery_delay_days > 0) as median_delay_days,
	coalesce(sum(case when delivery_delay_days > 0 then 1 else 0 end), 0) as total_delayed_orders,
	count(distinct order_id) as total_orders
from analytics.vw_logistics
where status = 'Delivered'
group by month, year


-- MONTHLY AVERAGE/MEDIAN LEAD TIME 
create materialized view analytics.vw_monthly_average_lead_time as
select 
	month,
	year,
	round(sum(delivery_days)::numeric
	/
	count(distinct order_id), 2) as avg_lead_days,
	percentile_cont(0.5) within group (order by delivery_days) as median_lead_days
from analytics.vw_logistics
where status = 'Delivered'
group by month, year


