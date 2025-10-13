USE coffeeshop_db;

-- =========================================================
-- JOINS & RELATIONSHIPS PRACTICE
-- =========================================================

-- Q1) Join products to categories: list product_name, category_name, price.

SELECT p.name AS product_name, c.name AS category_name, p.price
FROM products p
INNER JOIN categories c
    ON p.category_id = c.category_id;

-- Q2) For each order item, show: order_id, order_datetime, store_name,
--     product_name, quantity, line_total (= quantity * products.price).
--     Sort by order_datetime, then order_id.
select 
	o.order_id, 
	o.order_datetime, 
    s.name as store_name,
    p.name as product_name, 
    oi.quantity, (oi.quantity * p.price) as line_total
from order_items oi
Inner Join orders o
	on oi.order_id = o.order_id
Inner Join stores s
	on o.store_id = s.store_id
Inner Join products p
	on p.product_id = oi.product_id
Order By o.order_datetime, o.order_id;

-- Q3) Customer order history (PAID only):
--     For each order, show customer_name, store_name, order_datetime,
--     order_total (= SUM(quantity * products.price) per order).
Select 
   CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
   s.name as store_name, 
   o.order_datetime, 
	SUM(oi.quantity * p.price) as order_total
From orders o
Inner Join customers c
	on o.customer_id = c.customer_id
Inner Join stores s
	on o.store_id = s.store_id
Inner Join order_items oi
	on o.order_id = oi.order_id
Inner Join products p
	on oi.product_id = p.product_id
Group by 
	c.first_name, 
    c.last_name, 
    s.name, 
    o.order_datetime
Order by o.order_datetime;

-- Q4) Left join to find customers who have never placed an order.
--     Return first_name, last_name, city, state.
Select 
	c.first_name, 
	c.last_name, 
    c.city, 
    c.state
from customers c
Left Join orders o
	on c.customer_id = o.customer_id
Where o.customer_id is NULL;

-- Q5) For each store, list the top-selling product by units (PAID only).
--     Return store_name, product_name, total_units.
--     Hint: Use a window function (ROW_NUMBER PARTITION BY store) or a correlated subquery.
-- Assisted with ChatGPT on this problem as I could not figure out row number on my own.
WITH product_sales AS (
    SELECT 
        s.name AS store_name,
        p.name AS product_name,
        SUM(oi.quantity) AS total_units,
        ROW_NUMBER() OVER (
            PARTITION BY s.store_id 
            ORDER BY SUM(oi.quantity) DESC
        ) AS rn
    FROM order_items oi
    INNER JOIN orders o 
        ON oi.order_id = o.order_id
    INNER JOIN stores s 
        ON o.store_id = s.store_id
    INNER JOIN products p 
        ON oi.product_id = p.product_id
    WHERE o.status = 'PAID'
    GROUP BY s.store_id, s.name, p.name
)
SELECT 
    store_name, 
    product_name, 
    total_units
FROM product_sales
WHERE rn = 1
ORDER BY store_name;

-- Q6) Inventory check: show rows where on_hand < 12 in any store.
--     Return store_name, product_name, on_hand.
Select
	s.name as store_name, 
    p.name as product_name, 
    i.on_hand as on_hand
from stores s
inner join inventory i
	on s.store_id = i.store_id
inner join products p
	on i.product_id = p.product_id
Where on_hand < 12 
order by on_hand desc;
 
-- Q7) Manager roster: list each store's manager_name and hire_date.
--     (Assume title = 'Manager').
Select 
	CONCAT(first_name, ' ', last_name) as manager_name, 
    hire_date
from employees
where title = 'Manager'
order by manager_name;	

-- Q8) Using a subquery/CTE: list products whose total PAID revenue is above
--     the average PAID product revenue. Return product_name, total_revenue.
-- CHATGPT used with this solution
WITH paid_product_revenue AS (
    SELECT 
        p.name AS product_name,
        SUM(oi.quantity * p.price) AS total_revenue
    FROM order_items oi
    INNER JOIN orders o 
        ON oi.order_id = o.order_id
    INNER JOIN products p 
        ON oi.product_id = p.product_id
    WHERE o.status = 'PAID'
    GROUP BY p.product_id, p.name
)
SELECT 
    product_name,
    total_revenue
FROM paid_product_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM paid_product_revenue
)
ORDER BY total_revenue DESC;


-- Q9) Churn-ish check: list customers with their last PAID order date.
--     If they have no PAID orders, show NULL.
--     Hint: Put the status filter in the LEFT JOIN's ON clause to preserve non-buyer rows.
Select 
	c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) as customer_name, 
    MAX(o.order_datetime) as last_paid_order_date
from customers c
Left Join orders o
	on c.customer_id = o.customer_id AND o.status = 'PAID'
Group by c.customer_id, c.first_name, c.last_name
order by last_paid_order_date;

-- Q10) Product mix report (PAID only):
--     For each store and category, show total units and total revenue (= SUM(quantity * products.price)).
Select 
	s.name as store_name, 
    c.name as category_name, 
    SUM(oi.quantity) as total_units, 
    SUM(oi.quantity * p.price) as total_revenue
from order_items oi
inner join orders o
	on oi.order_id = o.order_id
inner join products p
	on oi.product_id = p.product_id
inner join categories c
	on p.category_id = c.category_id
inner join stores s
	on o.store_id = s.store_id
where o.status = 'PAID'
group by s.name, c.name
ORDER BY s.name, total_revenue DESC;