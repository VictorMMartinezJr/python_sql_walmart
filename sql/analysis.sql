-- 1. Find different payment methods, # of transactions, and # of qty sold
SELECT 
	payment_method,
	COUNT(*) AS num_of_transactions,
	SUM(quantity) AS qty_sold
FROM walmart
GROUP BY payment_method;

-- 2. Identify the highest rated category in each branch. Display the branch, category, AVG rating
SELECT branch, category, avg_rating
FROM (
	SELECT
		branch,
		category,
		AVG(rating) AS avg_rating,
		DENSE_RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank 
	FROM walmart
	GROUP BY 1, 2
)
WHERE rank = 1;

-- 3. Identify the busiest day for each branch based on the # of transactions
SELECT *
FROM (
	SELECT 
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_of_week,
		COUNT(*) AS num_of_transactions,
		DENSE_RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
	FROM walmart
	GROUP BY 1, 2
	)
WHERE rank = 1;

-- 4. Determine the avg, min, and max rating of products for each city.
SELECT 
	city, 
	AVG(rating) AS avg_rating,
	MIN(rating) AS min_rating,
	MAX(rating) AS max_rating
FROM walmart
GROUP BY city
ORDER BY city;

-- 5. Calculate the total profit for each category by considering total profit (price * qty * profit margin).
-- Display the category and the total profit ordered from highest to lowest.
SELECT 
	category,
	SUM(total_price) AS total_revenue,
	SUM(total_price * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- 6. Determine the most common payment method for each Branch. 
SELECT branch, payment_method AS most_common_payment_method
FROM (
	SELECT 
		branch,
		payment_method,
		COUNT(*) as total_transations,
		DENSE_RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
	FROM walmart
	GROUP BY branch, 2
	)
WHERE rank = 1;

-- 7. Categorize sales into 3 groups (MORNING, AFTERNOON EVENING). Find # of invoices for each shift
SELECT branch, 
	CASE
		WHEN EXTRACT(HOUR FROM time::time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM time::time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS shift,
	COUNT(*) as num_of_invoices
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

-- 8. Identify the 5 branches with the highest descreasing ratio in revenue compared from 2022 to 2023
SELECT * FROM walmart;

WITH revenue_2022 
AS (
	SELECT 
		branch,
		SUM(total_price) as total_revenue_2022
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
	GROUP BY branch	
	),
revenue_2023 
AS (
	SELECT 
		branch,
		SUM(total_price) as total_revenue_2023
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY branch	
)
SELECT
	cys.branch, 
	total_revenue_2022,
	total_revenue_2023,
	ROUND((total_revenue_2022 - total_revenue_2023)::numeric / total_revenue_2022::numeric * 100, 2) AS declining_ratio
FROM revenue_2022 lys
JOIN revenue_2023 cys ON cys.branch = lys.branch
ORDER BY declining_ratio DESC
LIMIT 5;