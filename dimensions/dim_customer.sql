-- ========================================
-- DIMENSION: CUSTOMERS
-- ========================================

-- Create customers dimension.
-- customer_sk: surrogate key.
-- location_sk: foreign key to dim_location.
-- id: natural key from source.
-- unique_id: unique customer identifier from source.
create table transformation.dim_customers (
	customer_sk INTEGER,
	location_sk INTEGER,
	id TEXT, 
	unique_id TEXT,
	primary key(customer_sk),
	constraint fk_customers_location
		foreign key (location_sk)
		references transformation.dim_location (location_sk)
);

-- Insert into dim_customers
-- Join with dim_location to get location_sk for each customer based on zip_code_prefix.
insert into transformation.dim_customers
select
	row_number() over(order by oc.customer_id) as customer_sk,
	dl.location_sk,
	oc.customer_id as id,
	oc.customer_unique_id as unique_id
from olist_customers oc
join transformation.dim_location dl
	on oc.customer_zip_code_prefix = dl.zip_code_prefix;

