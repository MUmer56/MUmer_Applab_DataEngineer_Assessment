-- ===========================================
-- Project : Mid-Level Data Engineer Assessment
-- Database: SalesDB
-- Schema: dbo
-- Purpose : Create star-schema model for sales and customers
-- Tables  : DimCustomer, DimProduct, DimDate, vw_DimDate, FactSales
-- Table Indexes
-- ===========================================

-- Step 1: Create database if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'SalesDB')
BEGIN
    PRINT 'Creating database [SalesDB]...';
    CREATE DATABASE SalesDB;
END
ELSE
BEGIN
    PRINT 'Database [SalesDB] already exists. Skipping creation.';
END
GO

USE SalesDB;
GO

-- Step 2: Ensure schema exists
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'dbo')
BEGIN
    EXEC('CREATE SCHEMA dbo');
END
GO


-- ==========================================
-- 1. DIMENSION: Customer
-- ==========================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DimCustomer') AND type = 'U')
BEGIN
    PRINT 'Creating table: DimCustomer...';
    CREATE TABLE dbo.DimCustomer (
        customer_id      NVARCHAR(50) PRIMARY KEY,
        customer_name    NVARCHAR(255) NULL,
        email            NVARCHAR(320) NULL,
        region           NVARCHAR(50) NULL,
        join_date        INT NULL,
        loyalty_points   INT NULL,
        created_at       DATETIME2 DEFAULT SYSDATETIME(),
        updated_at       DATETIME2 DEFAULT SYSDATETIME() NULL
    );
END
ELSE
    PRINT 'Table DimCustomer already exists. Skipping creation.';
GO

-- Insert a default "Unknown" record into DimCustomer
-- Purpose: Acts as a surrogate for any FactSales or related fact records where the customer_id is missing, null, or invalid.
-- This ensures referential integrity between Fact tables and DimCustomer.
IF NOT EXISTS (SELECT 1 FROM dbo.DimCustomer WHERE customer_id = 'Unknown')
BEGIN
    INSERT INTO dbo.DimCustomer (
        customer_id,
        customer_name,
        email,
        region,
        join_date,
        loyalty_points,
        created_at,
        updated_at
    )
    VALUES (
        'Unknown',
        'Unknown Customer',
        'Unknown',
        'Unknown',
        19900101,       
        0,        
        SYSDATETIME(),
        SYSDATETIME()
    );
END


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DimCustomer_Region_JoinDate')
BEGIN
    CREATE INDEX IX_DimCustomer_Region_JoinDate 
    ON dbo.DimCustomer (region, join_date);
END
GO


-- ==========================================
-- 2. DIMENSION: Product
-- ==========================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DimProduct') AND type = 'U')
BEGIN
    PRINT 'Creating table: DimProduct...';
    CREATE TABLE dbo.DimProduct (
        product_id     VARCHAR(20) PRIMARY KEY,
        product_name   NVARCHAR(255) NOT NULL,
        category       NVARCHAR(100) NULL,
        price          DECIMAL(10,2) NOT NULL DEFAULT 0.00,
        created_at     DATETIME2 DEFAULT SYSDATETIME(),
        updated_at     DATETIME2 NULL
    );
END
ELSE
    PRINT 'Table DimProduct already exists. Skipping creation.';
GO

-- Insert a default "Unknown" record into DimProduct
-- Purpose: Acts as a surrogate for any FactSales records where the product_id is missing, null, or invalid.
-- This ensures referential integrity between FactSales and DimProduct.
IF NOT EXISTS (SELECT 1 FROM dbo.DimProduct WHERE product_id = 'Unknown')
BEGIN
    INSERT INTO dbo.DimProduct (
        product_id,
        product_name,
        category,
        price,
        created_at,
        updated_at
    )
    VALUES (
        'Unknown',
        'Unknown Product',
        'Unknown',
        0.00,
        SYSDATETIME(),
        SYSDATETIME()
    );
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DimProduct_Category')
BEGIN
    CREATE INDEX IX_DimProduct_Category 
    ON dbo.DimProduct (category);
END
GO


-- ==========================================
-- 3. DIMENSION: Date
-- ==========================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.DimDate') AND type = 'U')
BEGIN
    PRINT 'Creating table: DimDate...';
    CREATE TABLE dbo.DimDate (
        date_key      INT PRIMARY KEY,   -- YYYYMMDD
        full_date     DATE NOT NULL,
        year          INT NOT NULL,
        month         INT NOT NULL,
        month_name    NVARCHAR(20) NOT NULL,
        day           INT NOT NULL,
        quarter       INT NOT NULL
    );
END
ELSE
    PRINT 'Table DimDate already exists. Skipping creation.';
GO

