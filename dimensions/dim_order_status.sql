-- ========================================
-- DIMENSION: ORDER STATUS
-- ========================================
-- Create a small dimension to standardize order statuses.
-- Surrogate key: order_status_sk
-- status: standardized label for order status categories
create table transformation.dim_order_status (
	order_status_sk INTEGER,
	status TEXT,
	primary key(order_status_sk)
);

-- Insert fixed order statuses
-- 'Delivered': orders successfully delivered
-- 'Canceled': orders canceled or unavailable
-- 'Failed': orders not delivered despite being created/processed
insert into transformation.dim_order_status (order_status_sk, status)
values
(1, 'Delivered'),
(2, 'Canceled'),
(3, 'Failed');

