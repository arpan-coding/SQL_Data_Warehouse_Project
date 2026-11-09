-- Change over time (trends)
-- This query is for daily sales
SELECT
[order date],
SUM([sales amount]) AS 'total sales'
FROM gold.fact_sales
WHERE [order date] IS NOT NULL
GROUP BY [order date]
ORDER BY [order date]


-- This one is for year level sales

SELECT
YEAR([order date]) AS 'order year', -- This year function will convert the date into year
COUNT(DISTINCT [customer key]) AS 'total customers',
SUM([sales amount]) AS 'total sales',
SUM(quantity) AS 'total quantity'
FROM gold.fact_sales
WHERE [order date] IS NOT NULL
GROUP BY YEAR([order date])
ORDER BY [order year]


-- This one is for month level sales

SELECT
MONTH([order date]) AS 'order month', -- This year function will convert the date into year
COUNT(DISTINCT [customer key]) AS 'total customers',
SUM([sales amount]) AS 'total sales',
SUM(quantity) AS 'total quantity'
FROM gold.fact_sales
WHERE [order date] IS NOT NULL
GROUP BY MONTH([order date])
ORDER BY [order month]


-- This one is for year and month both

SELECT
YEAR([order date]) AS 'order year', -- This year function will convert the date into year
MONTH([order date]) AS 'order month',

SUM([sales amount]) AS 'total sales',
COUNT(DISTINCT [customer key]) AS 'total customers',
SUM(quantity) AS 'total quantity'
FROM gold.fact_sales
WHERE [order date] IS NOT NULL
GROUP BY YEAR([order date]), MONTH([order date])
ORDER BY [order year], [order month]

-- This one is for customised format

SELECT
FORMAT([order date], 'yyyy-MMM') AS 'order date', -- This will sort the data according to the year
-- MONTH([order date]) AS 'order month',

SUM([sales amount]) AS 'total sales',
COUNT(DISTINCT [customer key]) AS 'total customers',
SUM(quantity) AS 'total quantity'
FROM gold.fact_sales
WHERE [order date] IS NOT NULL
GROUP BY FORMAT([order date], 'yyyy-MMM')
ORDER BY FORMAT([order date], 'yyyy-MMM')


-- Cumulative Analysis
-- Calculating the total sales per month and teh running total of sales over time
SELECT
[order date],
[total sales],
 -- Window Function
SUM([total sales]) OVER(ORDER BY [order date]) AS 'running total sales'
FROM
(
SELECT
DATETRUNC(month, [order date]) AS 'order date',
SUM([sales amount]) AS 'total sales'
-- [order date],
-- [sales amount]
FROM gold.fact_sales
WHERE [order date] IS NOT NULL -- To omit the null values
GROUP BY DATETRUNC(month, [order date])
-- ORDER BY DATETRUNC(month, [order date])
)t


-- Running total each year and the moving average
SELECT
[order date],
[total sales],
 -- Window Function
SUM([total sales]) OVER(PARTITION BY [order date] ORDER BY [order date]) AS 'running total sales per year',
SUM([avg price]) OVER(PARTITION BY [order date] ORDER BY [order date]) AS 'moving average price'


FROM
(
SELECT
DATETRUNC(year, [order date]) AS 'order date',
SUM([sales amount]) AS 'total sales',
AVG(price) AS 'avg price'
-- [order date],
-- [sales amount]
FROM gold.fact_sales
WHERE [order date] IS NOT NULL -- To omit the null values
GROUP BY DATETRUNC(year, [order date])
-- ORDER BY DATETRUNC(month, [order date])
)t



-- Performance Analysis
-- Analyse the yearly performance of products by comparing each product's
-- sales to both its average sales performance and the previous year's sales


WITH [yearly product sales] AS
(
SELECT
YEAR(f.[order date]) AS 'order year',
p.[product name],
SUM(f.[sales amount]) AS 'current sales'
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.[product key] = p.[product key]
WHERE f.[order date] IS NOT NULL
GROUP BY YEAR(f.[order date]), p.[product name]
)

