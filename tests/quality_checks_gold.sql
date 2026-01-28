/*
============================================================================================================================================
Quality Checks: Gold Layer
============================================================================================================================================
Description:
	This script performs final validation on the Gold Layer (Star Schema).
	It focuses on:
	- Uniqueness: Ensuring Surrogate Keys (customer_key, product_key) are truly unique.
	- Referential Integrity: Ensuring every sale in the Fact Table links to a valid Dimension record.
	- Model Connectivity: Verifying that the schema is ready for Power BI/Reporting.

Usage Notes:
	- Run these checks after executing the Gold Layer DDL script.
	- Any results returned indicate a breakdown in the join logic or surrogate key generation.
============================================================================================================================================
*/
-- ===================================================
-- Checking 'gold.dim_customers'
-- ===================================================
-- Requirement: Customer Key must be Unique 
-- Expectation: No Results  
SELECT 
	customer_key,
	COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;
GO

-- ===================================================
-- Checking 'gold.dim_products'
-- ===================================================
-- Requirement: Product Key must be Unique 
-- Expectation: No Results 
SELECT 
	product_key,
	COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;
GO

-- ===================================================
-- Checking 'gold.fact_sales' Referential Integrity
-- ===================================================
-- Requirement: Every sale must link to an existing customer and product.
-- If a join returns NULL, it means the fact table has "Orphaned" records.
-- Expectation: No Results
SELECT
	'Orphaned Sales' AS issue,
	COUNT(*) AS record_count
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c
	ON c.customer_key = s.customer_key
LEFT JOIN gold.dim_products AS p
	ON p.product_key = s.product_key
WHERE p.product_key IS NULL 
	OR c.customer_key IS NULL;
GO
