/*
============================================================================================================================================
Data Definition Language (DDL) Script: Gold Layer Views (Star Schema)
============================================================================================================================================
Description:
	This script defines the 'gold' layer of the Medallion Architecture. It creates the final Dimension and Fact views for BI and Reporting.
	
	The Gold Layer focuses on:
	- Creating Surrogate Keys for warehouse stability.
	- Joining Silver tables to create "Golden Records".
	- Implementing business logic (e.g., filtering for current products).
	- Mapping technical names to business friendly column names.

Usage:
	- Run the script after the Silver Layer is complete.
	- These views serve as the source for Power BI, Tableau, or Excel.
============================================================================================================================================
*/

-- ============================================================
-- 1. Dimension Table: gold.dim_customers
-- ============================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY ci.cst_id)	AS customer_key, -- Surrogate Key to uniquely identify customers across CRM and ERP
	ci.cst_id							                AS customer_id,
	ci.cst_key							              AS customer_number,
	ci.cst_firstname					            AS first_name,
	ci.cst_lastname						            AS last_name,
	la.country							              AS country,
	ci.cst_marital_status				          AS marital_status,
	-- Data Integration: priority given to CRM gender, fallback to ERP
	CASE	
		WHEN ci.cst_gndr != 'Unknown' THEN ci.cst_gndr
		ELSE COALESCE(ca.gender, 'Unknown')            
	END									                AS gender,
	ca.bdate							              AS birthdate,
	ci.cst_create_date					        AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca 
	ON	ci.cst_key = ca.customer_id
LEFT JOIN silver.erp_loc_a101 AS la 
	ON	ci.cst_key = la.customer_id;
GO

-- ============================================================
-- 2. Dimension Table: gold.dim_products
-- ============================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
	DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Surrogate Key for product tracking
	pn.prd_id												                        AS product_id,
  pn.prd_key												                      AS product_number,
	pn.prd_nm												                        AS product_name,
	pn.cat_id												                        AS category_id,
	pc.cat													                        AS category,
	pc.subcat												                        AS subcategory,
	pc.maintenance											                    AS maintenance,
	pn.prd_cost												                      AS cost,
	pn.prd_line												                      AS product_line,
	pn.prd_start_dt											                    AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
	ON pn.cat_id = pc.cat_id
WHERE pn.prd_end_dt IS NULL; -- Filter: Only include active product versions
GO

-- ============================================================
-- 3. Fact Table: gold.fact_sales
-- ============================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
	DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
	sd.sls_ord_num		AS order_number,
	pr.product_key		AS product_key, -- Reference to dim_products
	cu.customer_key		AS customer_key, -- Reference to dim_customers
	sd.sls_order_dt		AS order_date,
	sd.sls_ship_dt		AS shipping_date,
	sd.sls_due_dt		  AS due_date,
	sd.sls_sales		  AS sales_amount,
	sd.sls_quantity		AS quantity,
	sd.sls_price		  AS price
FROM silver.crm_sales_details AS sd
-- Join with Gold Dimensions to retrieve warehouse-specific Surrogate keys
LEFT JOIN gold.dim_products AS pr
	ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers AS cu
	ON sd.sls_cust_id = cu.customer_id;
GO