SELECT
[order year],
[product name],
[current sales],
AVG([current sales]) OVER (PARTITION BY [product name]) AS 'avg sales',
[current sales] - AVG([current sales]) OVER (PARTITION BY [product name]) AS 'diff in avg',
CASE  -- This portion of the code is used to put a flag column regarding the performance
	WHEN [current sales] - AVG([current sales]) OVER (PARTITION BY [product name]) > 0 THEN 'Above avg'
	WHEN [current sales] - AVG([current sales]) OVER (PARTITION BY [product name]) < 0 THEN 'Below avg'
	ELSE 'Avg'
END 'avg change',

-- the next line of code will do the comparison between the current sales and the previous year sales
-- Year-over-year Analysis

LAG([current sales]) OVER (PARTITION BY [product name] ORDER BY [order year]) 'py sales',
[current sales] - LAG([current sales]) OVER (PARTITION BY [product name] ORDER BY [order year]) AS ' diff in py sales',

CASE  -- This portion of the code is used to put a flag column regarding the performance
	WHEN [current sales] - LAG([current sales]) OVER (PARTITION BY [product name] ORDER BY [order year]) > 0 THEN 'Increasing'
	WHEN [current sales] - LAG([current sales]) OVER (PARTITION BY [product name] ORDER BY [order year]) < 0 THEN 'Decreasing'
	ELSE 'Unchanged'
END 'py sale comment'


FROM [yearly product sales]
ORDER BY [product name], [order year]


-- Which categories contribute the most to overall sales

WITH [category sales] AS
(
SELECT
	category,
	SUM([sales amount]) 'total sales'
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.[product key] = f. [product key]
GROUP BY category
)
SELECT
	category,
	[total sales],
	SUM([total sales]) OVER() 'overall sales',

	ROUND((CAST ([total sales] AS FLOAT) / SUM([total sales]) OVER ()) * 100, 3) AS '% of total' -- That casting is very important to get correct results. It will then give 0 otherwise

FROM [category sales]
ORDER BY [total sales] DESC

--- Data Segmentation
-- Group the data based on a specific range. (Segment products into cost ranges)
-- Helps understand the correlation between two measures. (Count how many products fall into each segment)

WITH [product segments] AS
(
SELECT
	[product key],
	[product name],
	cost,

	CASE 
		WHEN cost < 100 THEN 'Below 100'
		WHEN cost BETWEEN 100 AND 500 THEN '100 - 500'
		WHEN cost BETWEEN 500 AND 1000 THEN '500 - 1000'
		WHEN cost BETWEEN 1000 AND 1500 THEN '1000 - 1500'
		WHEN cost BETWEEN 1500 AND 2000 THEN '1500 - 2000'
		ELSE 'Above 2000'
	END 'cost range'

FROM gold.dim_products
)

SELECT
[cost range],
COUNT([product key]) AS 'total products'
FROM [product segments] 
GROUP BY [cost range]
ORDER BY [total products] DESC


-- Group customers into three segments based on their spending behaviour.
--VIP: at least 12 months of history and spending more than 5000.
--Regular: at least 12 months of history but spending 5000 or less
--New: lifespan is less than 12 months
-- Total number of customers by each group

WITH [customer spending] AS
(
SELECT
	c.[customer key],
	-- f.[sales amount],
	-- f.[order date],
	SUM(f.[sales amount]) AS 'total spending',
	MIN([order date]) AS 'first order',
	MAX([order date]) AS 'last order',
	DATEDIFF (month, MIN([order date]), MAX([order date])) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.[customer key] = c.[customer key]
-- ORDER BY c.[customer key]
GROUP BY c.[customer key]
)

SELECT
[customer segment],
COUNT([customer key]) AS 'total customers'
FROM

(

SELECT
[customer key],
[total spending],
lifespan,

CASE
	WHEN lifespan >= 12 AND [total spending] > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND [total spending] <= 5000 THEN 'Regular'
	--WHEN lifespan < 12 THEN 'New'
	ELSE 'New'
END 'customer segment'
FROM [customer spending]
-- ORDER BY [customer segment] DESC
)t 
GROUP BY [customer segment]
ORDER BY [total customers] DESC




