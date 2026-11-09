/*
======================================================
Customer Report
======================================================
Purpose:
		- This report consolidates key customer metrices and behaviours

Highlights:
	1. Gatheres essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups
	3. Aggregates customer-level metrices:
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- average monthly spend

======================================================
*/
CREATE OR ALTER VIEW gold.report_customers AS

WITH base_query AS (
/*
------------------------------------------------------
1. Base Query: Retrieves core columns from tables
------------------------------------------------------
*/
SELECT
f.[order number],
f.[product key],
f.[order date],
f.[sales amount],
f.quantity,
c.[customer key],
c.[customer number],
--c.[first name],
--c.[last name],

CONCAT(c.[first name], ' ', c.[last name]) AS 'customer name',

-- c.[birth date]

DATEDIFF(year, c.[birth date], GETDATE()) age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.[customer key] = f.[customer key]
WHERE [order date] IS NOT NULL
)
,
customer_aggregation AS
(
/*------------------------------------------------------
2. Customer Aggregations: Summarises key metrices at the customer level
-------------------------------------------------------*/
SELECT
	[customer key],
	[customer number],
	[customer name],
	age,
	COUNT(DISTINCT [order number]) AS 'total orders',
	SUM([sales amount]) AS 'total sales',
	SUM(quantity) AS 'total quantity',
	COUNT(DISTINCT [product key]) AS 'total products',
	MAX([order date]) AS 'last order date',
	DATEDIFF (month, MIN([order date]), MAX([order date])) AS lifespan

FROM base_query

GROUP BY
    [customer key],
    [customer number],
    [customer name],
    age
	)
SELECT
	[customer key],
	[customer number],
	[customer name],
	age,
	
	CASE
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20 - 29'
		WHEN age BETWEEn 30 AND 39 THEN '30 - 39'
		WHEN age BETWEEN 40 AND 49 THEN '40 - 49'
		WHEN age BETWEEN 50 AND 59 THEN '50 - 59'
		WHEN age BETWEEN 60 AND 69 THEN '60 - 69'
		ELSE '70 and above'
	END 'age group',
	
	[total orders],
	[total sales],
	[total quantity],
	[total products],
	-- [last order date],
	
	CASE
		WHEN lifespan >= 12 AND [total sales] > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND [total sales] <= 5000 THEN 'Regular'
		ELSE 'New'
	END 'customer segment',
	[last order date],
	DATEDIFF(month, [last order date], GETDATE()) AS recency,
	-- Computing the avg order value (AVO)
	[total sales]/[total orders] AS avo,

	-- Computing the avg monthly spending (AMS)
	CASE 
		WHEN lifespan = 0 THEN [total sales]
		ELSE [total sales]/lifespan
	END AS ams
	FROM customer_aggregation
