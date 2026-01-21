/*
============================================================================================================================================
Create Database and Schemas
============================================================================================================================================
Description:
    This script initialises the 'DataWarehouse' database. It follows the Medallion Architecture by creating Bronze, Silver, and Gold layers.

WARNING:
    This script is DESTRUCTIVE. If 'DataWarehouse' exists, it will be dropped and all data will be permanently lost.
============================================================================================================================================
*/

USE master;
GO

-- Delete existing database to ensure a clean environment
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    -- Terminate active connections and drop the database
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Initialise the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

--------------------------------------------------------------------------------------------------------------------------------------------
-- Create Medallion Schemas
--------------------------------------------------------------------------------------------------------------------------------------------
-- Bronze: Raw data ingestion
-- Silver: Cleaned and standardised data
-- Gold:   Business-ready aggregated data
--------------------------------------------------------------------------------------------------------------------------------------------
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
