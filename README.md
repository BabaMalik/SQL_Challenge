# SQL Analysis Using Medallion Architecture

## 📌 Overview
This repository contains SQL scripts implementing the **Medallion Architecture** (Bronze, Silver, Gold layers) for structured data processing and analytics.

### **What is Medallion Architecture?**
The **Medallion Architecture** is a data engineering design pattern used to organize data into three layers:

- **🤍 Bronze Layer**: Raw data ingestion
- **⚪ Silver Layer**: Cleaned, processed, and structured data
- **🟡 Gold Layer**: Business intelligence, aggregated insights, and reporting

This repository covers all three layers, ensuring raw data is correctly ingested, cleaned, processed, and transformed for analytics.

---

## **Dataset Overview**
The dataset contains **500,000 transactions** with fields like `TransactionID`, `CustomerID`, `TransactionDate`, `TransactionAmount`, `PaymentMethod`, etc. It was originally loaded from a **CSV file** into MySQL.

---

## 🤍 **Bronze Layer Processing**

### **1️⃣ Table Creation & Initial Data Load**
- Created the `bronze_transactions` table using **MySQL Workbench’s Table Data Import**.
- Initially, all columns were stored as **TEXT** or `VARCHAR(255)`, leading to incorrect data types.

### **2️⃣ Data Type Corrections**
- Changed certain columns to the correct types:
  - `TransactionDate` → **Converted to DATETIME**
  - `CustomerID` → **Converted to INT**
  - `TransactionAmount`, `DiscountPercent`, `ShippingCost` → **Converted to DECIMAL**
  - `CustomerAge` → **Converted to INT**
  - `StoreType`, `CustomerGender`, `Returned`, `IsPromotional` → **Converted to ENUM**

**SQL Used:**
```sql
ALTER TABLE bronze_transactions
MODIFY COLUMN CustomerID INT NULL,
MODIFY COLUMN TransactionDate DATETIME NULL,
MODIFY COLUMN TransactionAmount DECIMAL(10,2) NULL,
MODIFY COLUMN DiscountPercent DECIMAL(5,2) NULL,
MODIFY COLUMN CustomerAge INT NULL,
MODIFY COLUMN ShippingCost DECIMAL(10,2) NULL;
```

### **3️⃣ Handling NULL & Empty Values**
- Identified and replaced empty strings (`''`) with `NULL` in key columns:
  - `TransactionDate`, `CustomerID`, `ProductName`, `Region`, `PaymentMethod`, `StoreType`, `CustomerGender`.

**SQL Used:**
```sql
UPDATE bronze_transactions SET CustomerID = NULL WHERE CustomerID = '';
UPDATE bronze_transactions SET CustomerAge = NULL WHERE CustomerAge = '';
UPDATE bronze_transactions SET ProductName = NULL WHERE ProductName = '';
UPDATE bronze_transactions SET PaymentMethod = NULL WHERE PaymentMethod = '';
UPDATE bronze_transactions SET StoreType = NULL WHERE StoreType = '';
UPDATE bronze_transactions SET CustomerGender = NULL WHERE CustomerGender = '';
UPDATE bronze_transactions SET Region = NULL WHERE Region = '';
```

### **4️⃣ NULL Value Analysis**
- Performed NULL analysis to identify missing data percentages for each column.

**SQL Used:**
```sql
SELECT 
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS CustomerID_NullCount,
    SUM(CASE WHEN TransactionDate IS NULL THEN 1 ELSE 0 END) AS TransactionDate_NullCount,
    SUM(CASE WHEN PaymentMethod IS NULL THEN 1 ELSE 0 END) AS PaymentMethod_NullCount,
    SUM(CASE WHEN StoreType IS NULL THEN 1 ELSE 0 END) AS StoreType_NullCount,
    SUM(CASE WHEN CustomerAge IS NULL THEN 1 ELSE 0 END) AS CustomerAge_NullCount,
    SUM(CASE WHEN CustomerGender IS NULL THEN 1 ELSE 0 END) AS CustomerGender_NullCount,
    SUM(CASE WHEN ProductName IS NULL THEN 1 ELSE 0 END) AS ProductName_NullCount,
    SUM(CASE WHEN Region IS NULL THEN 1 ELSE 0 END) AS Region_NullCount
FROM bronze_transactions;
```


