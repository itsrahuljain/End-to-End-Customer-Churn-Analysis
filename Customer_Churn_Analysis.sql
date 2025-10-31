select * from customer limit 10
-- Mention revenue of male vs female customer
select gender, Sum(purchase_amount) from customer
group by gender

--Mention those customer who uses discount but still their purchase amount is greater than average
select * from customer 
where 
purchase_amount > (select avg(purchase_amount) from customer) And
discount_applied = 'Yes'

--mention top 5 products with highest avg review ratings
select item_purchased , avg(review_rating)  from customer 
group by item_purchased
order by avg(review_rating) desc
limit 5

--compare the avg purchase amounts between standard and express shipping
select Round(avg(purchase_amount),2),shipping_type from customer
where shipping_type in ('Standard', 'Express')
group by shipping_type

--compare avg spend and total revenue from subscribed and non subscribed members
select subscription_status,count(customer_id),Sum(purchase_amount) as Total_revenue,Avg(purchase_amount) from customer 
where subscription_status in ('Yes','No')
group by subscription_status

--which 5 product have highest percentage of purchases with discount applied
select item_purchased, 
Round(100 * Sum(case when discount_applied = 'Yes' then 1 else 0 end)/count(*),2) as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5

-- segment customers into new, returning and loyal on the basis of their previous purchases and show the count of each customer
with customer_type as(
select customer_id, previous_purchases,
Case 
	when previous_purchases = 1 then 'New'
	when previous_purchases between 2 and 10 then 'Returning'
	else 'Loyal'
	end as customer_segment
from customer 
)
select customer_segment , count(*) as "Number of customers"
from customer_type
group by customer_segment


--what are the top 3 products with highest sales within category
with item_counts as (
select category,
item_purchased,
count(customer_id) as total_orders,
row_number() over(partition by category order by count(customer_id) desc) as item_rank
from customer
group by category, item_purchased
)
select item_rank, category, item_purchased, total_orders
from item_counts
where item_rank <=3;

--are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
select count(customer_id) ,subscription_status from customer
where previous_purchases > 5
and subscription_status in ('Yes', 'No')
group by subscription_status

--what is the revenue contribution of each age group
select age_group, sum(purchase_amount) as revenue_contri
from customer
group by age_group
order by revenue_contri desc