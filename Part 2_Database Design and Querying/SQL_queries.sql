-- Query 1: Total sales by region and category.
SELECT 
    f.region,
    p.category,
    CAST(ROUND(SUM(f.quantity * p.price * (1 - ISNULL(f.discount,0))), 2) AS DECIMAL(18,2)) AS total_sales
FROM [SalesDB].[dbo].[FactSales] f
JOIN [SalesDB].[dbo].[DimProduct] p ON f.product_id = p.product_id
GROUP BY f.region, p.category
ORDER BY f.region, p.category;

-- Query 2:Top 5 products by total revenue.
SELECT TOP 5
    p.product_name,
    CAST(ROUND(SUM(f.quantity * p.price * (1 - ISNULL(f.discount,0))), 2) AS DECIMAL(18,2)) AS total_revenue
FROM [SalesDB].[dbo].[FactSales] f
JOIN [SalesDB].[dbo].[DimProduct] p ON f.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Query 3: Monthly sales trend.
SELECT 
    d.year,
    d.month,
    CAST(ROUND(SUM(f.quantity * p.price * (1 - ISNULL(f.discount,0))), 2) AS DECIMAL(18,2)) AS monthly_sales
FROM [SalesDB].[dbo].[FactSales] f
JOIN [SalesDB].[dbo].[DimProduct] p ON f.product_id = p.product_id
JOIN [SalesDB].[dbo].[DimDate] d ON f.date_key = d.date_key
GROUP BY d.year, d.month
ORDER BY d.year, d.month;

-- Query 4: Average discount percentage per region.
SELECT 
    region,
    CAST(ROUND(AVG(ISNULL(discount,0)) * 100, 2) AS DECIMAL(18,2)) AS avg_discount_percentage
FROM [SalesDB].[dbo].[FactSales]
GROUP BY region
ORDER BY region;

-- Query 5: Number of transactions with total_value > $1000.
SELECT 
    COUNT(*) AS high_value_transactions
FROM [SalesDB].[dbo].[FactSales] f
JOIN [SalesDB].[dbo].[DimProduct] p ON f.product_id = p.product_id
WHERE (f.quantity * p.price * (1 - ISNULL(f.discount,0))) > 1000;

