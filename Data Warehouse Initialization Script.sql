-- Data Warehouse Initialization Script
-- --------------------------------
-- The goal of this Data Warehouse (DWH) project is to track sales data efficiently while ensuring historical changes in customer and product attributes using Slowly Changing Dimensions (SCD Type 2).
-- The following business requirements are addressed:
-- 1. Track customer demographic changes over time (e.g., occupation, income level, city changes).
-- 2. Maintain a historical record of product changes (e.g., brand, size, color changes).
-- 3. Provide accurate sales tracking by linking transactional data to current and historical dimension data.
-- 4. Support business intelligence (BI) and reporting for sales performance by store, region, product, and customer demographics.
-- 5. Enable time-based analysis using a date dimension to facilitate period comparisons.

-- Step 1: Create Database
CREATE DATABASE DWH_SALES_PROJECT;
USE DWH_SALES_PROJECT;

-- Step 2: Create Dimension Tables
CREATE TABLE dim_customers (
    customer_key INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT,
    name VARCHAR(250),
    gender VARCHAR(50),
    age INT,
    Occupation VARCHAR(250),
    IncomeLevel VARCHAR(50),
    City VARCHAR(255),
    start_date DATETIME,
    end_date DATETIME NULL,
    is_current BIT
);

CREATE TABLE dim_products (
    product_key INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT,
    product_name VARCHAR(250),
    category VARCHAR(100),
    brand VARCHAR(100),
    size VARCHAR(50),
    color VARCHAR(50),
    price DECIMAL(10,2),
    start_date DATETIME,
    end_date DATETIME NULL,
    is_current BIT
);


CREATE TABLE dim_stores (
    store_key INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Key
    store_id INT,  
    store_name VARCHAR(100),
    region VARCHAR(100),
    city VARCHAR(100),
    manager VARCHAR(100),
    start_date DATETIME,
    end_date DATETIME NULL,
    is_current BIT
);

CREATE TABLE dim_dates (
    date_key INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate Key
    Date DATE NOT NULL,  
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    Month INT NOT NULL,
    Week INT NOT NULL,
    Day INT NOT NULL,
    Period CHAR(2) CHECK (Period IN ('AM', 'PM'))
);


DECLARE @start_date DATE = '2020-01-01';  
DECLARE @end_date DATE = '2030-12-31';    

WHILE @start_date <= @end_date
BEGIN
    DECLARE @year INT = YEAR(@start_date);
    DECLARE @quarter INT = DATEPART(QUARTER, @start_date);
    DECLARE @month INT = MONTH(@start_date);
    DECLARE @week INT = DATEPART(WEEK, @start_date);
    DECLARE @day INT = DAY(@start_date);
    DECLARE @period CHAR(2) = CASE WHEN DATEPART(HOUR, @start_date) < 12 THEN 'AM' ELSE 'PM' END;

    INSERT INTO dim_dates (Date, Year, Quarter, Month, Week, Day, Period)
    VALUES 
    (
        @start_date, 
        @year, 
        @quarter, 
        @month, 
        @week, 
        @day, 
        @period
    );

    SET @start_date = DATEADD(DAY, 1, @start_date);
END;

-- Step 3: Create Fact Table

CREATE TABLE fact_sales (
    SalesID INT PRIMARY KEY,
    CustomerKey INT,  
    ProductKey INT,   
    StoreKey INT,     
    DateKey INT,     
    Quantity INT,
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (CustomerKey) REFERENCES dim_customers(customer_key),
    FOREIGN KEY (ProductKey) REFERENCES dim_products(product_key),
    FOREIGN KEY (StoreKey) REFERENCES dim_stores(store_key),
    FOREIGN KEY (DateKey) REFERENCES dim_dates(date_key)  
);

-- Step 4: Handling SCD Type 2 for Customers
DECLARE @customer_id INT = 3;
DECLARE @name VARCHAR(50);
DECLARE @gender VARCHAR(10);
DECLARE @age INT;
DECLARE @Occupation VARCHAR(50);
DECLARE @IncomeLevel VARCHAR(10);
DECLARE @new_city VARCHAR(100) ;

-- Get current customer data
SELECT @name=name, @gender=gender, @age=age, @Occupation=Occupation, @IncomeLevel=IncomeLevel
FROM dim_customers
WHERE customer_id = @customer_id AND is_current = 1;

-- Update old record
UPDATE dim_customers
SET is_current = 0, end_date = GETDATE()
WHERE customer_id = @customer_id AND is_current = 1;

-- Insert new record
INSERT INTO dim_customers (customer_id, name, gender, age, Occupation, IncomeLevel, City, start_date, end_date, is_current)
VALUES (@customer_id, @name, @gender, @age, @Occupation, 'High', 'London', GETDATE(), NULL, 1);

select * from dim_customers order by customer_id


-- Step 5: Handling SCD Type 2 for Dim_product ...

DECLARE @product_id INT = 10;
DECLARE @product_name VARCHAR(100);
DECLARE @category VARCHAR(500);
DECLARE @brand VARCHAR(500); 
DECLARE @size VARCHAR(50) ; 
DECLARE @color VARCHAR(50);
DECLARE @price DECIMAL(10,2);

-- Get current product data
SELECT 
    @product_name = product_name,
    @category = category,
    @brand = brand,  
    @size = size,  
	@color = color,
    @price = price
FROM dim_products
WHERE product_id = @product_id
  AND is_current = 1;

-- Update old record
UPDATE dim_products
SET 
    is_current = 0,  
    end_date = GETDATE()  
WHERE product_id = @product_id
  AND is_current = 1;

-- Insert new record
INSERT INTO dim_products (product_id, product_name, category, brand, size, color, price, start_date, end_date, is_current)
VALUES (@product_id, @product_name, @category, @brand, 'Medium', 'Pink','6000', GETDATE(), NULL, 1);
 select * from dim_products order by product_id

-- Step 6: Insert Sample Data into fact_sales

INSERT INTO fact_sales (SalesID, CustomerKey, ProductKey, StoreKey, DateKey, Quantity, TotalAmount)
SELECT 1, customer_key, product_key, 1, (SELECT date_key FROM dim_dates WHERE Date = '2024-01-01'), 2, 199.99
FROM dim_customers, dim_products
WHERE dim_customers.customer_id = 3 AND dim_products.product_id = 1 AND dim_customers.is_current = 1 AND dim_products.is_current = 1;

DECLARE @i INT = 1;

WHILE @i <= 100
BEGIN
    INSERT INTO fact_sales (SalesID, CustomerKey, ProductKey, StoreKey, DateKey, Quantity, TotalAmount)
    SELECT 
        @i, 
        customer_key, 
        product_key, 
        (@i % 5) + 1 AS StoreKey, 
        (SELECT date_key FROM dim_dates WHERE Date = DATEADD(DAY, @i, '2024-01-01')), 
        (@i % 10) + 1 AS Quantity, 
        (@i * 10) + 99.99 AS TotalAmount
    FROM 
        dim_customers, dim_products
    WHERE 
        dim_customers.customer_id = (@i % 10) + 1 
        AND dim_products.product_id = (@i % 5) + 1 
        AND dim_customers.is_current = 1 
        AND dim_products.is_current = 1;

    SET @i = @i + 1;
END;

select * from fact_sales

