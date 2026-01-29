-- ========================================
-- DIMENSION: SELLERS
-- ========================================

-- Create sellers dimension.
-- seller_sk: surrogate key.
-- location_sk: foreign key to dim_location.
-- id: natural key from source.
create table transformation.dim_sellers (
	seller_sk INTEGER,
	location_sk INTEGER,
	id TEXT,
	primary key(seller_sk),
	constraint fk_sellers_location
		foreign key (location_sk)
		references transformation.dim_location (location_sk)
);

-- Insert into dim_sellers
-- Join with dim_location using seller zip code.
insert into transformation.dim_sellers
select
	row_number() over(order by os.seller_id) as seller_sk,
	dl.location_sk,
	os.seller_id as id
from olist_sellers os
join transformation.dim_location dl
	on os.seller_zip_code_prefix::integer = dl.zip_code_prefix;

