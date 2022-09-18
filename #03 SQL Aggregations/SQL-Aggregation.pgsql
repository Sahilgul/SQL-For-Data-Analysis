-- In the following concepts you will be learning in detail about each of the aggregate functions mentioned as well as some 
-- additional aggregate functions that are used in SQL all the time. Let's get started!

-- Introduction to NULL
-- NULLs are a datatype that specifies where no data exists in SQL. They are often ignored in our aggregation functions,
-- which you will get a first look at in the next concept using COUNT

-- Notice that NULLs are different than a zero - they are cells where data does not exist.

-- When identifying NULLs in a WHERE clause, we write IS NULL or IS NOT NULL. We don't use =, because NULL 
-- isn't considered a value in SQL. Rather, it is a property of the data.

-- NULLs - Expert Tip
-- There are two common ways in which you are likely to encounter NULLs:

-- NULLs frequently occur when performing a LEFT or RIGHT JOIN. You saw in the last lesson - when some rows in the 
-- left table of a left join are not matched with rows in the right table, those rows will contain some NULL values in the result set.


-- NULLs can also occur from simply missing data in our database.

-- Aggregation
-- Count No of rows in accounts
SELECT COUNT(*)
FROM accounts;

-- Tip 
-- If count of a column is less than no of rows in table,
-- then it's mean that there is difference of null



-- Aggregation SUM practice

-- Aggregation Questions
-- Use the SQL environment below to find the solution for each of the following questions. 
-- If you get stuck or want to check your answers, you can find the answers at the top of the next concept.
SELECT *
FROM orders;

-- 1-Find the total amount of poster_qty paper ordered in the orders table.

SELECT SUM(poster_qty) total_amt_poster
FROM orders;

-- 2-Find the total amount of standard_qty paper ordered in the orders table.
SELECT SUM(standard_qty) total_amt_std
FROM orders;

-- 3-Find the total dollar amount of sales using the total_amt_usd in the orders table.

SELECT SUM(total_amt_usd) total_amt
FROM orders;

-- 4-Find the total amount spent on standard_amt_usd and gloss_amt_usd paper for each order in the orders table. 
-- This should give a dollar amount for each order in the table.
SELECT SUM(standard_amt_usd) std_amt, SUM(gloss_amt_usd) gloss_amt
FROM orders;

-- 5-Find the standard_amt_usd per unit of standard_qty paper. Your solution should use both an aggregation and a mathematical operator.
SELECT SUM(standard_amt_usd)/SUM(standard_qty) per_unit
FROM  orders;

-- practice MIN,MIX, AVG

-- Aggregation Questions
-- Use the SQL environment below to find the solution for each of the following questions. 
-- If you get stuck or want to check your answers, you can find the answers at the top of the next concept.
SELECT *
FROM orders;

-- 1-Find the total amount of poster_qty paper ordered in the orders table.

SELECT SUM(poster_qty) total_amt_poster
FROM orders;

-- 2-Find the total amount of standard_qty paper ordered in the orders table.
SELECT SUM(standard_qty) total_amt_std
FROM orders;

-- 3-Find the total dollar amount of sales using the total_amt_usd in the orders table.

SELECT SUM(total_amt_usd) total_amt
FROM orders;

-- 4-Find the total amount spent on standard_amt_usd and gloss_amt_usd paper for each order in the orders table. 
-- This should give a dollar amount for each order in the table.
SELECT standard_amt_usd,gloss_amt_usd,
standard_amt_usd + gloss_amt_usd AS total_standard_gloss
FROM orders;

-- 5-Find the standard_amt_usd per unit of standard_qty paper. Your solution should use both an aggregation and a mathematical operator.
SELECT SUM(standard_amt_usd)/SUM(standard_qty) per_unit
FROM  orders;

-- Questions: MIN, MAX, & AVERAGE


-- 1-When was the earliest order ever placed? You only need to return the date.
SELECT MIN(occurred_at) earliest_order
FROM orders; --2013-12-04 04:22:44


