-- ============================================================================
-- PIZZA DATABASE SQL QUERIES - COMPLETE COLLECTION
-- Levels: Basic, Intermediate, Advanced
-- ============================================================================

-- ============================================================================
-- BASIC LEVEL QUERIES
-- ============================================================================

-- 1. Retrieve the total number of orders placed
-- Explanation: Counts unique orders from the orders table
select count(distinct order_id) as total_orders
from orders;

-- Alternative: If you want total order lines
select count(order_details_id) as total_order_lines
from orders_details;

---

-- 2. Calculate the total revenue generated from pizza sales
-- Explanation: Multiplies quantity by price and sums all sales
select sum(orders_details.quantity * pizzas.price) as total_revenue
from orders_details
join pizzas on orders_details.pizza_id = pizzas.pizza_id;

---

-- 3. Identify the highest-priced pizza
-- Explanation: Finds the pizza with maximum price and shows its name and price
select pizza_types.name, pizzas.price
from pizzas
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
order by pizzas.price desc
limit 1;

---

-- 4. Identify the most common pizza size ordered
-- Explanation: Counts how many times each size was ordered, shows most frequent
select pizzas.size, count(orders_details.order_details_id) as order_count
from pizzas
join orders_details on pizzas.pizza_id = orders_details.pizza_id
group by pizzas.size
order by order_count desc
limit 1;

---

-- 5. List the top 5 most ordered pizza types along with their quantities
-- Explanation: Sums total quantity for each pizza type, shows top 5
select pizza_types.name, sum(orders_details.quantity) as total_quantity
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details on pizzas.pizza_id = orders_details.pizza_id
group by pizza_types.name
order by total_quantity desc
limit 5;

---

-- ============================================================================
-- INTERMEDIATE LEVEL QUERIES
-- ============================================================================

-- 6. Join necessary tables to find the total quantity of each pizza category ordered
-- Explanation: Groups by pizza category and sums quantities for each
select pizza_types.category, sum(orders_details.quantity) as total_quantity
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details on pizzas.pizza_id = orders_details.pizza_id
group by pizza_types.category
order by total_quantity desc;

---

-- 7. Determine the distribution of orders by hour of the day
-- Explanation: Extracts hour from order time, counts orders per hour
select extract(hour from orders.order_time) as order_hour, 
       count(distinct orders.order_id) as order_count
from orders
group by extract(hour from orders.order_time)
order by order_hour;

-- Note: If your database uses different syntax, try:
-- select hour(orders.order_time) as order_hour, 
--        count(distinct orders.order_id) as order_count
-- from orders
-- group by hour(orders.order_time)
-- order by order_hour;

---

-- 8. Join relevant tables to find the category-wise distribution of pizzas
-- Explanation: Shows count of pizzas in each category
select pizza_types.category, count(pizzas.pizza_id) as pizza_count
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category
order by pizza_count desc;

---

-- 9. Group orders by date and calculate average pizzas ordered per day
-- Explanation: Groups by date, counts total pizzas per day, then averages
select date(orders.order_date) as order_date, 
       sum(orders_details.quantity) as total_pizzas_per_day,
       count(distinct orders.order_id) as orders_per_day,
       round(avg(orders_details.quantity), 2) as avg_pizzas_per_order
from orders
join orders_details on orders.order_id = orders_details.order_id
group by date(orders.order_date)
order by order_date;

-- Note: If using SQL Server, replace date() with cast(order_date as date)

---

-- 10. Determine the top 3 most ordered pizza types based on revenue
-- Explanation: Calculates revenue per pizza type, shows top 3
select pizza_types.name, 
       sum(orders_details.quantity * pizzas.price) as total_revenue,
       sum(orders_details.quantity) as total_quantity
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details on pizzas.pizza_id = orders_details.pizza_id
group by pizza_types.name
order by total_revenue desc
limit 3;

---

