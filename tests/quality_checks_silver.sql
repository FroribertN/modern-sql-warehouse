/*
============================================================================================================================================
Quality Checks
============================================================================================================================================
Description:
	This script performs various quality checks for data consistency, accuracy, and standardisation across the 'silver' schemas.
	It includes checks for:
	- NULL or duplicate primary keys.
	- Unwanted spaces in string fields.
	- Data standardisation and consistency.
	- Invalid date range and orders.
	- Data consistency between related fields.

Usage Notes:
	- Run these checks after data loading the Silver Layer (silver.silver_load).
	- Investigate and resolve any discrepancies found during the checks.
============================================================================================================================================
*/

-- ===================================================
-- Checking 'silver.crm_cust_info'
-- ===================================================
-- Check for Nulls or Duplicates in Primary Key 
-- Expectation: No Results
SELECT 
	cst_id,
	COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
GO

-- Check for unwanted spaces
-- Expectation: No Results
SELECT 
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key)
	OR cst_firstname != TRIM(cst_firstname)
	OR cst_lastname != TRIM(cst_lastname)
	OR cst_marital_status != TRIM(cst_marital_status);
GO

-- Data standardisation & consistency 
SELECT DISTINCT cst_gndr FROM silver.crm_cust_info;
SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info;
GO

-- ===================================================
-- Checking 'silver.crm_prd_info'
-- ===================================================
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Results
SELECT
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;
GO

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
	prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);
GO

-- Check for Nulls or Negative Values in Cost
-- Expectation: No Results
SELECT 
	prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;
GO

-- Check Standardisation & Consistency
SELECT DISTINCT prd_line FROM silver.crm_prd_info;
GO

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
GO

-- ===================================================
-- Checking 'silver.crm_sales_details'
-- ===================================================

-- Check for Invalid Date Orders (Order Date > Shipping/Due Date)
-- Expectation: No Results
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
	OR sls_order_dt > sls_due_dt;
GO

-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE ABS(sls_sales - (sls_quantity * sls_price)) > 0.01 -- Handling potential rounding differences
	OR sls_sales IS NULL 
	OR sls_quantity IS NULL 
	OR sls_price IS NULL
	OR sls_sales <= 0 
	OR sls_quantity <= 0			
	OR sls_price <= 0;
GO

-- ===================================================
-- Checking 'silver.erp_cust_az12'
-- ===================================================
-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today
SELECT DISTINCT 
	bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
	OR bdate > GETDATE();
GO

-- Data Standardization & Consistency
SELECT DISTINCT 
	gender
FROM silver.erp_cust_az12;
GO

-- ===================================================
-- Checking 'silver.erp_loc_a101'
-- ===================================================
-- Data Standardisation & Consistency (Country names should be full, not codes)
SELECT DISTINCT 
	country
FROM silver.erp_loc_a101
ORDER BY country;
GO

-- ===================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ===================================================
-- Check for Unwanted Spaces
-- Expectation: No results
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
	OR subcat != TRIM(subcat) 
	OR maintenance != TRIM(maintenance);
GO

-- Data Standardization & Consistency
SELECT DISTINCT 
	maintenance 
FROM silver.erp_px_cat_g1v2;
GO
