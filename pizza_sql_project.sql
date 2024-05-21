create database Pizza_Hut;
use Pizza_Hut;

create table orders(
 order_id int not null,
 order_date date not null, 
 order_time time not null,
 primary key(order_id));

create table order_details (
order_details_id int not null,
 order_id int not null,
 pizza_id text not null,
 quantity int not null,
 primary key(order_details_id));
 
 -- Basic:
-- 1)Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;

-- 2) Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(p.price * o.quantity), 2) AS 'total revenue'
FROM
    pizzas AS p
        JOIN
    order_details AS o ON p.pizza_id = o.pizza_id;

-- 3) Identify the highest-priced pizza.

SELECT 
    pt.name, p.price
FROM
    pizzas AS p
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1;

 -- 4) Identify the most common pizza size ordered
SELECT 
    p.size, COUNT(o.order_details_id) AS order_count
FROM
    pizzas AS p
        JOIN
    order_details AS o ON p.pizza_id = o.pizza_id
GROUP BY size
ORDER BY order_count DESC;
 
 -- 5) List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(o.quantity) as sum_quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS o ON p.pizza_id = o.pizza_id
GROUP BY pt.name order by sum_quantity desc limit 5;  

-- Intermediate:

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) as total_quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY category;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_time) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
select category,count(name) from pizza_types group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    AVG(sum_quantity)
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS sum_quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY order_date) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, SUM(p.price * od.quantity) AS revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    ROUND(SUM(p.price * od.quantity),2) / (SELECT 
            ROUND(SUM(p.price * od.quantity),2) AS revenue
        FROM
            order_details od
                JOIN
            pizzas p ON od.pizza_id = p.pizza_id) * 100 AS revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY revenue DESC;


-- Analyze the cumulative revenue generated over time.
select order_date,sum(revenue) over(order by order_date) as cum_revenue from
(select orders.order_date,round(sum(order_details.quantity * pizzas.price),2) as revenue from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id 
join  orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name , revenue from 
(select category,name,revenue,rank() over(partition by category order by revenue desc) as rn from
(SELECT 
    pt.category, pt.name , SUM((p.price) * od.quantity) as revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.category,pt.name) as a) as b where rn <=3;