-- 2-Try performing the same query as in question 1 without using an aggregation function.
SELECT occurred_at
FROM orders
ORDER BY occurred_at
LIMIT 1; --2013-12-04 04:22:44



-- 3-When did the most recent (latest) web_event occur?
SELECT MAX(occurred_at)
FROM web_events; --2017-01-01 23:51:09



-- 4-Try to perform the result of the previous query without using an aggregation function.
SELECT occurred_at
FROM web_events
ORDER BY occurred_at DESC
LIMIT 1; --2017-01-01 23:51:09




-- 5-Find the mean (AVERAGE) amount spent per order on each paper type, as well as the mean amount of each paper type purchased per order. 
-- Your final answer should have 6 values - one for each paper type for the average number of sales, as well as the average amount.
SELECT 
ROUND(AVG(standard_amt_usd)) as std_avg_std,
ROUND(AVG(gloss_amt_usd)) goss_amt_avg,
ROUND(AVG(poster_amt_usd)) poster_amt_avg,
ROUND(AVG(standard_qty)) as std_avg_qty_,
ROUND(AVG(gloss_qty)) goss_qty_avg,
ROUND(AVG(poster_qty)) poster_qty_avg
FROM orders;




-- 6-Via the video, you might be interested in how to calculate the MEDIAN. 
-- Though this is more advanced than what we have covered so far try finding - what is the MEDIAN total_usd spent on all orders?
SELECT ROUND(AVG(total_amt_usd)) total_usd_spent
FROM orders;



-- Practice on GROUP BY
-- #1Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.
SELECT a.name,max(o.occurred_at) order_occurr
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name
ORDER BY order_occurr DESC
LIMIT 1;

-- #2Find the total sales in usd for each account. You should include two columns - the total sales for each company's orders 
--  in usd and the company name.
SELECT a.name company,SUM(o.total)
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY a.name
ORDER BY company;




-- #3Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? 
--  Your query should return only three values - the date, channel, and account name. (2017-01-01 23:51:09)
SELECT MAX(w.occurred_at) recent_order,a.name,w.channel
FROM accounts a
JOIN web_events w
ON w.account_id = a.id
GROUP BY a.name,w.channel
ORDER BY recent_order DESC
LIMIT 1;




-- #4Find the total number of times each type of channel from the web_events was used. Your final table should have two columns - 
-- the channel and the number of times the channel was used.
SELECT w.channel, COUNT(w.channel) no_of_time_ch_rp
FROM web_events w
GROUP BY w.channel;




-- #5Who was the primary contact associated with the earliest web_event?
SELECT a.primary_poc, MAX(w.occurred_at)
FROM accounts a
JOIN web_events w
ON w.account_id = a.id
GROUP BY a.primary_poc
ORDER BY max DESC
LIMIT 1;




-- #6What was the smallest order placed by each account in terms of total usd. Provide only two columns - 
-- the account name and the total usd. Order from smallest dollar amounts to largest.
SELECT a.name,MIN(o.total_amt_usd)
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name
ORDER BY name;


-- #7Find the number of sales reps in each region. Your final table should have two columns - the region and the number of sales_reps. 
-- Order from fewest reps to most reps.
SELECT COUNT(s.name) sales_reps,r.name region
FROM sales_reps s
JOIN region r
ON r.id = s.region_id
GROUP BY region
ORDER BY sales_reps

-- ORDER  BY PART II

-- #1For each account, determine the average amount of each type of paper they purchased across their orders. 
-- Your result should have four columns - one for the account name and one for 
-- the average quantity purchased for each of the paper types for each account.
SELECT a.name,
    ROUND(AVG(o.standard_qty)) AVG_standard,
    ROUND(AVG(o.gloss_qty)) AVG_gloss,
    ROUND(AVG(o.poster_qty)) AVG_poster
    FROM accounts a
    JOIN orders o
    ON o.account_id = a.id
    GROUP BY a.name;

