-- ========================================
-- DIMENSION: LOCATION
-- ========================================

-- First, we check if there are duplicates in the geolocation dataset
-- for zip_code_prefix, because duplicates can affect the dominant city selection.
select geolocation_zip_code_prefix
from olist_geolocation
group by geolocation_zip_code_prefix
having count(*) > 1;

-- Create the dim_location table.
-- location_sk: surrogate key, integer, primary key.
-- zip_code_prefix: natural key, keeps the original zip code.
-- city/state: final standardized city and state names.
create table transformation.dim_location (
	location_sk INTEGER,
	zip_code_prefix INTEGER,
	city TEXT,
	state TEXT,
	primary key(location_sk),
	unique (zip_code_prefix)  -- ensures no duplicates per zip code
);

-- Insert data into dim_location
-- The process includes combining sources, normalizing city names, 
-- and selecting the statistically dominant city per zip code.
insert into transformation.dim_location
with location_sources_union as (
	-- Combine three sources: geolocation table, customer addresses, seller addresses.
	select geolocation_zip_code_prefix as zip_code_prefix,
		   geolocation_city as city,
		   geolocation_state as state
	from olist_geolocation
	
	union all
	
	select customer_zip_code_prefix as zip_code_prefix,
		   customer_city as city,
		   customer_state as state
	from olist_customers
	
	union all
	
	select seller_zip_code_prefix::integer as zip_code_prefix,
		   seller_city as city,
		   seller_state as state
	from olist_sellers
),
city_text_normalized as (
	-- Step 1: Normalize city names.
	-- Remove accents and uppercase all letters to reduce duplication.
	select *,
		   upper(trim(translate(city,
			   'áàãâäéèêëíìîïóòõôöúùûüç',
			   'aaaaaeeeeiiiiooooouuuuc'))) as first_step_cleaning_city
	from location_sources_union
),
city_text_sanitized as (
	-- Step 2: Further clean city names by removing special characters and extra spaces.
	select *,
		   regexp_replace(
		     regexp_replace(first_step_cleaning_city, '[^A-Z\s]', '', 'g'),
		     '\s+', ' ', 'g'
		   ) as sanitized_city
	from city_text_normalized
),
city_frequency_by_zip as (
	-- Count occurrences of each sanitized city name per zip_code.
	-- This will help determine the statistically dominant city for each zip code.
	select zip_code_prefix,
		   sanitized_city as city,
		   upper(trim(state)) as state,
		   count(*) as occurences
	from city_text_sanitized
	group by zip_code_prefix, sanitized_city, state
),
dominant_city_per_zip as (
	-- Rank city names by occurrence count per zip code.
	-- The row_number() function ensures we pick the city with the highest occurrence.
	select *,
		   row_number() over(partition by zip_code_prefix order by occurences desc, city) as rn
	from city_frequency_by_zip
)
-- Select only the dominant city (rn = 1) for each zip code and assign surrogate keys.
select
	row_number() over(order by zip_code_prefix) as location_sk,
	zip_code_prefix,
	city,
	state
from dominant_city_per_zip
where rn = 1;


