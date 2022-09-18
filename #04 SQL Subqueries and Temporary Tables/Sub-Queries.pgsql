-- subqueries and table expressions are methods for being able to write a query that creates a table, 
-- and then write a query that interacts with this newly created table


-- When to use Subquery ?
    -- Whenever we need to use existing tables to create a new table that we then want to query again, 
    -- this is an indication that we will need to use some sort of subquery

-- 1 - Practice Question
-- We want to find the average number of events for each day for each channel. 
-- The first table will provide us the number of events for each day and channel, 
-- and then we will need to average these values together using a second query.

SELECT DATE_TRUNC('day',occurred_at),channel,
COUNT(*) event_count
FROM web_events
GROUP BY 1,2
ORDER BY 3 DESC;




-- 2 - Create Subquery that returns all from previous query
SELECT *
FROM(
    SELECT DATE_TRUNC('day',occurred_at),channel,
    COUNT(*) event_count
    FROM web_events
    GROUP BY 1,2
    ORDER BY 3 DESC
)tb1;





-- 3 - Find the avg no of events for each channel
SELECT channel, AVG(event_count) avg_event_count
FROM
	(SELECT DATE_TRUNC('day',occurred_at),channel,
		COUNT(*) event_count
	FROM web_events
	GROUP BY 1,2)tb1

GROUP BY channel
ORDER  BY 2 DESC;



-- Badly Formatted query
SELECT * FROM (SELECT DATE_TRUNC('day',occurred_at) AS day, channel, COUNT(*) as events FROM web_events GROUP BY 1,2 ORDER BY 3 DESC) sub;

-- Well formatted query
SELECT channel, AVG(event_count) avg_event_count
FROM
	(SELECT DATE_TRUNC('day',occurred_at),
	 		channel,COUNT(*) event_count
	FROM web_events
	GROUP BY 1,2)tb1
GROUP BY channel
ORDER  BY 2 DESC;


		
-- Tip
    -- Note that you should not include an alias when you write a subquery in a conditional statement. 
    -- This is because the subquery is treated as an individual value (or set of values in the IN case) rather than as a table.



-- Use date_trunc to pull month level information about 
-- order placed in the orders table.

SELECT *
FROM
	(SELECT 
	 	DATE_TRUNC('month',MIN(occurred_at)) as earliest_month
	FROM orders) tb1

JOIN orders o
    ON DATE_TRUNC('month',o.occurred_at) = earliest_month
    ORDER BY 4;



-- Use the result of previous query to find only orders that
-- took place in the same month and year as the first order
-- and then pull the avg for each type of paper qty
-- in this month
SELECT AVG(standard_qty) std_avg,
        AVG(gloss_qty) gloss_avg,
        AVG(poster_qty) poster_avg
FROM orders
    WHERE DATE_TRUNC('month',occurred_at)=
		(SELECT 
	 		DATE_TRUNC('month',MIN(occurred_at)) as earliest_month
		FROM orders);
		
		



--     1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
-- MINE which is wrong
SELECT s.name,r.name,MAX(o.total_amt_usd)
FROM sales_reps s
JOIN region r
ON r.id = s.region_id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
GROUP BY s.name,r.name;

-- This will give total sales by each sales man
SELECT s.name s_name,r.name r_name,SUM(o.total_amt_usd) total_sales
FROM sales_reps s
JOIN region r
ON r.id = s.region_id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id=a.id
GROUP BY 1,2;

-- Now we have to find maximum sales from all 50 for each region
-- And have to Join previous sum table according to region name and max
SELECT s_name,tb3.r_name,maximum
FROM
(SELECT r_name,MAX(total_sales) maximum
FROM(
	SELECT s.name s_name,r.name r_name,SUM(o.total_amt_usd) total_sales
	FROM sales_reps s
	JOIN region r
	ON r.id = s.region_id
	JOIN accounts a
	ON a.sales_rep_id = s.id
	JOIN orders o
	ON o.account_id=a.id
	GROUP BY 1,2
)tb1
GROUP BY 1) tb2
JOIN (
	SELECT s.name s_name,r.name r_name,SUM(o.total_amt_usd) total_sales
	FROM sales_reps s
	JOIN region r
	ON r.id = s.region_id
	JOIN accounts a
	ON a.sales_rep_id = s.id
	JOIN orders o
	ON o.account_id=a.id
	GROUP BY 1,2
) tb3
ON tb2.r_name=tb3.r_name AND tb2.maximum=tb3.total_sales ;





--     2. For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?
-- MINE is accurate
SELECT r_name,count_order
FROM
(SELECT r_name,MAX(total_sales),count_order
FROM(
	SELECT r.name r_name,SUM(o.total_amt_usd) total_sales, COUNT(*) count_order
	FROM sales_reps s
	JOIN region r
	ON r.id = s.region_id
	JOIN accounts a
	ON a.sales_rep_id = s.id
	JOIN orders o
	ON o.account_id=a.id
	GROUP BY 1)tb1
GROUP BY 1,3
ORDER BY 2 DESC
LIMIT 1)tb2;



-- Udacity
	SELECT r.name r_name, COUNT(*) count_order
	FROM sales_reps s
	JOIN region r
	ON r.id = s.region_id
	JOIN accounts a
	ON a.sales_rep_id = s.id
	JOIN orders o
	ON o.account_id=a.id
	GROUP BY 1
