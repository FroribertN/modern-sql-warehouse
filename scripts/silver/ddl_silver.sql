/*
============================================================================================================================================
Data Definition Language (DDL) Script: Create Silver Tables
============================================================================================================================================
Description:
	This script creates the schema for 'silver' tables. It represents the "cleansed" layer of the Medallion Architecture, providing 
	standardised data types and metadata for the lineage.

WARNING:
	This script is DESTRUCTIVE. It drops existing tables in the 'silver' schema before recreating them. All data currently in these tables
	will be permanently lost.
============================================================================================================================================
*/

-- ============================================================
-- CRM Tables
-- ============================================================

IF OBJECT_ID ('silver.crm_cust_info', 'U') IS NOT NULL
		DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
		cst_id				INT NOT NULL,
		cst_key				NVARCHAR(50) NOT NULL,
		cst_firstname		NVARCHAR(50),
		cst_lastname		NVARCHAR(50),
		cst_marital_status	NVARCHAR(50),
		cst_gndr			NVARCHAR(10),
		cst_create_date		DATE,
		dwh_load_date		DATETIME2 DEFAULT GETDATE(),
		dwh_source_key		NVARCHAR(20) DEFAULT 'CRM',
	CONSTRAINT PK_silver_crm_cust_info PRIMARY KEY (cst_id)
);
GO

IF OBJECT_ID ('silver.crm_prd_info', 'U') IS NOT NULL
		DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
		prd_id				INT NOT NULL,
		cat_id				NVARCHAR(50),
		prd_key				NVARCHAR(50) NOT NULL,
		prd_nm				NVARCHAR(50),
		prd_cost			DECIMAL(18, 2),
		prd_line			NVARCHAR(50),
		prd_start_dt		DATE,
		prd_end_dt			DATE,
		dwh_load_date		DATETIME2 DEFAULT GETDATE(),
		dwh_source_key		NVARCHAR(20) DEFAULT 'CRM',
	CONSTRAINT PK_silver_crm_prd_info PRIMARY KEY (prd_id)
);
GO

IF OBJECT_ID ('silver.crm_sales_details', 'U') IS NOT NULL
		DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
		sls_ord_num			NVARCHAR(50) NOT NULL,
		sls_prd_key			NVARCHAR(50) NOT NULL,
		sls_cust_id			INT NOT NULL,
		sls_order_dt		DATE,           -- changed to DATE
		sls_ship_dt			DATE,
		sls_due_dt			DATE,
		sls_sales			DECIMAL(18, 2) CONSTRAINT CK_crm_sales_amt CHECK (sls_sales >=0),
		sls_quantity		INT,
		sls_price			DECIMAL(18, 2) CONSTRAINT CK_crm_price_amt CHECK (sls_price >=0),
		dwh_load_date		DATETIME2 DEFAULT GETDATE(),
		dwh_source_key		NVARCHAR(20) DEFAULT 'CRM',
	-- Performance: Fact tables benefit from Columnstore Indexes
	INDEX IX_silver_crm_sales_details_columnstore CLUSTERED COLUMNSTORE
);
GO

-- ============================================================
-- ERP Tables
-- ============================================================

IF OBJECT_ID ('silver.erp_cust_az12', 'U') IS NOT NULL
		DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
		customer_id			NVARCHAR(50) NOT NULL,
		bdate				DATE,
		gender				NVARCHAR(10),
		dwh_load_date		DATETIME2 DEFAULT GETDATE(),
		dwh_source_key		NVARCHAR(20) DEFAULT 'ERP',
	CONSTRAINT PK_silver_erp_cust_az12 PRIMARY KEY (customer_id)
);
GO

IF OBJECT_ID ('silver.erp_loc_a101', 'U') IS NOT NULL
		DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
		customer_id			NVARCHAR(50) NOT NULL,
		country				NVARCHAR(50),
		dwh_load_date		DATETIME2 DEFAULT GETDATE(),
		dwh_source_key		NVARCHAR(20) DEFAULT 'ERP',
	CONSTRAINT PK_silver_erp_loc_a101 PRIMARY KEY (customer_id)
);
GO

IF OBJECT_ID ('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
		DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
	cat_id					NVARCHAR(50) NOT NULL,
	cat						NVARCHAR(50),
	subcat					NVARCHAR(50),
	maintenance				NVARCHAR(50),
	dwh_load_date			DATETIME2 DEFAULT GETDATE(),
	dwh_source_key			NVARCHAR(20) DEFAULT 'ERP',
CONSTRAINT PK_silver_erp_px_cat_g1v2 PRIMARY KEY (cat_id)
);
GO
