
-- Creating a Running Total Using Window Functions
SELECT standard_amt_usd, DATE_TRUNC('year',occurred_at),
SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('year',occurred_at) ORDER BY occurred_at) as running_total
FROM orders;

SELECT id,
		account_id,
		occurred_at,
		ROW_NUMBER() OVER (ORDER BY id) 
	FROM orders;
	
	
SELECT id,
		account_id,
		occurred_at,
		ROW_NUMBER() OVER (ORDER BY occurred_at) 
	FROM orders;
	
	
SELECT id,
		account_id,
		occurred_at,
		ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY occurred_at) 
	FROM orders;



-- 	There is litte difference between row_number and rank
--	IN Row_Number, if two or more rows have same values for order by clause,
-- 	Then row_number gives diffirent number to each row.
-- 	While in same situation rank gives same number to those rows. 
SELECT id,
		account_id,
		DATE_TRUNC('month',occurred_at) monthly,
		RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) 
	FROM orders;

-- 		And there is DENSE RANK , it does not skip values, as rank skips (i.e. 1 2 2 4 4) => 1 2 2 3 3

SELECT id,
		account_id,
		DATE_TRUNC('month',occurred_at) monthly,
		DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) 
	FROM orders;
	
	

-- Agregated Functions in Windows

SELECT id,
		account_id,
		standard_qty,
		DATE_TRUNC('month',occurred_at) monthly,
		DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)),
		SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)),
		COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)),
		AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)),		
		MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)),
		MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at))
	FROM orders;
	


-- Ranking Total Paper Ordered by Account
SELECT id,
		account_id,
		total,
		RANK() OVER(PARTITION BY account_id ORDER BY total DESC) as ranking
	FROM orders;



-- Aliasing for multiple windows functions

SELECT id,
		account_id,
		standard_qty,
		DATE_TRUNC('month',occurred_at) monthly,
		DENSE_RANK() OVER window_func,
		SUM(standard_qty) OVER window_func,
		COUNT(standard_qty) OVER window_func,
		AVG(standard_qty) OVER window_func,		
		MIN(standard_qty) OVER window_func,
		MAX(standard_qty) OVER window_func
	FROM orders
WINDOW window_func AS (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at));


SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER window_1 AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER window_1 AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER window_1 AS count_total_amt_usd,
       AVG(total_amt_usd) OVER window_1 AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER window_1 AS min_total_amt_usd,
       MAX(total_amt_usd) OVER window_1  AS max_total_amt_usd
FROM orders

WINDOW window_1 AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at));




-- LAG AND LEAD
WITH tb1 AS (SELECT account_id,SUM(standard_qty) as sum_std_qty
	FROM orders
	GROUP BY 1)
	
SELECT account_id,sum_std_qty,
		LAG(sum_std_qty) OVER (ORDER BY sum_std_qty),
		LEAD(sum_std_qty) OVER (ORDER BY sum_std_qty),
		sum_std_qty - LAG(sum_std_qty) OVER (ORDER BY sum_std_qty) as lag_diff, -- shows the differene between current row and prior row
		LEAD(sum_std_qty) OVER (ORDER BY sum_std_qty) - sum_std_qty as lead_diff -- shows the difference between current row and next row
	FROM tb1;
	
	

-- how the current order's total revenue ("total" meaning from sales of all types of paper) compares to the next order's total revenue.
WITH tb1 AS(SELECT account_id,sum(total_amt_usd) total
	FROM orders
	GROUP BY 1
)
SELECT account_id, total,
-- 	LAG(total) OVER (ORDER BY total) as lag,
-- 	LEAD(total) OVER (ORDER BY total) as lead,
	total - LAG(total) OVER (ORDER BY total) as lag_diff,
	LEAD(total) OVER (ORDER BY total) - total as lead_diff
	FROM tb1;
	
	
WITH tb1 AS(SELECT account_id,sum(standard_qty) total
	FROM orders
	GROUP BY 1
)
SELECT account_id, total,
	LAG(total) OVER (ORDER BY total) as lag,
	LEAD(total) OVER (ORDER BY total) as lead,
	total - LAG(total) OVER (ORDER BY total) as lag_diff,
	LEAD(total) OVER (ORDER BY total) - total as lead_diff
	FROM tb1;
	

-- Comparing a Row to a Previous Row
SELECT occurred_at,
       total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) AS lead,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) - total_amt_usd AS lead_difference
FROM (
SELECT occurred_at,
       SUM(total_amt_usd) AS total_amt_usd
  FROM orders 
 GROUP BY 1
) sub;



-- Percentile
--     1. Use the NTILE functionality to divide the accounts into 4 levels in terms of the amount of standard_qty for their orders. 
-- 		Your resulting table should have the account_id, the occurred_at time for each order, the total amount of standard_qty paper purchased,
-- 		and one of four levels in a standard_quartile column.
--     2. Use the NTILE functionality to divide the accounts into two levels in terms of the amount of gloss_qty for their orders. 
-- 		Your resulting table should have the account_id, the occurred_at time for each order, the total amount of gloss_qty paper purchased, 
-- 		and one of two levels in a gloss_half column.
--     3. Use the NTILE functionality to divide the orders for each account into 100 levels in terms of the amount of total_amt_usd for their orders. 
-- 		Your resulting table should have the account_id, the occurred_at time for each order, the total amount of total_amt_usd paper purchased, 
-- 		and one of 100 levels in a total_percentile column.
-- 1
SELECT account_id,occurred_at,standard_qty,
	NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) as std_quartile
	FROM orders
	ORDER BY 1 DESC;



-- 2
SELECT account_id,occurred_at,gloss_qty,
	NTILE(2) OVER (PARTITION BY account_id ORDER BY gloss_qty) as gloss_two
	FROM orders
	ORDER BY 1 DESC;



-- 3
SELECT account_id,occurred_at,total_amt_usd,
	NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) as percentile
	FROM orders
	ORDER BY 1 DESC;



	
	
	
	
	
	
	
	
	
	
	