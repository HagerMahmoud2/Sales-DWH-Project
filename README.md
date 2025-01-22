# Sales Data Warehouse (DWH)

## Project Overview
This project is a **Sales Data Warehouse** designed using the **Star Schema** to track sales transactions efficiently while maintaining historical changes in **customers** and **products** using **Slowly Changing Dimensions (SCD Type 2)**.

## Key Features
- **Data Modeling**: Implemented **Star Schema** with fact and dimension tables.
- **Historical Tracking**: Used **SCD Type 2** to store changes in customer and product attributes.
- **Synthetic Data**: Generated sample data using **Python Faker**.
- **ETL Process**: Loaded and transformed data to ensure accuracy and consistency.
- **BI & Analytics**: Enabled insights into sales performance by region, product, and customer demographics.

## Schema Design
- **Fact Table**: `fact_sales` (Tracks sales transactions).
- **Dimension Tables**:
  - `dim_customers` (Stores customer details with historical tracking).
  - `dim_products` (Stores product details with historical tracking).
  - `dim_stores` (Stores store details).
  - `dim_dates` (Stores calendar dates for time-based analysis).

## Technologies Used
- **SQL** (Database & Queries)
- **Python Faker** (Data Generation)
- **ETL Pipelines** (For data processing)

## How to Use
1. **Create the Database**: Run the SQL script to set up tables.
2. **Generate Data**: Use Python Faker to populate dimension tables.
3. **Load Sales Data**: Insert sales transactions linking to dimension tables.
4. **Run Queries**: Perform **BI analysis** using SQL queries.

This project provides a scalable foundation for **sales analytics** and **business intelligence**.
