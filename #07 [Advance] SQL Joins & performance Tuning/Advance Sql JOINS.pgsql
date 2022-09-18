SELECT *
FROM accounts a
JOIN sales_reps s
ON s.id=a.sales_rep_id;



SELECT *
FROM accounts a
LEFT JOIN sales_reps s
ON s.id=a.sales_rep_id;




SELECT *
FROM accounts a
RIGHT JOIN sales_reps s
ON s.id=a.sales_rep_id;




SELECT *
FROM accounts a
FULL OUTER JOIN sales_reps s
ON s.id=a.sales_rep_id
WHERE a.sales_rep_id IS NULL OR s.id IS NULL;



-- we want to look at all of the web traffic events that occurred before that account's first order.
SELECT o.id,o.account_id,o.occurred_at as order_date,
	w.*
	FROM orders o
	LEFT JOIN web_events w
	ON w.account_id = o.account_id
	AND w.occurred_at < o.occurred_at
	WHERE DATE_TRUNC('month',o.occurred_at) = 
		(SELECT DATE_TRUNC('month',MIN(o.occurred_at))--,MIN(occurred_at)
FROM orders o)
ORDER BY 2,3;


-- write a query that left joins the accounts table and the sales_reps tables on each sale rep's ID number and joins it
-- using the < comparison operator on accounts.primary_poc and sales_reps.name, like so:
-- accounts.primary_poc < sales_reps.name
-- The query results should be a table with three columns:
-- the account name (e.g. Johnson Controls), the primary contact name (e.g. Cammy Sosnowski),
-- and the sales representative's name (e.g. Samuel Racine)

SELECT a.name as account_name,
		a.primary_poc as primary_cont,
		s.name as sales_rep_name
	FROM accounts a
	LEFT JOIN sales_reps s
	ON s.id = a.sales_rep_id
	AND a.primary_poc < s.name;
	
	


-- SELF JOIN
-- 1	1001	"2015-10-06 17:31:14"	4318	1001	"2016-11-25 23:19:37"
-- 1	1001	"2015-10-06 17:31:14"	14	1001	"2016-10-26 20:31:30"
-- 1	1001	"2015-10-06 17:31:14"	4316	1001	"2016-08-28 06:50:58"
-- 1	1001	"2015-10-06 17:31:14"	4315	1001	"2016-07-30 03:21:57"
-- 1	1001	"2015-10-06 17:31:14"	4314	1001	"2016-05-31 21:09:48"

SELECT o1.id as o1_id,
		o1.account_id as o1_acc_id,
		o1.occurred_at as o1_ord_date,
		o2.id as o2_id,
		o2.account_id as o2_acc_id,
		o2.occurred_at as o2_ord_date
	FROM orders o1
	LEFT JOIN orders o2
	ON o1.account_id = o2.account_id
	AND o2.occurred_at > o1.occurred_at
	AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY 2,3;




-- Modify the query from the previous video, which is pre-populated in the SQL Explorer below, to perform the same
-- interval analysis except for the web_events table. Also:
--     • change the interval to 1 day to find those web events that occurred after, but not more than 1 day after, another web event
--     • add a column for the channel variable in both instances of the table in your query


SELECT w1.id as w1_id,
		w1.account_id as w1_acc_id,
		w1.occurred_at as w1_ord_date,
		w1.channel as w1_channel,
		w2.id as w2_id,
		w2.account_id as w2_acc_id,
		w2.occurred_at as w2_ord_date,
		w2.channel as w2_channel
	FROM web_events w1
	LEFT JOIN web_events w2
	ON w1.account_id = w2.account_id
	AND w1.occurred_at > w2.occurred_at
	AND w1.occurred_at <= w2.occurred_at + INTERVAL '1 day';
		


-- 		SELECT w1.id as w1_id,
-- 		w1.account_id as w1_acc_id,
-- 		w1.occurred_at as w1_ord_date,
-- 		w1.channel as w1_channel,
-- 		w2.id as w2_id,
-- 		w2.account_id as w2_acc_id,
-- 		w2.occurred_at as w2_ord_date,
-- 		w2.channel as w2_channel
-- 	FROM web_events w1
-- 	LEFT JOIN web_events w2
-- 	ON w1.account_id = w2.account_id
-- 	AND w2.occurred_at > w1.occurred_at
-- 	AND w2.occurred_at <= w1.occurred_at + INTERVAL '1 day'
-- ORDER BY 3,7



-- UNION OPERATOR
-- UNION
SELECT *
	FROM accounts a1

