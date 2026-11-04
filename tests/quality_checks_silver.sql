/*
-- Check for NULLs or Duplicates in teh Primary Key
-- Expectation: No results


SELECT 
	cst_id,
	COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL -- It is a quality check to find out repeted values & NULLs

*/

-- Check for unwanted spaces
-- Expectation: NO results

SELECT cst_firstname FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
----- 
SELECT cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key) OR cst_key IS NULL

--- Date Standardisation & Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT *
FROM silver.crm_cust_info
WHERE cst_id IS NULL;

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info

-- Check for NULLS or duplicates in primary key
-- Expectation: No results
SELECT
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Checking the category id in that cat_g1v2 table for future joining
SELECT DISTINCT ID FROM bronze.erp_px_cat_g1v2



SELECT sls_prd_key FROM bronze.crm_sales_details

--Check for unwanted spaces
-- Expectation: No results

SELECT prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

--CHeck for NULLs or Negative Numbers
-- Expectation: No results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost <= 0 OR prd_cost IS NULL


-- Data Standardisation & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

--Check for invalid date orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

SELECT
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cst,
	
	CASE	WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
			WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
			WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
			WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
			ELSE 'N/A'
	END AS prd_line,
	prd_start_dt,
	--prd_end_dt,
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')

-- Check for invalid dates

SELECT
--sls_order_dt
NULLIF(sls_order_dt,0) sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0 
	OR LEN(sls_order_dt) != 8 
	OR sls_order_dt > 20500101 
	OR sls_order_dt < 19000101

SELECT
--sls_order_dt
NULLIF(sls_ship_dt,0) sls_order_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt <= 0 
	OR LEN(sls_ship_dt) != 8 
	OR sls_ship_dt > 20500101 
	OR sls_ship_dt < 19000101

-- Check for invalid order date
SELECT
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

SELECT DISTINCT
	sls_sales AS old_sls_sales,
	sls_quantity,
	sls_price AS old_sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
		OR sls_sales IS NULL OR sls_sales <= 0
		OR sls_quantity IS NULL OR sls_quantity <= 0
		OR sls_price IS NULL OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price



SELECT DISTINCT
	sls_sales AS old_sls_sales,
	sls_quantity,
	sls_price AS old_sls_price,
-- sls_sales AS old_sales,
	CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,

	sls_quantity,

	-- sls_price AS old_price,

	CASE WHEN sls_price IS NULL OR sls_price <= 0 OR sls_price != sls_sales / NULLIF(sls_quantity, 0)
			THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
	END AS sls_price

FROM silver.crm_sales_details


-- Identify Out of Range Dates

SELECT DISTINCT
	bdate
	FROM silver.erp_cust_az12
	WHERE bdate /*< '1920-01-01' OR bdate*/ > GETDATE()

-- Data Standardisation & Consistency
SELECT DISTINCT gen,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
			WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'	
			ELSE 'n/a'
	END AS gen
FROM silver.erp_cust_az12


SELECT
	
	REPLACE(cid, '-', '') cid,
	cntry,

	CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
		WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		ELSE TRIM(cntry)
	END AS cntry

FROM silver.erp_loc_a101 WHERE REPLACE(cid, '-', '') NOT IN
(SELECT cst_key FROM silver.crm_cust_info)


--- DATA standerdisation & Consistancy
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry

SELECT
id,
cat,
subcat,
maintenance

FROM silver.erp_px_cat_g1v2

-- Check for unwanted spaces
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data Standardisation & Consistency
SELECT DISTINCT

maintenance
FROM silver.erp_px_cat_g1v2
