USE coffeeshop_db;

-- =========================================================
-- BASICS PRACTICE
-- Instructions: Answer each prompt by writing a SELECT query
-- directly below it. Keep your work; you'll submit this file.
-- =========================================================

-- Q1) List all products (show product name and price), sorted by price descending.
select name, price from products 
order by price desc;
-- Q2) Show all customers who live in the city of 'Lihue'.
select first_name, last_name from customers 
where city = 'Lihue';
-- Q3) Return the first 5 orders by earliest order_datetime (order_id, order_datetime).
select order_id, order_datetime from orders
order by order_datetime asc
limit 5;
-- Q4) Find all products with the word 'Latte' in the name.
select * from products
where name LIKE '%Latte%';
-- Q5) Show distinct payment methods used in the dataset.
select distinct payment_method
from orders;
-- Q6) For each store, list its name and city/state (one row per store).
select name, city, state 
from stores;
-- Q7) From orders, show order_id, status, and a computed column total_items
--     that counts how many items are in each order.
-- I had to have assistance from ChatGPT for this answer to help me understand how to join. I had it for the most part but the o. oi.  All others I was able to figure out--
SELECT 
    o.order_id,
    o.status,
    SUM(oi.quantity) AS total_items
FROM 
    orders o
JOIN 
    order_items oi ON o.order_id = oi.order_id
GROUP BY 
    o.order_id, o.status;
-- Q8) Show orders placed on '2025-09-04' (any time that day).
  select order_id, date(order_datetime) AS OnlyDate
    from orders
    where date(order_datetime) = '2025-09-04' ; 
-- Q9) Return the top 3 most expensive products (price, name).
select price, name from products
order by price desc
limit 3;
-- Q10) Show customer full names as a single column 'customer_name'
--      in the format "Last, First".
select concat(last_name, ',', first_name) as customer_name from customers;