# 🥈 Silver Layer - Data Transformation, Cleansing & Enrichment


## 📌 Overview

The **Silver Layer** is an enriched, cleansed, and structured version of transactional data obtained from the **Bronze Layer**. This layer ensures data integrity, assigns default values to missing records, and enhances data with additional derived attributes for downstream analysis in the **Gold Layer**.

### 🔹 **Key Features**
- Cleanse and standardize raw transaction data
- Replace NULL values with meaningful defaults
- Derive additional attributes to improve analytical capabilities
- Assign data quality scores and issue flags for better reporting

---

## Steps in the Silver Layer Processing

### **1. Backup Existing Silver Table**
```sql
CREATE TABLE silver_transactions_backup AS
SELECT * FROM silver_transactions;
```

### **2. Drop and Recreate `silver_transactions` Table**
```sql
DROP TABLE IF EXISTS TRANSACTIONS.silver_transactions;

CREATE TABLE silver_transactions (
    TransactionID INT PRIMARY KEY,
    CustomerID INT NULL,
    TransactionDate DATETIME NULL,
    TransactionAmount DECIMAL(10,2) NULL,
    PaymentMethod VARCHAR(255) NULL,
    Quantity INT NULL,
    DiscountPercent DECIMAL(5,2) NULL,
    City VARCHAR(255) NULL,
    StoreType VARCHAR(255) NULL,
    CustomerAge INT NULL,
    CustomerGender VARCHAR(255) NULL,
    LoyaltyPoints INT,
    ProductName VARCHAR(255),
    Region VARCHAR(255),
    Returned VARCHAR(255),
    FeedbackScore INT,
    ShippingCost DECIMAL(10,2) NULL,
    DeliveryTimeDays INT,
    IsPromotional VARCHAR(255)
);
```

### **3. Insert Data from Bronze Layer**
```sql
INSERT INTO silver_transactions
SELECT * FROM bronze_transactions;
```

### **4. Replace NULL Values with Meaningful Defaults**
```sql
UPDATE silver_transactions
SET
    CustomerID = COALESCE(CustomerID, -1),
    TransactionDate = COALESCE(TransactionDate, '1900-01-01'),
    PaymentMethod = COALESCE(PaymentMethod, 'Unknown'),
    StoreType = COALESCE(StoreType, 'General'),
    CustomerAge = COALESCE(CustomerAge, 30),
    CustomerGender = COALESCE(CustomerGender, 'Unknown'),
    ProductName = COALESCE(ProductName, 'Uncategorized'),
    Region = COALESCE(Region, 'Unknown');
```

### **5. Add Enrichment Columns**
```sql
ALTER TABLE silver_transactions
ADD COLUMN transaction_year INT,
ADD COLUMN transaction_month INT,
ADD COLUMN transaction_quarter INT,
ADD COLUMN total_sale_value DECIMAL(18,6),
ADD COLUMN discount_amount DECIMAL(18,6),
ADD COLUMN net_revenue DECIMAL(18,6),
ADD COLUMN customer_segment VARCHAR(50),
ADD COLUMN age_group VARCHAR(50),
ADD COLUMN is_weekend BOOLEAN,
ADD COLUMN day_of_week VARCHAR(20),
ADD COLUMN transaction_status VARCHAR(50),
ADD COLUMN data_quality_score DECIMAL(5,2),
ADD COLUMN data_issue_flag VARCHAR(255);
```

### **6. Populate New Columns**
```sql
UPDATE silver_transactions
SET
    transaction_year = YEAR(TransactionDate),
    transaction_month = MONTH(TransactionDate),
    transaction_quarter = QUARTER(TransactionDate),
    day_of_week = DAYNAME(TransactionDate),
    is_weekend = CASE WHEN DAYOFWEEK(TransactionDate) IN (1, 7) THEN TRUE ELSE FALSE END;
```

