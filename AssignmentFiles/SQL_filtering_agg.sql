-- ==================================
-- FILTERS & AGGREGATION
-- ==================================

USE coffeeshop_db;


-- Q1) Compute total items per order.
--     Return (order_id, total_items) from order_items.
select order_id, sum(quantity) as total_items
from order_items
Group by order_id;

-- Q2) Compute total items per order for PAID orders only.
--     Return (order_id, total_items). Hint: order_id IN (SELECT ... FROM orders WHERE status='paid').
select order_id, sum(quantity) as total_items from order_items
where order_id IN (select order_id from orders 
where status = 'paid')
Group by order_id;

-- Q3) How many orders were placed per day (all statuses)?
--     Return (order_date, orders_count) from orders.
select date(order_datetime) as order_date, sum(order_id) as order_count
from orders
group by date(order_datetime)
order by order_date asc;

-- Q4) What is the average number of items per PAID order?
--     Use a subquery or CTE over order_items filtered by order_id IN (...).
select AVG(total_items) as avg_items_paid
FROM (
	select order_id, sum(quantity) as total_items from order_items
	where order_id IN (
		select order_id from orders 
		where status = 'paid')
		Group by order_id)
        as paid_orders;
        
-- Q5) Which products (by product_id) have sold the most units overall across all stores?
--     Return (product_id, total_units), sorted desc.
select product_id, SUM(quantity) as total_units from order_items
group by product_id
order by total_units desc;

-- Q6) Among PAID orders only, which product_ids have the most units sold?
--     Return (product_id, total_units_paid), sorted desc.
--     Hint: order_id IN (SELECT order_id FROM orders WHERE status='paid').
select product_id, SUM(quantity) as total_units_paid 
from order_items
where order_id IN (
		select order_id 
        from orders 
		where status = 'paid') 
	group by product_id
    order by total_units_paid desc;

-- Q7) For each store, how many UNIQUE customers have placed a PAID order?
--     Return (store_id, unique_customers) using only the orders table.
 select store_id, count(distinct customer_id) as unique_customers from orders
 Where status = 'paid'
 group by store_id;

-- Q8) Which day of week has the highest number of PAID orders?
--     Return (day_name, orders_count). Hint: DAYNAME(order_datetime). Return ties if any.
select DAYNAME(order_datetime) as day_name, sum(order_id) as orders_count
from orders
where status = 'paid'
group by dayname(order_datetime)

having count(order_id) = 
(select max(day_count) from (select count(order_id) as day_count
from orders
where status = 'paid'
group by DAYNAME(order_datetime)
) as counts);


-- Q9) Show the calendar days whose total orders (any status) exceed 3.
--     Use HAVING. Return (order_date, orders_count).
Select date(order_datetime) as order_date, sum(order_id) as orders_count
from orders
group by date(order_datetime)
having sum(order_id) > 3;

-- Q10) Per store, list payment_method and the number of PAID orders.
--      Return (store_id, payment_method, paid_orders_count).
select store_id, payment_method, COUNT(order_id) as paid_orders_count
from orders
where status = 'PAID'
Group by store_id, payment_method;


-- Q11) Among PAID orders, what percent used 'app' as the payment_method?
--      Return a single row with pct_app_paid_orders (0–100).
-- HAD CHAT GPT HELP WITH THIS. Couldn't figure out the percentage part
SELECT 
    100.0 * COUNT(CASE WHEN payment_method = 'app' THEN 1 END) 
    / COUNT(*) AS pct_app_paid_orders
FROM orders
WHERE status = 'PAID';

-- Q12) Busiest hour: for PAID orders, show (hour_of_day, orders_count) sorted desc.
Select hour(order_datetime) as hour_of_day, sum(order_id) as orders_count
from orders
group by hour(order_datetime)
order by orders_count desc;


-- ================
