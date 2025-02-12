# 🏆 SQL Analysis using Medallion Architecture

## 📌 Overview
This repository contains SQL scripts implementing the **Medallion Architecture (Bronze, Silver, Gold layers)** for structured data processing and analytics.

### **What is Medallion Architecture?**
The Medallion Architecture is a data engineering design pattern used to **organize data into three layers**:
- 🟤 **Bronze Layer**: Raw data ingestion (this repository focuses on this layer so far)
- ⚪ **Silver Layer**: Cleaned and processed data
- 🟡 **Gold Layer**: Business insights and reporting

This repository focuses on the **Bronze Layer**, where raw data is ingested and minimally processed.

---

## 🏗 Bronze Layer: Raw Data Ingestion
### **Objective**
- Load raw **CSV data** into MySQL Workbench.
- Store data in the **Bronze Layer** without transformation (except for minor cleaning).
- Ensure raw data is accessible for further processing in the Silver Layer.

### **Steps Performed**
#### **1️⃣ Loading Data into MySQL**
- The CSV file containing transactional data was loaded into MySQL Workbench.
- The dataset was stored in the `TRANSACTIONS.assessment_dataset` table.

#### **2️⃣ Creating the Bronze Table**
To store raw data, we created the `bronze_transactions` table:

```sql
CREATE TABLE TRANSACTIONS.bronze_transactions (
    TransactionID INT,
    CustomerID INT,
    TransactionDate DATE,
    TransactionAmount DOUBLE,
    PaymentMethod VARCHAR(50),
    Quantity INT,
    DiscountPercent DOUBLE,
    City VARCHAR(100),
    StoreType VARCHAR(50),
    CustomerAge INT,
    CustomerGender VARCHAR(10),
    LoyaltyPoints INT,
    ProductName VARCHAR(100),
    Region VARCHAR(100),
    Returned VARCHAR(10),
    FeedbackScore INT,
    ShippingCost DOUBLE,
    DeliveryTimeDays INT,
    IsPromotional VARCHAR(10)
);
```

#### **3️⃣ Ingesting Data into Bronze Layer**
We inserted the raw data from `assessment_dataset` into `bronze_transactions`.

```sql
INSERT INTO TRANSACTIONS.bronze_transactions
SELECT * FROM TRANSACTIONS.assessment_dataset;
```

#### **4️⃣ Data Cleaning & Handling Issues**
We identified and fixed common data issues:

- **Fixing `TransactionDate` format:**
  ```sql
  UPDATE TRANSACTIONS.assessment_dataset
  SET TransactionDate = STR_TO_DATE(TransactionDate, '%m/%d/%Y %H:%i')
  WHERE TransactionDate IS NOT NULL AND TransactionDate <> '';
  ```

- **Handling missing `CustomerID` values:**
  ```sql
  UPDATE TRANSACTIONS.assessment_dataset
  SET CustomerID = NULL
  WHERE CustomerID = '' OR CustomerID REGEXP '[^0-9]';
  ```

- **Checking incorrect date formats:**
  ```sql
  SELECT TransactionDate
  FROM TRANSACTIONS.assessment_dataset
  WHERE TransactionDate NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$';
  ```

#### **5️⃣ Validating the Data**
After cleaning, we verified that data was correctly inserted into the Bronze Layer:
```sql
SELECT * FROM TRANSACTIONS.bronze_transactions;
```

---

## 📂 Project Structure
📁 **assessment-medallion-sql**
```
├── 📜 README.md   --> (Project Documentation)
├── 📁 sql-scripts
│   ├── 🟤 bronze_layer.sql   --> (Raw Data Queries & Cleaning Scripts)
│   ├── ⚪ silver_layer.sql   --> (Cleansed Data Queries - Future Work)
│   ├── 🟡 gold_layer.sql   --> (Business Insights Queries - Future Work)
│
├── 📁 documentation
│   ├── 📜 design_decisions.md   --> (Why Medallion Architecture?)
│   ├── 📜 best_practices.md   --> (SQL Optimization & Indexing)
```

---

## 📌 Next Steps
✅ **Bronze Layer** - ✅ Completed 🚀  
🟩 **Silver Layer** - To be implemented (data transformation, deduplication, validation)  
🟨 **Gold Layer** - Future work (business insights, dashboards, aggregations)  

🔹 **For full SQL scripts, check [`sql-scripts/bronze_layer.sql`](sql-scripts/bronze_layer.sql)**

---

## 👨‍💻 Author
🚀 **Baba Malik Hussain** - Passionate about Data Engineering & Medallion Architecture.

📧 Reach out on LinkedIn / GitHub for any discussions!


