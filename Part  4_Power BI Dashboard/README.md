# Part 4: Power BI Dashboard

## Overview
This Power BI dashboard visualizes insights from the SalesDB dataset, combining both sales and customer data. The goal is to provide a clear view of sales performance, customer distribution, product revenue, and key metrics to support analytical decision-making.

The dashboard includes multiple visuals, card KPIs, and interactive filters to allow slicing and dicing by different dimensions such as year, month, region, product, and product category.

## Visualizations

### Card Visuals
These card visuals provide high-level KPIs at a glance:
- **Total Sales** – Sum of all sales across transactions.
- **Total Customers** – Count of distinct customers.
- **Total Loyalty Points** – Sum of loyalty points from all customers.
- **High-Value Transactions (>1000)** – Count of transactions where total value exceeds 1000.
- **Average Sale per Transaction** – Average sales amount per transaction.

### Charts and Tables
1. **Monthly Sales Trend (Line Chart)**  
   Shows the trend of sales over months to monitor performance and seasonality.
   
2. **Top 5 Products by Revenue (Table)**  
   Lists the five highest revenue-generating products for product performance analysis.
   
3. **Loyalty Points Distribution by Region (Donut Chart)**  
   Visualizes how loyalty points are distributed across different regions, highlighting customer engagement.

4. **Sales by Product Category (Line Chart)**  
   Illustrates revenue trends across product categories over time.

5. **Total Sales by Region (Bar Chart)**  
   Displays total sales by region to identify top-performing areas.

## Filters
The dashboard includes a filter pane with dropdowns for:
- **Year**
- **Month**
- **Region**
- **Product**
- **Product Category**  

These filters allow users to dynamically adjust the visuals based on their analysis needs.

## ## Power BI Dashboard - DAX Measures and Visuals

1. **Total Sales**
Total Sales = 
SUMX(
    FactSales,
    FactSales[quantity] * RELATED(DimProduct[price])
)

**Explanation:**
Calculates the total sales by multiplying the quantity of each product sold with its price. The RELATED function fetches the price from the DimProduct table to ensure accurate computation across the fact and dimension tables.

2. **Average Sale per Transaction**
Average Sale per Transaction = 
VAR NumTransactions =
    DISTINCTCOUNT(FactSales[transaction_id])
RETURN
    DIVIDE([Total Sales], NumTransactions)

**Explanation:**
Computes the average sale amount per transaction by dividing the total sales by the number of unique transactions.

3. **Total Loyalty Points**
Total Loyalty Points = SUM(DimCustomer[loyalty_points])

**Explanation:**
Sums up the loyalty points from the DimCustomer table to show total accumulated loyalty points across all customers.

4. **High-Value Transactions (>1000)**
High Value Transactions (>1000) = 
VAR TransactionTotals =
    ADDCOLUMNS(
        SUMMARIZE(FactSales, FactSales[transaction_id]),
        "TransactionTotal",
            SUMX(
                FILTER(FactSales, FactSales[transaction_id] = EARLIER(FactSales[transaction_id])),
                FactSales[quantity] * RELATED(DimProduct[price])
            )
    )
RETURN
COUNTROWS(FILTER(TransactionTotals, [TransactionTotal] > 1000))

**Explanation:**
Counts the number of transactions where the total value exceeds 1000. This helps identify high-value orders or VIP customer transactions.

5. **Sales YTD**
Sales YTD = 
TOTALYTD(
    [Total Sales],
    DimDate[full_date]
)

**Explanation:**
Calculates year-to-date total sales using the DimDate table for time intelligence, allowing trend analysis over the current year.

6. **Total Customers**
Total Customers = DISTINCTCOUNT(FactSales[customer_id])

**Explanation:**
Counts the total number of unique customers who made purchases.

---