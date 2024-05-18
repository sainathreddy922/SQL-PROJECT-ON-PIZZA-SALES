create database dominos;
use dominos;
select * from pizzas;	
select * from pizza_types;
select * from orders;
select * from orders_details;

-- 1. Retrieve the total number of orders placed.
select count(*)
 as totoal_no_of_orders 
   from orders;

-- 2. Calculate the total revenue generated from pizza sales.
select round(sum(o.quantity*p.price),2) as total_sales 
from pizzas as p
 inner join orders_details as o
    on o.pizza_id=p.pizza_id ;

-- 3. Identify the highest-priced pizza.
select pt.name,max(p.price) as highest_price 
from pizzas as p inner join pizza_types as pt
on pt.pizza_type_id=p.pizza_type_id
group by pt.name
order by highest_price desc
limit 1;

-- 4. Identify the most common pizza size ordered.
select p.size,count(o.order_details_id) as count_of_pizzas 
from pizzas as p 
inner join orders_details as o
on o.pizza_id=p.pizza_id 
group by size
order by count_of_pizzas desc;

-- 5. List the top 5 most ordered pizza types along with their quantities.

select pt.name, sum(o.quantity) as total_quantity
from pizza_types as pt
inner join pizzas as p on p.pizza_type_id=pt.pizza_type_id  
inner join orders_details as o
on o.pizza_id=p.pizza_id 
group by pt.name
order by total_quantity desc
limit 5;

-- 6.Join the necessary tables to find the total quantity of each pizza category ordered.

select pt.category,sum(o.quantity) as total_quantity 
 from orders_details as o
inner join pizzas as p on p.pizza_id=o.pizza_id
inner join pizza_types as pt on pt.pizza_type_id=p.pizza_type_id
group by pt.category
order by total_quantity desc; 

-- 7.Determine the distribution of orders by hour of the day .

select hour(order_time),count(order_id) as total_orders from orders
group by hour(order_time)
order by total_orders desc;

-- 8.Join relevant tables to find the category-wise distribution of pizzas.

select category,count(name) from pizza_types 
group by category;

-- 9.Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(total_quantity),2) as avg_no_of_pizza_perday from
(select order_date,sum(od.quantity) as total_quantity 
from orders as o inner join orders_details as od on 
od.order_id=o.order_id
group by order_date) as d ; 

-- 10.Determine the op 3 most ordered pizza types based on revenue.

select pt.name,round(sum(o.quantity*p.price),2) as revenue from pizzas as p
 inner join orders_details as o
on o.pizza_id=p.pizza_id inner join pizza_types as pt on pt.pizza_type_id=p.pizza_type_id 
group by pt.name
order by revenue desc
limit 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.

select pt.category,(sum(p.price * od.quantity) /(select round(sum(o.quantity*p.price),2)
 as revenue from pizzas as p
 inner join orders_details as o
on o.pizza_id=p.pizza_id inner join pizza_types as pt 
on pt.pizza_type_id=p.pizza_type_id))*100 as rev from pizza_types as pt
inner join pizzas as p on pt.pizza_type_id=p.pizza_type_id 
inner join orders_details as od on od.pizza_id=p.pizza_id
group by pt.category;

-- 12. Analyze the cumulative revenue generated over time.

select order_date,
sum(revenue)over(order by order_date) as cummulative_revenue from
(select od.order_date ,round(sum(o.quantity*p.price),2) as revenue from pizzas as p 
inner join orders_details as o on o.pizza_id=p.pizza_id
inner join orders  as od on od.order_id=o.order_id
group by od.order_date) as a;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, category,total_sales from
(select name,category,total_sales,
rank()over(partition by category order by  total_sales desc) as rnk 
from
(select pt.name,pt.category,round(sum(o.quantity*p.price),2) as total_sales from
 pizzas as p
inner join orders_details as o
on o.pizza_id=p.pizza_id
inner join pizza_types as pt on pt.pizza_type_id=p.pizza_type_id 
group by pt.name,pt.category) as a) as aa
where rnk<=3;	 



