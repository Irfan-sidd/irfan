-- Calculate total number of orders

SELECT 
    COUNT(OrderID) AS Total_Orders
FROM
    orders;

-- Calculate total revenue
SELECT 
    SUM(o.Quantity * p.Price) AS total_revenue
FROM
    orders o
        INNER JOIN
    products p ON o.ProductID = p.ProductID;

 -- Change column name  
 ALTER TABLE orders
 RENAME COLUMN Order_Datetime To Order_Date;
 
-- Convert proper format
 update orders
 set Order_Date = str_to_date(Order_date, '%Y-%m-%d %H:%i:%s');
-- Add new column 
alter table orders add column total_amount decimal (10,2);

-- Add values
update orders o
join products p on o.ProductID = p.ProductID
set total_amount = p.Price * o.Quantity;

-- Calculate month-wise revenue
SELECT 
    DATE_FORMAT(Order_Date, '%Y-%m') AS month,
    SUM(total_amount) AS revenue
FROM
    orders
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
ORDER BY month;

-- Top 5 highest selling products (by revenue)
SELECT 
    p.product_name, 
    SUM(o.total_amount) AS revenue
FROM
    orders o
        JOIN
    products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 5;

-- Customer-wise total spend
SELECT 
    c.first_name,
    c.last_name,
    SUM(o.total_amount) AS total_spend
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY c.first_name , c.last_name
ORDER BY total_spend DESC;

-- City-wise number of orders
SELECT 
    c.City,
    COUNT(o.order_id) AS total_orders
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY c.City
ORDER BY total_orders DESC;

-- Category-wise total revenue
SELECT 
    p.category,
    SUM(o.total_amount) AS category_revenue
FROM
    products p
        JOIN
    orders o ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

alter table customers
add column full_name varchar(100);

update customers
set full_name = concat(first_name, ' ',coalesce(last_name, ''));

set sql_safe_updates = 1;


-- Calculate total purchase for each customer
with customer_purchase AS (
	select 
		customer_id,
		sum(total_amount) as total_purchase
    from orders 
    group by customer_id
    )
    select
		c.full_name,
		cp.total_purchase
	from customer_purchase cp
    join customers c on cp.customer_id = c.customer_id
    order by cp.total_purchase desc;

-- Identify repeat customers
with order_count as(
	select
		customer_id, 
        count(customer_id) as total_orders
	from orders
    group by customer_id
    )
	select
		c.full_name,
        oc.total_orders
	from order_count oc
    join customers c on oc.customer_id = c.customer_id
    where oc.total_orders >1
    order by oc.total_orders desc;
    
-- Rank customers  by total spend
SELECT
    c.customer_id,
    c.full_name,
    SUM(o.total_amount) AS total_spend,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS spend_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY spend_rank;

-- Calculate month-on-month revenue growth
with monthly_revenue as (
	select 
		DATE_FORMAT(order_date, '%Y-%m') as month,
			sum(total_amount) as revenue
	from orders
    group by DATE_FORMAT(order_date, '%Y-%m')
    )
    select
		month,
        revenue,
        revenue - lag(revenue) over (order by month) as revenue_growth
	from monthly_revenue;
    
    -- find the top-selling product in each category
with product_sales as (
	select
        p.category,
        p.product_name,
        sum(o.total_amount) as revenue,
        row_number() over (partition by p.category order by sum(o.total_amount)
        desc
			) as rn
		from products p
        join orders o on p.product_id = o.product_id
        group by p.category, p.product_name
        )
        select
        category,
        product_name,
        revenue
        from product_sales
        where rn = 1;
		
    
    
    
    
    
    
    
    
















    

        