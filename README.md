## Overview of the Complete Solution

This project demonstrates a full end-to-end data engineering and analytics pipeline, covering data extraction, transformation, loading, database modeling, and visualization. It integrates multiple technologies including Python, SQL Server, SSIS, and Power BI to provide actionable business insights from sales and customer data.

The solution is structured into the following parts:

1. **ETL Pipeline (Python)**  
   - Extracts raw sales data from json source file.  
   - Cleans and validates data, handling missing, duplicate, or invalid records.  
   - Implements incremental loading logic to update the FactSales table without overwriting existing records. 
   -- Load data to dimesion tables DimDate, DimProduct in an incremental manner. 
   - Maintains referential integrity by using "Unknown" surrogate records in dimension tables.  
   - Logs bad or invalid data for traceability.

2. **Database Design (SQL Server)**  
   - Implements a star-schema model with FactSales and dimension tables: DimCustomer, DimProduct, DimDate.  
   - Ensures normalization and efficient storage, with surrogate keys and primary/foreign key relationships.  
   - Implements indexes to optimize analytical queries for performance.  
   - Handles slowly changing dimensions (SCD0) for updates to existing records.

3. **SSIS Package (Customer Data JSON)**  
   - Automates the ingestion of JSON customer data into the DimCustomer table.  
   - Includes data cleaning, deduplication, schema enforcement, and conditional logic for new and existing records.  
   - Updates existing records using SCD0 approach while maintaining data integrity.  

4. **Power BI Dashboard**  
   - Provides an interactive visualization layer to monitor business metrics.  
   - Includes key visuals: Total Sales, Monthly Sales Trend, Top Products, Customer Loyalty Points, High-Value Transactions.  
   - Implements DAX measures for total, average, and YTD calculations, as well as high-value transaction tracking.  
   - Filter pane allows slicing by Year, Month, Region, Product, and Product Category for detailed analysis.

5. **Logging and Monitoring**  
   - Python ETL pipeline log errors and bad data for auditing.  
   - Ensures traceability of data transformations and facilitates debugging.

**Key Features:**  
- End-to-end automation from data ingestion to analytics.  
- Incremental and scalable design suitable for production deployment.  
- Star-schema modeling for efficient querying and reporting.  
- Interactive dashboards for real-time business insights.  
- Robust data validation and error logging to maintain data quality.

## Documentation

For detailed documentation of each part of this project, please refer to the individual Markdown files linked below:

- [Part 1: Python Sales ETL Pipeline](/Part%201_Python%20Data%20Pipeline/README.md) – Complete ETL workflow, data cleaning, incremental logic, and fact/dimension handling.
- [Part 2: Database Design and Querying](/Part%202_Database%20Design%20and%20Querying/README.md) – Database schema, table relationships, indexes, and SQL queries with explanations
- [Part 3: SSIS Customr ETL Pipeline](/Part%203_SSIS%20Pipeline/README.md) – SSIS package design, data flow, error handling, SCD0 updates etc.
- [Part 4: Power BI Dashboard](/Part%20%204_Power%20BI%20Dashboard/README.md) – Dashboard visuals, DAX measures, filters, and insights summary.

This README serves as the central index to access all detailed documentation for the project.

