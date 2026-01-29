-- ========================================
-- DIMENSION: TIME
-- ========================================

-- Create time dimension
-- Provides date-level granularity and multiple time attributes for analysis
create table transformation.dim_time (
	date_sk INTEGER,
	date DATE,
	day INTEGER,
	day_name TEXT,
	day_of_week INTEGER,
	week INTEGER,
	month INTEGER,
	month_name TEXT,
	quarter INTEGER,
	year INTEGER,
	is_holiday INTEGER,
	primary key(date_sk)
);

-- Insert into time dimension
-- Generates all dates in the range 2016-01-01 to 2018-12-31
-- Extracts day, week, month, quarter, year
-- Maps numeric day and month to names
-- Flags holidays
insert into transformation.dim_time
with generate_time as (
	select *
	from generate_series('2016-01-01'::timestamp,'2018-12-31'::timestamp, interval '1 day') t(date)
),
extraction_dimensions_date as (
	select date,
		   EXTRACT('day' from date) as day,
		   EXTRACT(isodow from date) as day_of_week,
		   EXTRACT('week' from date) as week,
		   EXTRACT('month' from date) as month,
		   EXTRACT('quarter' from date) as quarter,
		   EXTRACT('year' from date) as year
	from generate_time
),
weekday_month_mapped as (
	select *,
		   case 
		   	when day_of_week = 1 then 'Monday'
		   	when day_of_week = 2 then 'Tuesday'
		   	when day_of_week = 3 then 'Wednesday'
		   	when day_of_week = 4 then 'Thursday'
		   	when day_of_week = 5 then 'Friday'
		   	when day_of_week = 6 then 'Saturday'
		   	when day_of_week = 7 then 'Sunday'
		   end as day_name,
		   case 
		   	when month = 1 then 'January'
		   	when month = 2 then 'February'
		   	when month = 3 then 'March'
		   	when month = 4 then 'April'
		   	when month = 5 then 'May'
		   	when month = 6 then 'June'
		   	when month = 7 then 'July'
		   	when month = 8 then 'August'
		   	when month = 9 then 'September'
		   	when month = 10 then 'October'
		   	when month = 11 then 'November'
		   	when month = 12 then 'December'
		   end as month_name
	from extraction_dimensions_date
),
holidays_mapped as (
	select *,
		   case 
		   	-- Hardcoded national holidays for Brazil
		   	when date::date in (
		   		'2016-01-01','2016-02-09','2016-03-25','2016-04-21','2016-05-01',
		   		'2016-05-26','2016-09-07','2016-10-12','2016-11-02','2016-11-15','2016-12-25',
		   		'2017-01-01','2017-02-28','2017-04-14','2017-04-21','2017-05-01','2017-06-15',
		   		'2017-09-07','2017-10-12','2017-11-02','2017-11-15','2017-12-25',
		   		'2018-01-01','2018-02-13','2018-03-30','2018-04-21','2018-05-01','2018-05-31',
		   		'2018-09-07','2018-10-12','2018-11-02','2018-11-15','2018-12-25'
		   	) then 1
		   	else 0
		   end as is_holiday
	from weekday_month_mapped
)
select
	to_char(date,'YYYYMMDD')::integer as date_sk,
	date,
	day,
	day_name,
	day_of_week,
	week,
	month,
	month_name,
	quarter,
	year,
	is_holiday
from holidays_mapped;

