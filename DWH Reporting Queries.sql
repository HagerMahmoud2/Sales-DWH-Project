--Store Sales Analysis Report
use [DWH_SALES_PROJECT]

-- Query 1: Sales by Product per Month
-- This query shows the sales data of products by month. It can be used to monitor monthly product performance.
SELECT 
    p.product_name,
    SUM(f.Quantity) AS TotalQuantitySold,
    SUM(f.TotalAmount) AS TotalSalesAmount,
    d.Month,
    d.Year
FROM fact_sales f
JOIN dim_products p ON f.ProductKey = p.product_key
JOIN dim_dates d ON f.DateKey = d.date_key
GROUP BY p.product_name, d.Month, d.Year
ORDER BY d.Year, d.Month;

-- Query 2: Total Sales by Customer
-- This query shows the total sales for each customer. It can be used to analyze customer purchasing behavior.
SELECT 
    c.name AS CustomerName,
    SUM(f.TotalAmount) AS TotalAmountSpent
FROM fact_sales f
JOIN dim_customers c ON f.CustomerKey = c.customer_key
GROUP BY c.name
ORDER BY TotalAmountSpent DESC;

-- Query 3: Sales by Product Category
-- This query shows the sales per product category. It helps to identify which categories are performing better.
SELECT 
    p.category,
    p.product_name,
    SUM(f.Quantity) AS TotalQuantitySold,
    SUM(f.TotalAmount) AS TotalSalesAmount
FROM fact_sales f
JOIN dim_products p ON f.ProductKey = p.product_key
GROUP BY p.category, p.product_name
ORDER BY TotalSalesAmount DESC;

-- Query 4: Sales by Region for each Store
-- This query shows the sales by region for each store. It can help to analyze geographical performance.
SELECT 
    s.region,
    st.store_name,
    SUM(f.TotalAmount) AS TotalSalesAmount
FROM fact_sales f
JOIN dim_stores s ON f.StoreKey = s.store_key
JOIN dim_stores st ON f.StoreKey = st.store_key
GROUP BY s.region, st.store_name
ORDER BY TotalSalesAmount DESC;

-- Query 5: Top Customers with Highest Sales
-- This query shows the customers who spent the most on purchases. It can be used to reward or target loyal customers.
SELECT TOP 10
    c.name AS CustomerName,
    SUM(f.TotalAmount) AS TotalAmountSpent
FROM fact_sales f
JOIN dim_customers c ON f.CustomerKey = c.customer_key
GROUP BY c.name
ORDER BY TotalAmountSpent DESC;

-- Query 6: Sales Analysis by Date (Time-Based Analysis)
-- This query shows the total sales by each day. It can help analyze daily performance trends.
SELECT 
    d.Date,
    SUM(f.TotalAmount) AS TotalSalesAmount
FROM fact_sales f
JOIN dim_dates d ON f.DateKey = d.date_key
GROUP BY d.Date
ORDER BY d.Date;