-- ============================================================================
-- ADVANCED LEVEL QUERIES
-- ============================================================================

-- 11. Calculate the percentage contribution of each pizza type to total revenue
-- Explanation: Divides each pizza's revenue by total revenue, converts to percentage
select pizza_types.name,
       sum(orders_details.quantity * pizzas.price) as pizza_revenue,
       round(
           (sum(orders_details.quantity * pizzas.price) / 
            (select sum(orders_details.quantity * pizzas.price)
             from orders_details
             join pizzas on orders_details.pizza_id = pizzas.pizza_id) * 100), 2
       ) as percentage_contribution
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details on pizzas.pizza_id = orders_details.pizza_id
group by pizza_types.name
order by percentage_contribution desc;

---

-- 12. Analyze cumulative revenue generated over time
-- Explanation: Shows running total of revenue over dates
select order_date,
       sum(daily_revenue) over (order by order_date) as cumulative_revenue
from (
    select date(orders.order_date) as order_date,
           sum(orders_details.quantity * pizzas.price) as daily_revenue
    from orders
    join orders_details on orders.order_id = orders_details.order_id
    join pizzas on orders_details.pizza_id = pizzas.pizza_id
    group by date(orders.order_date)
) daily_sales
order by order_date;

-- Note: If using SQL Server, replace "OVER" window function with:
-- select order_date,
--        sum(daily_revenue) over (order by order_date rows between unbounded preceding and current row) as cumulative_revenue

---

-- 13. Determine top 3 most ordered pizza types by revenue for each pizza category
-- Explanation: Ranks pizzas within each category, shows top 3 per category
select category, name, total_revenue, pizza_rank
from (
    select pizza_types.category,
           pizza_types.name,
           sum(orders_details.quantity * pizzas.price) as total_revenue,
           row_number() over (partition by pizza_types.category order by sum(orders_details.quantity * pizzas.price) desc) as pizza_rank
    from pizza_types
    join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
    join orders_details on pizzas.pizza_id = orders_details.pizza_id
    group by pizza_types.category, pizza_types.name
) ranked_pizzas
where pizza_rank <= 3
order by category, pizza_rank;

-- Note: If using SQL Server or older MySQL without ROW_NUMBER(), use:
-- select category, name, total_revenue
-- from (
--     select pizza_types.category,
--            pizza_types.name,
--            sum(orders_details.quantity * pizzas.price) as total_revenue,
--            rank() over (partition by pizza_types.category order by sum(orders_details.quantity * pizzas.price) desc) as pizza_rank
--     from pizza_types
--     join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
--     join orders_details on pizzas.pizza_id = orders_details.pizza_id
--     group by pizza_types.category, pizza_types.name
-- ) ranked_pizzas
-- where pizza_rank <= 3

---

-- ============================================================================
-- BONUS QUERIES
-- ============================================================================

-- Bonus 1: Best selling pizza by size and category combination
select pizza_types.category, pizzas.size, 
       count(orders_details.order_details_id) as order_frequency,
       sum(orders_details.quantity) as total_quantity,
       round(sum(orders_details.quantity * pizzas.price), 2) as total_revenue
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details on pizzas.pizza_id = orders_details.pizza_id
group by pizza_types.category, pizzas.size
order by total_revenue desc;

---

-- Bonus 2: Orders with multiple pizza types in single order
select orders.order_id, orders.order_date, 
       count(distinct pizza_types.category) as distinct_categories,
       sum(orders_details.quantity) as total_pizzas,
       round(sum(orders_details.quantity * pizzas.price), 2) as order_total
from orders
join orders_details on orders.order_id = orders_details.order_id
join pizzas on orders_details.pizza_id = pizzas.pizza_id
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by orders.order_id, orders.order_date
having count(distinct pizza_types.category) > 1
order by order_total desc;

---

-- ============================================================================
-- END OF SQL QUERIES
-- ============================================================================