-- #2For each account, determine the average amount spent per order on each paper type. 
-- Your result should have four columns - one for the account name and one for the average amount spent on each paper type.
SELECT a.name,
    ROUND(AVG(o.standard_amt_usd)) standard_amt_Avg,
    ROUND(AVG(o.gloss_amt_usd)) gloss_amt_Avg,
    ROUND(AVG(o.poster_amt_usd)) poster_amt_Avg
    FROM accounts a
    JOIN orders o
    ON o.account_id = a.id
    GROUP BY name;



-- #3Determine the number of times a particular channel was used in the web_events table for each sales rep. 
-- Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences. 
-- Order your table with the highest number of occurrences first.

SELECT s.name,
w.channel channel,count(w.occurred_at)
FROM sales_reps s
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN web_events w
ON w.account_id = a.id
GROUP BY w.channel,s.name
ORDER BY 3 DESC;




-- #4Determine the number of times a particular channel was used in the web_events table for each region. 
-- Your final table should have three columns - the region name, the channel, and the number of occurrences. 
-- Order your table with the highest number of occurrences first.

SELECT r.name,w.channel,COUNT(*)
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN web_events w
ON w.account_id = a.id
GROUP BY r.name,w.channel
ORDER BY count DESC;


-- DISTINCT 

SELECT account_id,channel,count(id) events
FROM web_events
GROUP BY account_id,channel
ORDER BY account_id, events DESC; 

--if you want to groupy by but do not want to include any aggregation
-- you can use distnict
SELECT account_id,channel
FROM web_events
GROUP BY account_id,channel
ORDER BY account_id;


SELECT DISTINCT account_id,channel
FROM web_events
ORDER BY account_id;



-- QUIZ DISTINCT
-- 1-Use DISTINCT to test if there are any accounts associated with more than one region.
SELECT DISTINCT r.id,r.name,s.name sales_rep_name,s.region_id,a.name account_name
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
ORDER BY account_name DESC;



-- 2-Have any sales reps worked on more than one account?
SELECT s.id,s.name,COUNT(a.id)
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
GROUP BY s.id,s.name
ORDER BY count DESC;


SELECT sales_rep_id,count(*)
FROM accounts
GROUP BY sales_rep_id
ORDER BY count DESC;
SELECT DISTINCT sales_rep_id
FROM accounts;

-- HAVING
-- When you applied aggregated function on some column
-- then if you want to see some specific results you can't use 
-- WHere clause, instead of this you can use HAVING Clause

-- 1-How many of the sales reps have more than 5 accounts that they manage?
SELECT s.name, COUNT(a.*)
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
GROUP BY s.name
HAVING COUNT(*)>5
ORDER BY count;

SELECT COUNT(*) sales_rep_5
FROM(
	SELECT s.name, COUNT(a.*)
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
GROUP BY s.name
HAVING COUNT(*)>5
ORDER BY count
) as t1;




-- 2-How many accounts have more than 20 orders?
SELECT o.total,COUNT(*)
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY o.total --a.name
HAVING count(*)>20;

SELECT a.name,COUNT(*)
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY a.name
HAVING COUNT(*)>20;

SELECT COUNT(*) greater_20
FROM(
	SELECT a.name,COUNT(*)
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY a.name
HAVING COUNT(*)>20
) tb2;




-- 3-Which account has the most orders?
SELECT MAX(maxi) maxi_order
FROM(
SELECT a.name,MAX(o.total)  maxi
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY a.name
HAVING MAX(o.total)>1000
) tb3;

SELECT a.id,a.name, COUNT(*) no_order
FROM accounts a
JOIN orders o
ON o.account_id  = a.id
GROUP BY a.id,a.name
ORDER BY no_order DESC
LIMIT 1;




-- 4-Which accounts spent more than 30,000 usd total across all orders?
SELECT a.id,a.name,SUM(total_amt_usd) amnt
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id,a.name
HAVING SUM(total_amt_usd)>30000
ORDER BY amnt;




-- 5-Which accounts spent less than 1,000 usd total across all orders?
SELECT a.id,a.name,SUM(total_amt_usd) amnt
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id,a.name
HAVING SUM(total_amt_usd)<1000
ORDER BY amnt;





