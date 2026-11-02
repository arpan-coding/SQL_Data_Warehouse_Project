/*

This portion is the header comment. It gives an overall summary of the code.

=============================================================================
Create Database and Schemas
=============================================================================
Purpose:
	This script creates a new database named 'DataWarehouse' after checking if it already exists.
	If the database exists, it will be dropped and recreated.
	Additionally, the script sets up three schemas within the databes namely, 'bronze', 'silver', and 'gold'.

WARNING:
	Running this script will drop the entire 'DataWarehouse' database if it exists.
	All data in the database will be permanently deleted.
	Proceed with caution and ensure proper backup has been taken before running the script.


*/


USE master;

GO		-- That 'GO' commands actas as a seperator everywhere. It tells the SQL to execute the first code completely before moving to the next code.--

-- Drop and recreate the 'DataWarehouse' database --

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;

GO


-- Creating the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;

USE DataWarehouse;

-- creating the schemas --

CREATE SCHEMA bronze;

GO		-- This Go command acts as a separator --

CREATE SCHEMA silver;

GO

CREATE SCHEMA gold;
