-- ========================================
-- FACT: ORDER ITEMS
-- ========================================

-- Create fact_order_items table
-- Each row represents an order-item combination
-- Useful for sales, product, and seller analytics
create table transformation.fact_order_items (
	order_id TEXT,
	customer_sk INTEGER,
	product_sk INTEGER,
	seller_sk INTEGER,
	date_sk INTEGER,
	order_status_sk INTEGER,
	price real,
	freight_value real,
	quantity INTEGER,
	total_value real,
	primary key(order_id, product_sk),
	constraint fk_fact_order_items_customers
		foreign key (customer_sk)
		references transformation.dim_customers (customer_sk),
	constraint fk_fact_order_items_products
		foreign key (product_sk)
		references transformation.dim_products (product_sk),
	constraint fk_fact_order_items_sellers
		foreign key (seller_sk)
		references transformation.dim_sellers (seller_sk),
	constraint fk_fact_order_items_time
		foreign key (date_sk)
		references transformation.dim_time (date_sk),
	constraint fk_fact_order_items_order_status
		foreign key (order_status_sk)
		references transformation.dim_order_status (order_status_sk)
);

-- Insert into fact_order_items
-- 1. Aggregate order items to compute quantity per order/product/seller
-- 2. Join with orders table to get date, customer, and status
-- 3. Compute total value = price * quantity + freight
insert into transformation.fact_order_items
with agg_order_items as (
	select
		order_id,
		product_id,
		seller_id,
		price,
		freight_value,
		count(*) as quantity
	from olist_order_items
	group by order_id, product_id, seller_id, price, freight_value
),
enriched_sales_metrics as (
	select
		aoi.order_id,
		to_char(oo.order_purchase_timestamp::timestamp, 'YYYYMMDD')::integer as date_sk,
		oo.customer_id,
		aoi.product_id,
		aoi.seller_id,
		aoi.price,
		aoi.freight_value,
		aoi.quantity,
		round(cast(aoi.price * quantity + freight_value as numeric), 2) as total_value
	from agg_order_items aoi
	join olist_orders oo
		on aoi.order_id = oo.order_id
) 
-- Final insert joining with dimension tables to get surrogate keys
select
	esm.order_id,
	dc.customer_sk,
	dp.product_sk,
	ds.seller_sk,
	esm.date_sk,
	fo.order_status_sk,
	esm.price,
	esm.freight_value,
	esm.quantity,
	esm.total_value
from enriched_sales_metrics esm
join transformation.dim_customers dc
	on esm.customer_id = dc.id
join transformation.dim_products dp
	on esm.product_id = dp.id
join transformation.dim_sellers ds
	on esm.seller_id = ds.id
join transformation.fact_orders fo
    on esm.order_id = fo.order_id


