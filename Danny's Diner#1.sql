# ------------------------------------SCHEMA ----------------------------------
CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
#1.  What is the total amount each customer spent at the restaurant?
select 	customer_id,
	sum(price) as amount_spent
from sales s
join menu m
on s.product_id = m.product_id
group by 1
order by 1; 

#2. How many days has each customer visited the restaurant?
select 	customer_id,
	count(order_date) as no_of_visits
from sales
group by 1;

#3. What was the first item from the menu purchased by each customer?
select distinct customer_id,
       first_value(product_name) over(partition by customer_id order by order_date) as first_item
from sales s
join menu m 
 on s.product_id = m.product_id;

#4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_name,
       count(s.product_id) as no_of_times_purchased
from menu m 
join sales s 
  on m.product_id = s.product_id
group by 1
order by 2 desc;

#5. Which item was the most popular for each customer?
select customer_id,
       group_concat(product_name separator " | ") as popular_product
from (
	select customer_id,
		product_name,
		count(s.product_id)  as no_of_purchases,
		rank() over(partition by customer_id order by count(s.product_id) desc) as most_ordered
	from sales s
	join menu m 
	using(product_id)
	group by customer_id, product_name ) x
where most_ordered = "1"
group by customer_id;

#6. Which item was purchased first by the customer after they became a member?
select s.customer_id,
	count(s.product_id) as total_items,
        sum(price) as amount_spent
from sales s 
join menu m 
 on s.product_id = m.product_id
join members b
 on s.customer_id = b.customer_id and
    s.order_date < b.join_date
group by 1;


#7. Which item was purchased just before the customer became a member?
select customer_id, group_concat(product_name separator ",") as product_name

from (select s.customer_id, product_name, order_date, join_date,
	    rank() over(partition by s.customer_id order by order_date desc) as rnk
from sales s
join menu m 
 on s.product_id = m.product_id
join members b
 on s.customer_id = b.customer_id and 
    s.order_date < b.join_date) x 
where rnk = 1
group by 1;


#8. Which item was purchased first by the customer after they became a member? 
with cte as (
		select s.customer_id, join_date, min(order_date) as order_dt
		from sales s
		join members m 
	         on s.customer_id = m.customer_id and
		    s.order_date >= m.join_date
		group by 1,2
	     )

select customer_id, product_name
from sales s
join menu m
 using(product_id)
join cte 
 using(customer_id)
where order_date = cte.order_dt ;


--- 2nd method
select customer_id, product_name 

from (select s.customer_id, product_name, order_date, join_date,
	rank() over(partition by s.customer_id order by order_date ) as rnk
from sales s
join menu m 
 on s.product_id = m.product_id
join members b
 on s.customer_id = b.customer_id and 
    s.order_date >= b.join_date) x 
where rnk = 1;

#9. What is the total items and amount spent for each member before they became a member?
select s.customer_id,
	count(s.product_id) as total_items,
        sum(price) as amount_spent
from sales s
join menu m 
 on s.product_id = m.product_id
join members b
 on s.customer_id = b.customer_id and 
    s.order_date < b.join_date
group by 1
order by 1;

#10. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select s.customer_id,
	SUM(case when product_name = 'sushi' then price *20 else
        price*10 end) as points
from sales s  
join menu m
 using(product_id)
GROUP BY 1;

#In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi how many points do customer A and B have at the end of January?

select s.customer_id,  
		sum(
	   case WHEN ORDER_DATE BETWEEN B.join_date and date_add(b.join_date, INTERVAL 6 DAY) then price *20
            when product_name = 'sushi' then price * 20 
            else price *10 end ) as points
from sales s  
join menu m
	using(product_id)
join members b
	on s.customer_id = b.customer_id 
WHERE month(order_date) = '01'
group by 1;


-- BONUS QUESTIONS
-- JOIN ALL THE THINGS

select s.customer_id,  
	order_date,
        product_name,
        price,
        case when order_date >= join_date then 'Y' else 'N' end as member 
from sales s  
join menu m
 using(product_id)
left join members b
 on s.customer_id = b.customer_id 
order by 1, 2;


-- RANK ALL THE THINGS
# Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
with cte as (
	select s.customer_id,
	       order_date,
               product_name,
               price,
               case when order_date >= join_date then 'Y' else 'N' end as member 
        from sales s  
	join menu m
	 using(product_id)
	left join members b
	 on s.customer_id = b.customer_id 
	order by 1, 2
		)

select * ,
		case when member = 'N' then Null else
		rank() OVER(PARTITION BY customer_id , member ORDER BY order_date) end as ranking
from cte 