-- 6-Which account has spent the most with us?
SELECT a.id,a.name,SUM(total_amt_usd) amnt
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id,a.name
-- HAVING SUM(total_amt_usd)<1000
ORDER BY amnt DESC
LIMIT 1;






-- 7-Which account has spent the least with us?
SELECT a.id,a.name,SUM(total_amt_usd) amnt
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id,a.name
-- HAVING SUM(total_amt_usd)<1000
ORDER BY amnt 
LIMIT 1;





-- 8-Which accounts used facebook as a channel to contact customers more than 6 times?
SELECT a.id,a.name,w.channel,COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON w.account_id = a.id
GROUP BY a.id,a.name,w.channel
HAVING COUNT(*)>6 AND channel='facebook'
ORDER BY use_of_channel;




-- 9-Which account used facebook most as a channel?
SELECT a.id,a.name,w.channel,COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON w.account_id = a.id
GROUP BY a.id,a.name,w.channel
HAVING channel='facebook'
ORDER BY use_of_channel DESC
LIMIT 1;




-- 10-Which channel was most frequently used by most accounts?
SELECT w.channel chn,COUNT(*) no_of_time_used
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
GROUP BY chn
ORDER BY no_of_time_used DESC
LIMIT 1;

SELECT a.id,a.name,w.channel chn,COUNT(*) no_of_time_used
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
GROUP BY chn,a.id,a.name
ORDER BY no_of_time_used DESC
LIMIT 20;



-- DATE
-- 1-Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least. 
-- Do you notice any trends in the yearly sales totals?
SELECT DATE_TRUNC('year',o.occurred_at) each_year,
SUM(o.total_amt_usd)
FROM orders o
GROUP BY 1
ORDER  BY 2 DESC;





-- 2-Which month did Parch & Posey have the greatest sales in terms of total dollars? Are all months evenly represented by the dataset?
SELECT DATE_PART('month',o.occurred_at) each_month,
SUM(o.total_amt_usd) total
FROM orders o
GROUP BY 1
ORDER BY 2 DESC
------------ by udacity
SELECT DATE_PART('month', occurred_at) ord_month, SUM(total_amt_usd) total_spent
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC; 




-- 3-Which year did Parch & Posey have the greatest sales in terms of total number of orders? Are all years evenly represented by 
    -- the dataset?
SELECT DATE_PART('year',o.occurred_at) yearly,
COUNT(o.total) total_order
FROM orders o
GROUP BY 1
ORDER BY 2 DESC
-- LIMIT 1;



-- 4-Which month did Parch & Posey have the greatest sales in terms of total number of orders? Are all months evenly represented 
    -- by the dataset?
SELECT DATE_PART('month',o.occurred_at) monthly,
COUNT(*) total_order
FROM orders o
GROUP BY 1
ORDER BY 2 DESC
-- LIMIT 1;




-- 5-In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
SELECT DATE_TRUNC('month',o.occurred_at) monthly,SUM(o.gloss_amt_usd) gloss_amt
FROM accounts a
JOIN orders o
ON o.account_id = a.id
WHERE name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;



SELECT id, account_id, 
CASE
	WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
	ELSE standard_amt_usd/standard_qty
END
unit_price,
CASE
	WHEN id <=10 THEN 'below 10'
	WHEN id <=20 THEN 'below 20'
	WHEN id <=30 THEN 'below 30'
	WHEN id <=40 THEN 'below 40'
	WHEN id <=50 THEN 'below 50'
	ELSE 'Other'
END
id_check

FROM orders
LIMIT 100;

SELECT id, account_id, 
CASE
	WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
	ELSE standard_amt_usd/standard_qty
END
unit_price,
CASE
	WHEN id >50 THEN 'Other'
	WHEN id >40 AND id<=50 THEN '40-50'
	WHEN id >30 AND id<=40 THEN '30-40'
	WHEN id >20 AND id<=30 THEN '20-30'
	WHEN id >10 AND id<=20 THEN '10-20'
	WHEN id >1 AND id<=10 THEN '1-10'
