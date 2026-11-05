--SELECT cst_id, COUNT(*) FROM (

SELECT 
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
FROM silver.crm_cust_info ci -- Putting an allias named ci

LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
--)t GROUP BY cst_id

--HAVING COUNT(*) > 1


SELECT DISTINCT
	
	ci.cst_gndr,
	
	ca.gen
	
FROM silver.crm_cust_info ci -- Putting an allias named ci

LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
ORDER BY 1,2


SELECT DISTINCT
	
	ci.cst_gndr,
	
	ca.gen,
	
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the Master Table for gender
		ELSE COALESCE(ca.gen, 'n/a')
	END AS new_gen

FROM silver.crm_cust_info ci -- Putting an allias named ci

LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
ORDER BY 1,2


SELECT DISTINCT gender FROM gold.dim_customers


SELECT prd_key, COUNT(*) FROM
(
SELECT
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pn.prd_end_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL --Filter out all teh historical data
)t
GROUP BY prd_key
HAVING COUNT(*) >1


SELECT
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS 'product key',
	pn.prd_id AS 'product id',
	pn.prd_key AS 'product number',
	pn.prd_nm AS 'product name',

	pn.cat_id AS 'category id',
	pc.cat AS 'category',
	pc.subcat AS 'subcategory',
	pc.maintenance,

	pn.prd_cost AS cost,
	pn.prd_line 'product line',
	pn.prd_start_dt AS 'start date'--,
	--pn.prd_end_dt
	
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL --Filter out all teh historical data

SELECT
	sd.sls_ord_num AS 'order number',
	pr.[product key],
	
	-- sd.sls_prd_key,

	cu.[customer key],
	-- sd.sls_cust_id,
	sd.sls_order_dt AS 'order date',
	sd.sls_ship_dt AS 'shipping date',
	sd.sls_due_dt AS 'due date',
	sd.sls_sales AS 'sales amount',
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.[product number]
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.[customer id]

SELECT * FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.[customer key] = f.[customer key]
LEFT JOIN gold.dim_products p
ON p.[product key] = f.[product key]
WHERE c.[customer key] IS NULL