HAVING SUM(o.total_amt_usd)=(
	SELECT MAX(total_sales)
FROM(
	SELECT r.name r_name,SUM(o.total_amt_usd) total_sales, COUNT(*) count_order
	FROM sales_reps s
	JOIN region r
	ON r.id = s.region_id
	JOIN accounts a
	ON a.sales_rep_id = s.id
	JOIN orders o
	ON o.account_id=a.id
	GROUP BY 1)tb1
);





--     3. How many accounts had more total purchases than the account name which has 
-- 		bought the most standard_qty paper throughout their lifetime as a customer?
SELECT COUNT(*)
FROM(SELECT name
FROM(SELECT a.name,SUM(o.total),SUM(o.standard_qty) std_qty
FROM accounts a
JOIN orders o
ON o.account_id=a.id
GROUP BY 1
HAVING SUM(o.total) > (
	SELECT MAX(total)
	FROM(
		SELECT a.name,SUM(o.total) total,SUM(o.standard_qty) std_qty
		FROM accounts a
		JOIN orders o
		ON o.account_id=a.id
		GROUP BY 1
		ORDER BY std_qty DESC
		LIMIT 1
		)tb1
		))tb2)tb3;
		



-- 		BY USING WITH Common Table EXPRESSION
WITH cte AS(
			SELECT a.name,SUM(o.total) total,SUM(o.standard_qty) std_qty
		FROM accounts a
		JOIN orders o
		ON o.account_id=a.id
		GROUP BY 1
		ORDER BY std_qty DESC
		LIMIT 1
)
SELECT COUNT(*)
FROM(SELECT name
FROM(SELECT a.name,SUM(o.total),SUM(o.standard_qty) std_qty
FROM accounts a
JOIN orders o
ON o.account_id=a.id
GROUP BY 1
HAVING SUM(o.total) > (
	SELECT MAX(total)
	FROM cte
	))tb2)tb3;
		




--     4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, 
-- 		how many web_events did they have for each channel?

-- First Calculate Maximum SUM ammount
SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY 3 DESC
LIMIT 1;

SELECT a.id,a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id = (
SELECT id FROM(
SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY 3 DESC
LIMIT 1
)tb1)
GROUP BY 1,2,3;



-- BY USING WITH
WITH cte1 AS(SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY 3 DESC
LIMIT 1
)

SELECT a.id,a.name, w.channel, COUNT(*)
	FROM accounts a
	JOIN web_events w
	ON a.id = w.account_id AND a.id = 
		(SELECT id FROM cte1
		)
	GROUP BY 1,2,3;





--     5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
SELECT AVG(total_spent)
FROM(SELECT a.id,a.name,SUM(o.total_amt_usd) total_spent,AVG(o.total_amt_usd)
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10)tb1;







--     6. What is the lifetime average amount spent in terms of total_amt_usd, 
-- 		including only the companies that spent more per order, on average, than the average of all orders.

SELECT AVG(avg_all)
FROM(
	SELECT o.account_id,AVG(o.total_amt_usd) avg_all
	FROM orders o
	GROUP BY 1
	HAVING AVG(o.total_amt_usd)>(
		SELECT AVG(o.total_amt_usd)
		FROM orders o
		)
	ORDER BY 2
)tb1;



-- WITH STATEMENT
-- by using with

WITH companies AS(
		SELECT o.account_id,AVG(o.total_amt_usd) avg_all
	FROM orders o
	GROUP BY 1
	HAVING AVG(o.total_amt_usd)>(
		SELECT AVG(o.total_amt_usd)
		FROM orders o
		)
	ORDER BY 2
)
SELECT AVG(avg_all)
FROM companies
;


-- WITH CTE Practice
WITH event_count AS(
		SELECT channel,DATE_TRUNC('day',occurred_at) day_tr,COUNT(*)
		FROM web_events w
		GROUP BY 1,2)

SELECT channel,AVG(count)
FROM event_count
GROUP BY 1;




WITH table1 AS (
          SELECT *
          FROM web_events),

     table2 AS (
          SELECT *
          FROM accounts)


SELECT *
FROM table1
JOIN table2
ON table1.account_id = table2.id;



WITH tb1 AS(
		SELECT id,name
		FROM accounts),
	tb2 AS(
		SELECT id,account_id,total
		FROM orders)
SELECT *
FROM tb1 
JOIN tb2
ON tb1.id = tb2.account_id;




-- WITH QUIZ




--     1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

-- This will give total sales by each sales man
WITH tb1 AS(SELECT s.name s_name,r.name r_name,SUM(o.total_amt_usd) total_sales
		FROM sales_reps s
		JOIN region r
		ON r.id = s.region_id
		JOIN accounts a
		ON a.sales_rep_id = s.id
		JOIN orders o
		ON o.account_id=a.id
		GROUP BY 1,2),
	tb2 AS(
		SELECT r_name,MAX(total_sales) maximum
		FROM tb1
		GROUP BY 1)

SELECT s_name,tb2.r_name,maximum
	FROM tb1
	JOIN tb2
	ON tb2.r_name=tb1.r_name AND tb2.maximum=tb1.total_sales ;


-- Use above quiz solution to solve this like Q-1
-- 2-For the region with the largest sales total_amt_usd, how many total orders were placed?

-- 3-How many accounts had more total purchases than the account name which has bought the most standard_qty 
    -- paper throughout their lifetime as a customer?

-- 4-For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many 
    -- web_events did they have for each channel?

-- 5-What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?

-- 6-What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more 
    -- per order, on average, than the average of all orders.