-- 	ELSE 'Don"t Know'
END
id_check
FROM orders
LIMIT 100;


SELECT CASE 
	WHEN total>500 THEN 'Over 500'
	ELSE '500 or less'
	END total_group,
	COUNT(*) order_count
FROM orders
GROUP BY 1;
-- We can calculate by using WHERE but where only support one condition at a time
SELECT COUNT(*) as order_count
FROM orders
WHERE total>500;






-- 1. Write a query to display for each order, the account ID, total amount of the order, and the level of the order 
-- - ‘Large’ or ’Small’ - depending on if the order is $3000 or more, or smaller than $3000.

SELECT account_id,total_amt_usd,
CASE
	WHEN total_amt_usd >=3000 THEN 'Large'
	ELSE 'Small'
END level_of_order
FROM orders;





-- 2. Write a query to display the number of orders in each of three categories, based on the total number of items in each order. 
-- The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.
SELECT account_id,total,
CASE
	WHEN total>=2000 THEN 'At Least 2000'
	WHEN total>=1000 AND total<2000 THEN 'Between 1000 and 2000'
	ELSE 'Less than 1000'
END category
FROM orders 
ORDER BY 2 DESC;




-- 3. We would like to understand 3 different levels of customers based on the amount associated with their purchases. 
-- The top level includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd. 
-- The second level is between 200,000 and 100,000 usd. 
-- The lowest level is anyone under 100,000 usd. Provide a table that includes the level associated with each account. 
-- You should provide the account name, the total sales of all orders for the customer, and the level. 
-- Order with the top spending customers listed first.

SELECT  o.account_id,a.name,o.total,o.total_amt_usd,
CASE
	WHEN o.total_amt_usd >200000 THEN 'Top Level'
	WHEN o.total_amt_usd >=100000 AND o.total_amt_usd <=200000 THEN 'Second Level'
	ELSE 'Lowest Level'
END level_of_customer
FROM orders o
JOIN accounts a
ON a.id = o.account_id
ORDER BY 4 DESC;




-- 4. We would now like to perform a similar calculation to the first, 
-- but we want to obtain the total amount spent by customers only in 2016 and 2017. 
-- Keep the same levels as in the previous question. Order with the top spending customers listed first.
SELECT a.id,a.name,o.total,o.total_amt_usd,DATE_PART('year',o.occurred_at),
CASE
	WHEN o.total_amt_usd >200000 THEN 'Top Level'
	WHEN o.total_amt_usd >=100000 AND o.total_amt_usd <=200000 THEN 'Second Level'
	ELSE 'Lowest Level'
END as customer
FROM accounts a
JOIN orders o
ON o.account_id = a.id
WHERE occurred_at BETWEEN '2016-1-1' AND '2017-12-30'
ORDER BY 4 DESC;




-- 5. We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders. 
-- Create a table with the sales rep name, the total number of orders, 
-- and a column with top or not depending on if they have more than 200 orders. 
-- lace the top sales people first in your final table.
SELECT s.name,o.total,
CASE
	WHEN total>200 THEN 'Top Seller'
	ELSE 'Not Top Seller'
END as sales_rank
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
ORDER BY 3 DESC;



-- 6. The previous didn't account for the middle, nor the dollar amount associated with the sales. 
-- Management decides they want to see these characteristics represented as well. 
-- We would like to identify top performing sales reps, which are sales reps associated with more than 
-- 200 orders or more than 750000 in total sales. The middle group has any rep with more than 150 orders or 500000 in sales. 
-- Create a table with the sales rep name, the total number of orders, total sales across all orders, 
-- and a column with top, middle, or low depending on this criteria. 
-- Place the top sales people based on dollar amount of sales first in your final table. 
-- You might see a few upset sales people by this criteria!

SELECT s.name,o.total,o.total_amt_usd,
CASE
	WHEN total>200 OR total_amt_usd>750000 THEN 'Top'
	WHEN total>150 OR total_amt_usd>500000 THEN 'Middle'
	ELSE 'Low'
END sales_reps_rank
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
ORDER BY 3 DESC;

