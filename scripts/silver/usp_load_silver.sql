/*
============================================================================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
============================================================================================================================================
Description:
	This stored procedure performs the ETL (Extract, Transform, Load) process to facilitate the transition from the 'bronze' raw layer to 
	the 'silver' cleansed layer within the Medallion Architecture.

	Actions performed:
  - Truncates the silver tables: to avoid duplicating the same data
	- Data Cleansing: Trimming whitespace and handling NULLs.
	- Data Standardisation: Mapping cryptic codes to readable descriptions.
	- Data Integrity: Recalculating sales and price for accuracy. 
	- Data Deuplication: Keeping only the most recent records.
	- Metadata Injection: Adding lineage through the 'dwh_source_key'.

Parameters:
  None.
  This stored procedure does not accept any parameters or returns any values

Usage example:
	EXEC silver.load_silver;
============================================================================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN 
	-- Variable declaration for performing auditing
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
		PRINT 'Loading the Silver Layer';
		PRINT '================================================';

		-- ====================================================
		-- CRM Tables
		--=====================================================
		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		-- 1. Load silver.crm_cust_info
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;

		PRINT '>> Inserting Data Into: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date,
			dwh_source_key
		)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			-- Mapping marital status codes to full description
			CASE 
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				ELSE 'Unknown' 
			END AS cst_marital_status, 
			-- Mapping gender codes to full description
			CASE 
				WHEN UPPER (TRIM(cst_gndr)) = 'F' THEN 'Female'
				WHEN UPPER (TRIM(cst_gndr)) = 'M' THEN 'Male'
				ELSE 'Unknown'
			END AS cst_gndr, 
			cst_create_date,
			'CRM' AS dwh_source_key -- Explicit lineage 
		FROM (
			-- Identifying the most recent record for each customer to remove duplicates 
			SELECT *,
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) AS t 
		WHERE flag_last = 1;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'; 
		PRINT '----------------------------'

		-- 2. Load silver.crm_prd_info
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		
		PRINT '>> Inserting Data Into: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt,
			dwh_source_key
		)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extract category ID from Key
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,		   -- Extract product key
			prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost, -- Replace NULL costs with zero
			-- Data Normalisation: Map product line codes to descriptive values: 
			CASE UPPER(TRIM(prd_line)) 
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'Unknown'
			END AS prd_line,
			CAST(prd_start_dt AS DATE) AS prd_start_dt, 
			-- Generate product end dates based on the next products's start date
			CAST(DATEADD(day, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt ASC)) AS DATE) AS prd_end_dt,
			'CRM' AS dwh_source_key
		FROM bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'; 
		PRINT '----------------------------'

		-- 3. Load silver.crm_sales_details
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;

		PRINT'>> Inserting Data Into: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price,
			dwh_source_key
		)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			-- Transforming YYYYMMDD Integers into proper SQL DATEs
			CASE
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
			END AS sls_order_dt,
			CASE
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			-- Financial Integrity: Recalculate Sales if missing or mathematically incorrect
			CASE
				WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			-- Financial Integrity: Derive Price if missing/invalid using Sales and Quantity
			CASE	
				WHEN sls_price IS NULL OR sls_price <=0 THEN sls_sales / NULLIF(sls_quantity, 0)
				ELSE sls_price
			END AS sls_price,
			'CRM' AS dwh_source_key
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'; 
		PRINT '----------------------------'

		-- ====================================================
		-- ERP Tables
		--=====================================================

		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';

		-- 4. Load silver.erp_cust_az12
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;

		PRINT '>> Inserting Data Into: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12 (
			customer_id,
			bdate,
			gender,
			dwh_source_key
		)
		SELECT 
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) -- Remove 'NAS' prefix if present
				ELSE cid
			END AS customer_id,
			CASE
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END AS bdate, -- Invalidating future birthdays
			CASE	
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				ELSE 'Unknown'
			END AS gender,
			'ERP' AS dwh_source_key
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'; 
		PRINT '----------------------------'

		-- 5. Load silver.erp_loc_a101
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		
		PRINT '>> Inserting Data Into: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101 (
			customer_id,
			country,
			dwh_source_key
		)
		SELECT 
			REPLACE(cid, '-', '') AS customer_id,
			-- Mapping country codes to full names for standardisation reporting
			CASE
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'Unknown'
				ELSE TRIM(cntry)
			END AS country,
			'ERP' AS dwh_source_key
		FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'; 
		PRINT '----------------------------'

		-- 6. Load silver.erp_px_cat_g1v2
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		
		PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2 (
			cat_id,
			cat,
			subcat,
			maintenance,
			dwh_source_key
		)
		SELECT
			id AS cat_id,
			cat,
			subcat,
			maintenance,
			'ERP' AS dwh_source_key
		FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'; 
		PRINT '----------------------------'

		SET @batch_end_time = GETDATE();
		PRINT '================================================';
		PRINT 'Loading Silver Layer is Completed';
		PRINT '	  - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds'
		PRINT '================================================';
	END TRY

	BEGIN CATCH
		-- Comprehensive error reporting for failure diagnostics
		PRINT '=========================================================='	
		PRINT 'ERROR OCCURRED DURING LOADING THE SILVER LAYER'
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number:  ' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State:   ' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================================='
	END CATCH
END;
GO
