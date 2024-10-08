create database pizza_sales;
use pizza_sales;

-- creating the larger tables manually to avoid datatype mixup
create table orders (
order_id int not null primary key,
order_date date not null,
order_time time not null);

create table order_details (
order_details_id int not null  primary key,
order_id int not null,
pizza_id text not null,
quantity int not null);

-- total numbers of orders placed
select count(order_id) as total_orders 
from orders;

-- Total revenue generated
SELECT 
    SUM(order_details.quantity * pizzas.price) AS total_revenue
FROM
    order_Details
        INNER JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;

-- identify the highest price pizza
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- identify the most common pizza size ordered
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS no_of_pizzas
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY no_of_pizzas DESC;

-- List top 5 most ordered pizza types along with their quantities
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC
LIMIT 5;

-- Total quantity of each pizza category ordered
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS category_summary
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    Order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY category_summary DESC;

-- Determine distribution of orders by hrs of the day
SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY Hour;

-- Category wise distribution of pizzas
SELECT 
    name, category
FROM
    pizza_types;
    
-- Group the orders by date and calculate avg numbrs of pizzas ordered per day
SELECT 
    ROUND(AVG(Pizzas_ordered)) AS avg_pizza_orders_per_day
FROM
    (SELECT 
        orders.order_date,
            SUM(order_details.quantity) AS Pizzas_ordered
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;

-- Most ordered pizza based on the revenue
SELECT 
    pizza_types.name,
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price)) AS revenue_generated
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name , pizza_types.category
ORDER BY revenue_generated DESC limit 3;

-- percent contribution of each pizza type to total revenue
SELECT 
    pizza_types.category,
    (SUM(order_details.quantity * pizzas.price) / (SELECT 
            ROUND(SUM(order_details.quantity * pizzas.price)) AS total_revenue
        FROM
            order_Details
                JOIN
            pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100 AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category;

-- Analysis of cumulative revenue generated over time
select order_date, 
sum(revenue) over (order by order_date) as cummulative_revenue
from
(select orders.order_date, 
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
join orders
on orders.order_id = order_details.order_id
group by orders.order_date ) as sales;

-- top 3 most ordered pizza types based on revenue for each pizza category
select name,revenue
from
(select category, name, revenue, rank() over(Partition by category order by revenue desc) as most_ordered_pizzas 
from
(select pizza_types.category, pizza_types.name,
sum(order_details.quantity* pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where most_ordered_pizzas<=3