-- Insert a default "Unknown" record into DimDate
-- Purpose: Serves as a placeholder date record for any Fact or Dimension table where the date_key is missing, null, or invalid.
-- This ensures referential integrity between fact tables and DimDate by providing a consistent fallback value (19900101).
IF NOT EXISTS (SELECT 1 FROM dbo.DimDate WHERE date_key = 19900101)
BEGIN
    INSERT INTO dbo.DimDate (
        date_key,
        full_date,
        year,
        month,
        month_name,
        day,
        quarter
    )
    VALUES (
        19900101,              
        '1990-01-01',        
        1990,
        1,
        'Unknown',
        1,
        0
    );
END
GO

-- ==========================================
-- DimDate View
-- Purpose: Provides DimDate records from 2010 onwards,
-- excluding placeholder/legacy dates, for clean and relevant reporting in Power BI.
-- ==========================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.vw_DimDate') AND type = 'V')
BEGIN
    PRINT 'Creating view: vw_DimDate...';
    EXEC('
        CREATE VIEW dbo.vw_DimDate AS
        SELECT *
        FROM dbo.DimDate
        WHERE full_date >= ''2010-01-01''
    ');
END
ELSE
    PRINT 'View vw_DimDate already exists. Skipping creation.';
GO


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DimDate_YearMonth')
BEGIN
    CREATE INDEX IX_DimDate_YearMonth 
    ON dbo.DimDate (year, month);
END
GO


-- ==========================================
-- 4. FACT: Sales / Transactions
-- ==========================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.FactSales') AND type = 'U')
BEGIN
    PRINT 'Creating table: FactSales...';
	CREATE TABLE dbo.FactSales (
		transaction_id   VARCHAR(20) NOT NULL,
		product_id       VARCHAR(20) NOT NULL,
		customer_id      NVARCHAR(50) NULL,
		date_key         INT NOT NULL,
		quantity         INT CHECK (quantity >= 0),
		discount         DECIMAL(5,2) NULL CHECK (discount >= 0),
		region           NVARCHAR(50) NULL,
		created_at       DATETIME2 DEFAULT SYSDATETIME(),
    
		CONSTRAINT PK_FactSales PRIMARY KEY (transaction_id, product_id),

		CONSTRAINT FK_FactSales_Customer FOREIGN KEY (customer_id)
			REFERENCES dbo.DimCustomer (customer_id),

		CONSTRAINT FK_FactSales_Product FOREIGN KEY (product_id)
			REFERENCES dbo.DimProduct (product_id),

		CONSTRAINT FK_FactSales_Date FOREIGN KEY (date_key)
			REFERENCES dbo.DimDate (date_key)
	);
END
ELSE
    PRINT 'Table FactSales already exists. Skipping creation.';
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FactSales_Region_Date')
BEGIN
    CREATE INDEX IX_FactSales_Region_Date 
    ON dbo.FactSales (region, date_key);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FactSales_Customer_Product')
BEGIN
    CREATE INDEX IX_FactSales_Customer_Product 
    ON dbo.FactSales (customer_id, product_id);
END
GO

-- ==========================================
-- 5. LOGS: BadDataLog 
-- ==========================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.BadDataLog ') AND type = 'U')
BEGIN
    PRINT 'Creating table: BadDataLog ...';
	CREATE TABLE dbo.BadDataLog (
		log_id INT IDENTITY(1,1) PRIMARY KEY,         -- Surrogate key for internal use
		etl_run_id DATETIME NOT NULL,                 -- Timestamp of the ETL run
		source_system NVARCHAR(50) NOT NULL,          -- e.g., 'python_etl' or 'ssis_pkg'
		record_id NVARCHAR(100) NULL,                 -- Natural key of the row: transaction_id for sales data, customer_id for customers data; NULL if missing
		bad_column NVARCHAR(100) NOT NULL,            -- Column with issue
		issue_type NVARCHAR(50) NOT NULL,             -- e.g., 'missing', 'invalid_format', 'negative_value', 'duplicate'
		original_record NVARCHAR(MAX) NOT NULL,       -- JSON full row for traceability
		notes NVARCHAR(255) NULL                      -- Optional description
	);
END
ELSE
    PRINT 'Table BadDataLog already exists. Skipping creation.';
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_BadData_ETLRun_Source')
BEGIN
    CREATE INDEX IX_BadData_ETLRun_Source 
    ON dbo.BadDataLog (etl_run_id, source_system);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_BadData_RecordId')
BEGIN
    CREATE INDEX IX_BadData_RecordId 
    ON dbo.BadDataLog (record_id);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_BadData_ETLRun_Column')
BEGIN
    CREATE INDEX IX_BadData_ETLRun_Column 
    ON dbo.BadDataLog (etl_run_id, bad_column);
END
GO

PRINT 'Schema creation complete.';

