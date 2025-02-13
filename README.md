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

## **Bronze Layer Processing**

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

---

## **Project Structure**

```
assessment-medallion-sql
├── README.md               # Project Documentation
├── sql-scripts
│   ├── bronze_layer.sql    # Raw Data Queries & Cleaning Scripts
│   ├── silver_layer.sql    # Cleansed Data Queries (Future Work)
│   ├── gold_layer.sql      # Business Insights Queries (Future Work)
│
├── documentation
│   ├── design_decisions.md  # Why Medallion Architecture?
│   ├── best_practices.md    # SQL Optimization & Indexing
```

---

## **Next Steps (Silver Layer Processing)**
- **Deduplication:** Remove duplicate transaction records.
- **Handling Missing Data:** Impute or remove records with excessive NULL values.
- **Data Normalization:** Ensuring consistency in categorical values (e.g., `Region`, `PaymentMethod`).
- **Derived Columns:** Extracting additional insights like `Year`, `Month`, `DiscountCategory`.


