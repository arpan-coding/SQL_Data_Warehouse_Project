--SELECT cst_id, COUNT(*) FROM (


CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY cst_id) AS 'customer key',
	ci.cst_id AS 'customer id',
	ci.cst_key AS 'customer numebr',
	ci.cst_firstname AS 'first name',
	ci.cst_lastname AS 'last name',
	la.cntry AS country,
	ci.cst_marital_status AS 'marital status',
	-- ci.cst_gndr,
	
	
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the Master Table for gender
		ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,

	ca.bdate AS 'birth date',
	-- ca.gen,
	ci.cst_create_date
FROM silver.crm_cust_info ci -- Putting an allias named ci

LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
--)t GROUP BY cst_id

--HAVING COUNT(*) > 1


CREATE VIEW gold.dim_products AS
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


CREATE VIEW gold.fact_sales AS

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