UNION 

SELECT *
	FROM accounts a2;

-- UNION ALL
SELECT *
	FROM accounts a1

UNION ALL

SELECT *
	FROM accounts a2;




-- UNION
SELECT *
	FROM accounts a1
	WHERE name = 'Walmart'

UNION 

SELECT *
	FROM accounts a2
	WHERE name='Disney';



-- UNION ALL
SELECT *
	FROM accounts a1
	WHERE name = 'Walmart'

UNION ALL

SELECT *
	FROM accounts a2
	WHERE name='Disney';



-- How else could the above query results be generated? WITH AND or with OR
SELECT *
	FROM accounts 
	WHERE name='Walmart' OR name='Disney';
-- So Ans is With OR



-- Performing Operations on a Combined Dataset

WITH double_accounts AS(
	SELECT *
	FROM accounts a1
	UNION ALL
	SELECT *
	FROM accounts a2
)
SELECT name,COUNT(*)
	FROM double_accounts
	GROUP BY 1 
	ORDER BY 2 DESC;
	



-- 	Big Data
-- Filtering the Data to to speed up query
-- for example in time series data, limiting your query to a samller window boost up query speed
SELECT *
FROM orders;
-- above query take 00.231 seconds to execute on my machine


SELECT *
	FROM orders 
	WHERE occurred_at >='2016-01-04'
		AND occurred_at<'2016-07-04';	

-- above query take 00.125 seconds 
-- So time reduces from 0.231s to 0.125s
-- SO best practice is to check perform exploratory analysis on subset of data
-- refine your query into final query
-- remove all limitations and run query across the data set
-- in this way final query takes long time but intermediate (subset) quries takes less time
-- so overall performance increases

-- One thing to remember limit does not work on aggregation clauses
-- because aggregation perform before limit
-- only way to apply limit across aggregations is 
-- this that limit your rows in sub query and apply
-- aggregations outer query



SELECT SUM(poster_qty) as poster_qty_sum
	FROM orders 
	WHERE occurred_at >='2016-01-04'
		AND occurred_at<'2016-07-04';
-- Sum is 132002 

SELECT SUM(poster_qty) as poster_qty_sum
	FROM orders 
	WHERE occurred_at >='2016-01-04'
		AND occurred_at<'2016-07-04'
	LIMIT 10;
-- 	Here sum is also same


SELECT account_id,SUM(poster_qty) as poster_qty_sum
	FROM orders 
	WHERE occurred_at >='2016-01-04'
		AND occurred_at<'2016-07-04'
	GROUP BY 1;

SELECT account_id,SUM(poster_qty) as poster_qty_sum
	FROM orders 
	WHERE occurred_at >='2016-01-04'
		AND occurred_at<'2016-07-04'
	GROUP BY 1	
	LIMIT 10;
	

-- 	As you can see sum for both above query is same,
-- 2nd query actaully limiting results table to show 10 rows

WITH tb1 AS (SELECT * 
			 FROM orders
				LIMIT 100)

SELECT account_id,SUM(poster_qty) as poster_qty_sum
	FROM tb1
	WHERE occurred_at >='2016-01-04'
		AND occurred_at<'2016-07-04'
	GROUP BY 1	
	LIMIT 10;
	
-- in this way rows can be limited
-- though this will not give actuall results, but it's good to check query logic through this


-- 2nd step in this to make joins less complicated

SELECT a.name, COUNT(*) WEB_EVENTS
	FROM accounts a
	JOIN web_events w
	ON w.account_id=a.id
	GROUP BY 1
	ORDER BY 2 DESC;
	
	
-- 	So previous logic reduce data at a point that is executed early
-- mean it is better to reduce data before joining
-- 9073 rows from web_events compared to 6912 rows of orders
--  but if we can pre aggregated web_events, it can speed up query
-- Although this is small data, but same logic for large data

SELECT account_id, COUNT(*)
	FROM web_events 
	GROUP BY 1;
-- 	returns 351 accounts


WITH tb1 AS(SELECT account_id, COUNT(*) as web_event
	FROM web_events 
	GROUP BY 1)
SELECT a.name, tb1.web_event
	FROM accounts a
	JOIN tb1
	ON tb1.account_id = a.id
	ORDER BY 2 DESC;
	
	
	
EXPLAIN
SELECT a.name, COUNT(*) WEB_EVENTS
	FROM accounts a
	JOIN web_events w
	ON w.account_id=a.id
	GROUP BY 1
	ORDER BY 2 DESC