#-------------------------------------------SCHEMA----------------------------------------------------
CREATE SCHEMA danny_pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
 order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
 pickup_time VARCHAR(19),
 distance VARCHAR(7),
 duration VARCHAR(10),
 cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

#-------------------------------------------PIZZA METRICS-----------------------------------------------

-- 1 How many pizzas were ordered?
Select count(*) as orders from customer_orders;
/* output
	orders
    14
*/

-- 2. How many unique customer orders were made?
Select count(distinct order_id) as orders from customer_orders;

/* output
	orders
    10
*/


-- 3. How many successful orders were delivered by each runner?
select runner_id, COUNT(distinct order_id) as pizza_delivered
from runner_orders 
where pickup_time <> 'null'
GROUP BY RUNNER_ID;
/* OUTPUT
		runner_id	pizza_delivered
		1	4
		2	3
		3	1

*/
-- 4. How many of each type of pizza was delivered?
select pizza_name, count(*) as orders 
from customer_orders c
join runner_orders r
	on c.order_id = r.order_id 
join pizza_names p
	on c.pizza_id = p.pizza_id
where pickup_time <> 'null'
group by pizza_name;

# Output
-- Meatlovers	9
-- Vegetarian	3

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

select customer_id, pizza_name, count(*) as Pizza_ordered 
from customer_orders c
inner join pizza_names p
	on c.pizza_id = p.pizza_id
group by 1,2
order by 1, 2;

/*Output
101	Meatlovers	2
101	Vegetarian	1
102	Meatlovers	2
102	Vegetarian	1
103	Meatlovers	3
103	Vegetarian	1
104	Meatlovers	3
105	Vegetarian	1*/

-- 6. What was the maximum number of pizzas delivered in a single order?
-- Using Subquery 

select order_id, max(pizza_delivered) as pizza_delivered
from (
		select C.order_id, count(*) as pizza_delivered
		from customer_orders c
		inner join runner_orders r
			on c.order_id = r.order_id
		where pickup_time <> 'null'
		group by 1) x ;
        
-- w/o subquery       
select 
C.order_id, count(*) as pizza_delivered
from customer_orders c
inner join runner_orders r
on c.order_id = r.order_id
where pickup_time <> 'null'
group by C.order_id
order by count(*) desc
limit 1;

/*Output
	order_id	pizza_delivered
	4	3*/


-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select customer_id,
		sum(case when (exclusions is not null and exclusions <> 'null' and length(exclusions)>0) or
        (extras is not null and extras <> 'null' and length(extras)>0) = TRUE then 1 else 0 end ) changes,
        
        sum(case when (exclusions is not null and exclusions <> 'null' and length(exclusions)>0) or
        (extras is not null and extras <> 'null' and length(extras)>0) =TRUE then 0 else 1 end) as no_changes,
        count(pizza_id) as pizza_ordered
from customer_orders c
inner join runner_orders r 
	using(order_id)
where pickup_time <> 'null'
group by 1;

/* OUTPUT 
customer_id	changes	no_changes	pizza_ordered
101	0	2	2
102	0	3	3
103	3	0	3
104	2	1	3
105	1	0	1

*/

-- 8.How many pizzas were delivered that had both exclusions and extras?
select 
 sum(case when (exclusions is not null and exclusions <> 'null' and length(exclusions)>0) and 
				(extras is not null and extras <> 'null' and length(extras)>0 ) then 1 
                else 0 end) as pizza_delivered_with_exclusions_extras
from customer_orders c
inner join runner_orders r
on c.order_id = r.order_id
where pickup_time <> 'null';

/* Output
pizza_delivered_with_exclusions_extras			
1 */


-- 9.What was the total volume of pizzas ordered for each hour of the day?

select  date_format(order_time, '%H') as hour_of_the_day,
		count(pizza_id) as orders_per_hour
from customer_orders
group by 1
order by 1;
 
 /* OUTPUT
 hour_of_the_day	orders_per_hour	
11	1	
13	3	
18	3	
19	1	
21	3	
23	3	

 */

-- 10. What was the volume of orders for each day of the week?

select date_format(order_time, '%W') as day_of_week,
		count(pizza_id) AS pizza_ordered
group by 1;

/* OUTPUT
day_of week	pizza_ordered
Wednesday	5
Thursday	3
Saturday	5
Friday	1

*/
#--------------------------------------B. RUNNER AND CUSTOMER EXPERIENCE---------------------------------------------------------------

#1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

select concat('week', week(registration_date) +1) as week,
		count(runner_id) as runners_cnt
from runners
group by 1;

-- 2nd method 
SELECT CONCAT('Week', WEEK(registration_date) - WEEK('2021-01-01') + 1) AS week,
       COUNT(runner_id) AS runners_cnt
FROM runners
GROUP BY week;

/* output
		Week 	runner_cnt
		week1	1
		week2	2
		week3	1

*/

#2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select runner_id, concat(round(avg(minute(timediff(pickup_time, order_time)))), ' min') as avg_reaching_time
from customer_orders c
inner join runner_orders r
	using(order_id)
group by 1;

/*output
		runner_id	avg_reaching_time
		1	15 min
		2	23 min
		3	10 min
*/