### **7. Compute Financial Metrics**
```sql
UPDATE silver_transactions
SET
    discount_amount = TransactionAmount * (DiscountPercent / 100),
    total_sale_value = TransactionAmount + ShippingCost,
    net_revenue = total_sale_value - discount_amount;
```

### **8. Assign Customer Segments**
```sql
UPDATE silver_transactions
SET
    age_group = CASE
        WHEN CustomerAge < 25 THEN 'Young Adult'
        WHEN CustomerAge BETWEEN 25 AND 34 THEN 'Adult'
        WHEN CustomerAge BETWEEN 35 AND 49 THEN 'Middle Age'
        WHEN CustomerAge >= 50 THEN 'Senior'
        ELSE 'Unknown'
    END,
    customer_segment = CASE
        WHEN LoyaltyPoints >= 8000 THEN 'Premium'
        WHEN LoyaltyPoints BETWEEN 5000 AND 7999 THEN 'Gold'
        WHEN LoyaltyPoints BETWEEN 2000 AND 4999 THEN 'Silver'
        ELSE 'Bronze'
    END;
```

### **9. Assign Data Quality Scores**
```sql
UPDATE silver_transactions
SET data_quality_score = (
    CASE WHEN CustomerID != -1 THEN 20 ELSE 5 END +
    CASE WHEN TransactionAmount > 0 THEN 20 ELSE 0 END +
    CASE WHEN ProductName != 'Uncategorized' THEN 20 ELSE 5 END +
    CASE WHEN TransactionDate != '1900-01-01' THEN 20 ELSE 5 END +
    CASE WHEN PaymentMethod != 'Unknown' THEN 20 ELSE 5 END
) / 100;
```

### **10. Assign Data Issue Flags**
```sql
UPDATE silver_transactions
SET data_issue_flag =
    CASE
        WHEN CustomerID = -1 THEN 'Missing Customer'
        WHEN TransactionDate = '1900-01-01' THEN 'Missing Date'
        WHEN ProductName = 'Uncategorized' THEN 'Uncategorized Product'
        WHEN PaymentMethod = 'Unknown' THEN 'Unknown Payment Method'
        ELSE 'Valid'
    END;
```

### **11. Validate Data Integrity**
```sql
SELECT data_issue_flag, COUNT(*) AS total_records
FROM silver_transactions
GROUP BY data_issue_flag
ORDER BY total_records DESC;
```

### **12. Missing Data Percentage Calculation**
```sql
SELECT
    SUM(CASE WHEN CustomerID = -1 THEN 1 ELSE 0 END) AS missing_customerID,
    ROUND((SUM(CASE WHEN CustomerID = -1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS missing_customerID_pct,
    
    SUM(CASE WHEN TransactionDate = '1900-01-01' THEN 1 ELSE 0 END) AS missing_dates,
    ROUND((SUM(CASE WHEN TransactionDate = '1900-01-01' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS missing_dates_pct,
    
    SUM(CASE WHEN ProductName = 'Uncategorized' THEN 1 ELSE 0 END) AS uncategorized_products,
    ROUND((SUM(CASE WHEN ProductName = 'Uncategorized' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS uncategorized_products_pct,
    
    SUM(CASE WHEN PaymentMethod = 'Unknown' THEN 1 ELSE 0 END) AS unknown_payments,
    ROUND((SUM(CASE WHEN PaymentMethod = 'Unknown' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS unknown_payments_pct
FROM silver_transactions;
```

---
---

## **Project Structure**

```
assessment-medallion-sql
├── README.md               # Project Documentation
├── sql-scripts
    ├── bronze_layer.sql    # Raw Data Queries & Cleaning Scripts
    ├── silver_layer.sql    # Cleansed Data Queries (Future Work)
    ├── gold_layer.sql      # Business Insights Queries (Future Work)


```
--- 
## Conclusion
This Silver Layer ensures that transaction data is **clean, enriched, and structured** before moving into the Gold Layer for final aggregation and reporting. The transformation pipeline handles missing values, assigns data quality scores, and ensures consistency across the dataset.



## 🛠 **Contributing**
1. Fork this repository.
2. Create a new branch for your feature.
3. Submit a pull request.

---



---


