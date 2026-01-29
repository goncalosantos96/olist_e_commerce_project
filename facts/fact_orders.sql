-- ========================================
-- FACT: ORDERS
-- ========================================

-- Create fact_orders table
-- Each row represents one order.
-- Includes foreign keys to customers, time, and order status.
-- Also includes delivery metrics and review_score for analysis.
create table transformation.fact_orders (
	order_id TEXT,
	customer_sk INTEGER,
	date_sk INTEGER,
	order_status_sk INTEGER,
	review_score INTEGER,
	delivery_delay_days INTEGER,  -- days late
	delivery_early_days INTEGER,  -- days early
	delivery_days INTEGER,        -- total days from approval to delivery
	is_on_time BOOLEAN,
	primary key(order_id),
	constraint fk_fact_orders_customer
		foreign key (customer_sk)
		references transformation.dim_customers (customer_sk),
	constraint fk_fact_orders_time
		foreign key (date_sk)
		references transformation.dim_time (date_sk),
	constraint fk_fact_order_status
		foreign key (order_status_sk)
		references transformation.dim_order_status (order_status_sk)
);

-- Insert into fact_orders
-- We use several CTEs to:
-- 1. Clean the raw orders
-- 2. Deduplicate reviews
-- 3. Enrich orders with review scores
-- 4. Compute delivery metrics
-- 5. Compute on-time flag
insert into transformation.fact_orders
with cleaned_orders as (
	-- Basic cleaning of orders table
	select
		order_id,
		customer_id,
		order_status,
		case
			when order_status = 'delivered' then 1
			when order_status in ('canceled','unavailable') then 2
			when order_status in ('created','approved','processing','invoiced','shipped')
			     and order_purchase_timestamp::date < '2018-12-31'::date - interval '60 days' then 3
		end as order_status_sk,
		to_char(order_purchase_timestamp::date, 'YYYYMMDD')::integer as date_sk,
		order_purchase_timestamp::date as order_purchase_date,
		case
			when order_status = 'delivered' and order_approved_at is null
			then order_purchase_timestamp::date
			else order_approved_at::date
		end as order_approved_at_date,
		order_delivered_carrier_date::date as order_delivered_carrier_date,
		case
			when order_status = 'delivered' and order_delivered_customer_date is null
			then order_estimated_delivery_date::date
			else order_delivered_customer_date::date
		end as order_delivered_customer_date,
		order_estimated_delivery_date::date as order_estimated_delivery_date
	from olist_orders
),
deduped_order_reviews as (
	-- Some orders may have multiple reviews; pick the most recent one
	select *,
		   row_number() over(partition by order_id order by review_creation_date desc) as rn
	from olist_order_reviews
),
orders_with_review as (
	-- Join orders with review score (most recent)
	select
		co.*,
		dor.review_score
	from cleaned_orders co
	left join deduped_order_reviews dor
		on co.order_id = dor.order_id
	where dor.rn = 1
),
enriched_delivery_metrics as (
	-- Compute delivery-related metrics
	select *,
		-- Delay in days: positive if delivered after estimated delivery
		case when order_status_sk = 1
		     then greatest(0, order_delivered_customer_date - order_estimated_delivery_date)
		end as delivery_delay_days,
		-- Early delivery in days: positive if delivered before estimated delivery
		case when order_status_sk = 1
		     then greatest(0, order_estimated_delivery_date - order_delivered_customer_date)
		end as delivery_early_days,
		-- Total delivery time: days between approval and customer delivery
		case when order_status_sk = 1
		     then order_delivered_customer_date - order_approved_at_date
		end as delivery_days
	from orders_with_review
),
enriched_on_time_metric as (
	-- Flag if delivery was on time
	select *,
		case when delivery_delay_days = 0 then true
		     else false
		end as is_on_time
	from enriched_delivery_metrics
)
-- Final insert selecting all required columns
select
	eotm.order_id,
	dc.customer_sk,
	eotm.date_sk,
	eotm.order_status_sk,
	eotm.review_score,
	eotm.delivery_delay_days,
	eotm.delivery_early_days,
	eotm.delivery_days,
	eotm.is_on_time
from enriched_on_time_metric eotm
join transformation.dim_customers dc
	on eotm.customer_id = dc.id;

