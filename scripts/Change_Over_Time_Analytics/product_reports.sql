/*
======================================================
Product Report
======================================================
Purpose:
		- This report consolidates key product metrices and behaviours

Highlights:
	1. Gatheres essential fields such as product names, categories, subcategories, and cost
	2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers
	3. Aggregates customer-level metrices:
		- total orders
		- total sales
		- total quantity sold
		- total customers (unique)
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order revenue (AOR)
		- average monthly spend

======================================================
*/
CREATE OR ALTER VIEW gold.report_products AS

WITH base_query AS (
/*
------------------------------------------------------
1. Base Query: Retrieves core columns from tables
------------------------------------------------------
*/
SELECT
f.[order number],
f.[order date],
f.[customer key],
f.[sales amount],
f.quantity,
p.[product key],
p.[product name],
p.category,
p.subcategory,
p.cost


FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
	ON f.[product key] = p.[product key]
WHERE [order date] IS NOT NULL
)
,
product_aggregation AS
(
/*------------------------------------------------------
2. Customer Aggregations: Summarises key metrices at the product level
-------------------------------------------------------*/
SELECT
	[product key],
	[product name],
	category,
	subcategory,
	cost,
	DATEDIFF(MONTH, MIN([order date]), MAX([order date])) AS lifespan,
	
	MAX([order date]) AS 'last sale date',
	
	COUNT(DISTINCT [order number]) AS 'total orders',
	COUNT(DISTINCT [customer key]) AS 'total customers',
	SUM([sales amount]) AS 'total sales',
	SUM(quantity) AS 'total quantity',
	
	ROUND(AVG(CAST([sales amount] AS FLOAT) / NULLIF(quantity, 0)), 1) AS 'avg selling price'

FROM base_query

GROUP BY
    [product key],
    [product name],
	category,
	subcategory,
	cost
 	)
/*-------------------------------------------------------------
3. Final Query: Combining all product results into one output
--------------------------------------------------------------*/
SELECT
	[product key],
	[product name],
	category,
	subcategory,
	cost,
	[last sale date],
	DATEDIFF(month, [last sale date], GETDATE()) AS 'recency in months',
	CASE
		WHEN [total sales] > 50000 THEN 'High-Performer'
		WHEN [total sales] >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END 'product segment',
	lifespan,
	[total orders],
	[total sales],
	[total quantity],
	[total customers],
	[avg selling price],
	

	---- Average order revenue (AOR)

	CASE
		WHEN [total orders] = 0 THEN 0
		ELSE [total sales]/ [total orders]
	END aor,

	---- Average Monthly Revenue (AMR)
	
	CASE 
		WHEN lifespan = 0 THEN [total sales]
		ELSE [total sales]/lifespan
	END AS amr
	FROM product_aggregation
