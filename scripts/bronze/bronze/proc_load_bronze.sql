/*
==========================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
==========================================================================================
Purpose:
	This stored procedure loads data into the 'bronze' schema from external CSV files.
	It performs the following actions:
	-	Truncates the bronze tables before loading data.
	-	Uses the 'BULK INSERT' command to load data from csv Files to bronze tables.

Parameters:
	None.
	This stored procedure does not accept any parameters or return any values.
Usage Example:
	EXEC bronze.load_bronze;
==========================================================================================

*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
BEGIN TRY

	SET @batch_start_time = GETDATE();

	PRINT '====================================';
	PRINT 'Loading the Bronze Layer';
	PRINT '====================================';

	PRINT '------------------------------------';
	PRINT 'Loading CRM Tables';
	PRINT '------------------------------------';

	SET @start_time = GETDATE();
	PRINT '>> Truncating Table: bronze.crm_cust_info';
	TRUNCATE TABLE bronze.crm_cust_info; -- This step is necessary to empty the table 
	
	PRINT '>>Insearting Data Into: bronze.crm_cust_info';
	BULK INSERT bronze.crm_cust_info
	FROM 'C:\Program Files\MySQL\SQL_Data_Warehouse\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	); -- The first row in the original csv file contains the headings i.e., the column names. That is why that particular row was not selected.

	/* SELECT COUNT(*) FROM bronze.crm_cust_info*/ -- This one is just there for quick checking
	SET @end_time = GETDATE();

	PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------';


	SET @start_time = GETDATE();
	PRINT '>> Truncating Table: bronze.crm_prd_info';
	TRUNCATE TABLE bronze.crm_prd_info; -- This step is necessary to empty the table 
	
	PRINT '>>Insearting Data Into: bronze.crm_prd_info';
	BULK INSERT bronze.crm_prd_info
	FROM 'C:\Program Files\MySQL\SQL_Data_Warehouse\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	); -- The first row in the original csv file contains the headings i.e., the column names. That is why that particular row was not selected.

	SET @end_time = GETDATE();
	PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------';


	SET @start_time = GETDATE();
	PRINT '>> Truncating Table: bronze.crm_sales_details';
	TRUNCATE TABLE bronze.crm_sales_details; -- This step is necessary to empty the table 
	
	PRINT '>>Insearting Data Into: bronze.crm_sales_details';
	BULK INSERT bronze.crm_sales_details
	FROM 'C:\Program Files\MySQL\SQL_Data_Warehouse\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	); -- The first row in the original csv file contains the headings i.e., the column names. That is why that particular row was not selected.
	
	SET @end_time = GETDATE();
	PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------';



	PRINT '------------------------------------';
	PRINT 'Loading ERP Tables';
	PRINT '------------------------------------';


	SET @start_time = GETDATE();

	PRINT '>> Truncating Table: bronze.erp_cust_az12';
	TRUNCATE TABLE bronze.erp_cust_az12; -- This step is necessary to empty the table 
	
	PRINT '>>Insearting Data Into: bronze.erp_cust_az12';
	BULK INSERT bronze.erp_cust_az12
	FROM 'C:\Program Files\MySQL\SQL_Data_Warehouse\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	); -- The first row in the original csv file contains the headings i.e., the column names. That is why that particular row was not selected.
	SET @end_time = GETDATE();
	PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------';



	SET @start_time = GETDATE();

	PRINT '>> Truncating Table: bronze.erp_loc_a101';
	TRUNCATE TABLE bronze.erp_loc_a101; -- This step is necessary to empty the table 
	
	PRINT '>>Insearting Data Into: bronze.erp_loc_a101';
	BULK INSERT bronze.erp_loc_a101
	FROM 'C:\Program Files\MySQL\SQL_Data_Warehouse\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	); -- The first row in the original csv file contains the headings i.e., the column names. That is why that particular row was not selected.
	SET @end_time = GETDATE();
	PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------';



	SET @start_time = GETDATE();

	PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
	TRUNCATE TABLE bronze.erp_px_cat_g1v2; -- This step is necessary to empty the table 
	
	PRINT '>>Insearting Data Into: bronze.erp_px_cat_g1v2';
	BULK INSERT bronze.erp_px_cat_g1v2
	FROM 'C:\Program Files\MySQL\SQL_Data_Warehouse\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	); -- The first row in the original csv file contains the headings i.e., the column names. That is why that particular row was not selected.
	SET @end_time = GETDATE();
	PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '-----------------';
	
	SET @batch_end_time = GETDATE();
	PRINT 'Loading bronze layer is completed';
	PRINT ' ----  Total Load Duration:  ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';


	END TRY
	BEGIN CATCH
		PRINT '========================================================';
		PRINT 'Error occured during loading bronze layer';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '========================================================';
	END CATCH
END