#3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
with cte as (select order_id, count(pizza_id) as pizza_cnt, max(minute(timediff(pickup_time, order_time))) order_prep_time
from customer_orders c 
inner join runner_orders r 
	using(order_id)
where pickup_time <> 'null'
group by 1)

select pizza_cnt, round(avg(order_prep_time)) as order_prep_time
from cte 
group by 1;

/* Yes there exists direct relationship between number of pizza and the avg time taken to prepare
pizza_cnt	order_prep_time
1	12
2	18
3	29

*/

#4. What was the average distance travelled for each customer?
select customer_id, ROUND(AVG(replace(distance, 'km', ''))) as avg_distance_km
from customer_orders c
inner join runner_orders r
	using(order_id)
where distance <> 'null'
group by 1;

/* OUTPUT
customer_id	avg_distance_km
101	20
102	17
103	23
104	10
105	25

*/
#5. What was the difference between the longest and shortest delivery times for all orders?

		select max(substring(duration, 1, 2))   - min(substring(duration, 1, 2)) AS duration_diff
		from runner_orders
		where duration <>'null';

/* OUTPUT 
		duration_diff
		30
*/
#6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

select runner_id, order_id, round(avg(substring(distance, 1, 2)/ substring(duration, 1, 2)),2) as avg_speed
from runner_orders r 
where duration <> 'null'
group by 1,2;

/* OUTPUT
		runner_id	order_id	avg_speed
		1	1	0.62
		1	2	0.74
		1	3	0.65
		2	4	0.57
		3	5	0.67
		2	7	1
		2	8	1.53
		1	10	1


*/

#7. What is the successful delivery percentage for each runner?
with cte as (SELECT RUNNER_ID,  COUNT(*) as successful_delivery
FROM runner_orders 
WHERE pickup_time <> 'null'
GROUP BY 1 )

select r.runner_id, round(cte.successful_delivery*100/count(*), 2) as successfull_delivery_pct
from runner_orders r 
join cte
using(runner_id)
group by r.runner_id;

/* OUTPUT
runner_id	successful_delivery_pct	
1	100	
2	75	
3	50	
*/


# ------------------------------------- Pricing and Ratings---------------------------------------------------
# 1.  If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes -
# 	   how much money has Pizza Runner made so far if there are no delivery fees?
with cte as (select r.order_id, pizza_id, 
		case when pizza_id = 1 then 12 else 10 end as price_in_USD
from runner_orders r 
INNER JOIN customer_orders c
	on r.order_id = c.order_id
where pickup_time <> 'null'
)
 select concat('$', sum(price_in_usd)) as total_revenue
 from cte;
 
 /* OUTPUT
	total_revenue
    $138  */

# 2. What if there was an additional $1 charge for any pizza extras?
with cte as (select r.order_id, pizza_id, 
		case when pizza_id = 1 then 12 + 1* coalesce(LENGTH(extras), 0) -- Handling the case where the extras column is NULL by assigning a specific value (e.g., 0) in the calculation.
        else 10 + 1* coalesce(length(extras), 0) end as price_in_USD

from runner_orders r 
INNER JOIN customer_orders c
	on r.order_id = c.order_id
where pickup_time <> 'null'
)
 select concat('$', sum(price_in_usd)) as total_revenue
 from cte;
 
 /* OUTPUT 
	total_revenue
	$152 */
    
# 4 The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
 
 DROP TABLE IF EXISTS runner_ratings;
CREATE TABLE runner_ratings (
		order_id INTEGER,
        ratings INTEGER);
INSERT INTO runner_ratings ( order_id, ratings)
VALUES 
	(1, 3),
    (2, 4),
    (3, 3),
    (4, 5),
    (5, 1),
    (7, 2),
    (8, 3),
    (10, 4);
    
    SELECT * FROM runner_ratings;

# 5 Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries? customer_id, order_id, runner_id, rating, order_time, pickup_time, Time between order and pickup, Delivery duration, Average speed, Total number of pizzas
	-- AVERAGE SPEED =  DISTANCE / TIME
select customer_id, c.order_id, ro.runner_id, ratings, 
		TIME(order_time) as order_time, TIME(STR_TO_DATE(pickup_time, '%Y-%m-%d %H:%i:%s')) as pick_up_time,
		timestampdiff(MINUTE, order_time, STR_TO_DATE(pickup_time, '%Y-%m-%d %H:%i:%s')) as time_btwn_order_n_pickup_min,
        concat(substring(duration, 1, 2), ' min') as delivery_duration,
        round(REPLACE(distance, 'km', '')/substring(duration, 1, 2)*60, 2) as avg_speed_kmperhr,
        COUNT(pizza_id) AS pizza_count
from customer_orders c
INNER JOIN runner_orders ro
	ON c.order_id = ro.order_id
INNER JOIN runner_ratings rr
	on c.order_id = rr.order_id
where pickup_time <> 'null'
group by 1,2,3,4,5,6,7,8,9;

#6. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled. how much money does Pizza Runner have left over after these deliveries?
    
    with cte as (select sum(case when pizza_id = 1 then 12 else 10 end )as total_revenue ,
		round(sum(replace(distance, 'km', '')*0.30), 2) as delivery_cost
from customer_orders co
INNER JOIN runner_orders ro
	using(order_id)
where pickup_time <> 'null')

select (total_revenue - delivery_cost) as amount_aftr_deliveries
from cte ;

