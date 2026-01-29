create materialized view analytics.vw_sales as
select
	foi.order_id,
	dt.day_of_week,
	dt.day_name,
	dt.month,
	dt.month_name,
	dt.quarter,
	dt.year,
	dt.is_holiday,
	dc.unique_id as customer_unique_id,
	dcl.city as customer_city,
	dcl.state as customer_state,
	ds.id as seller_id,
	dsl.city as seller_city,
	dsl.state as seller_state,
	dp.id as product_id,
	dp.category as product_category,
	foi.price,
	foi.freight_value,
	foi.quantity,
	foi.total_value,
	dos.status
from transformation.fact_order_items foi
join transformation.dim_time dt
on foi.date_sk = dt.date_sk
join transformation.dim_customers dc
on foi.customer_sk = dc.customer_sk
join transformation.dim_location dcl
on dc.location_sk = dcl.location_sk
join transformation.dim_sellers ds
on foi.seller_sk = ds.seller_sk
join transformation.dim_location dsl
on ds.location_sk = dsl.location_sk
join transformation.dim_products dp
on foi.product_sk = dp.product_sk
join transformation.dim_order_status dos
on foi.order_status_sk = dos.order_status_sk



  
create materialized view analytics.vw_logistics as
select
	fo.order_id,
	dt.day_of_week,
	dt.day_name,
	dt.month,
	dt.month_name,
	dt.quarter,
	dt.year,
	dt.is_holiday,
	dc.unique_id as customer_unique_id,
	dl.city as customer_city,
	dl.state as customer_state,
	fo.review_score,
	fo.delivery_delay_days,
	fo.delivery_early_days,
	fo.delivery_days,
	fo.is_on_time,
	dos.status
from transformation.fact_orders fo
join transformation.dim_time dt
on fo.date_sk = dt.date_sk
join transformation.dim_customers dc
on fo.customer_sk = dc.customer_sk
join transformation.dim_location dl
on dc.location_sk = dl.location_sk
join transformation.dim_order_status dos
on fo.order_status_sk = dos.order_status_sk



