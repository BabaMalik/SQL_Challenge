

# 🏆 SQL Analysis using Medallion Architecture

## 📌 Overview
This project implements **SQL-based ETL workflows** using the **Medallion Architecture** in **MySQL Workbench**.  
The goal is to **ingest, clean, and transform raw transactional data** into **structured, analytics-ready data**.  

### **Medallion Architecture - 3 Layers**
- 🟤 **Bronze Layer** → Raw data ingestion (**This README focuses on this layer**)
- ⚪ **Silver Layer** → Cleansed and processed data (*Future work*)
- 🟡 **Gold Layer** → Business insights and reporting (*Future work*)

---

## 🛠️ **Step 1: Loading Data into MySQL Workbench**
I started by **loading a CSV file** containing **transactional data** into MySQL Workbench.  
This dataset contains customer transactions, product purchases, and metadata.

### **📌 Dataset Schema (Raw Data)**
| Field             | Type          | Description |
|------------------|--------------|-------------|
| `TransactionID`   | INT          | Unique transaction identifier |
| `CustomerID`      | INT          | Unique customer identifier |
| `TransactionDate` | DATE         | Date of the transaction |
| `TransactionAmount` | DOUBLE      | Total amount of the transaction |
| `PaymentMethod`   | VARCHAR(50)  | Mode of payment (Credit Card, PayPal, etc.) |
| `Quantity`        | INT          | Number of items purchased |
| `DiscountPercent` | DOUBLE       | Discount applied to the transaction |
| `City`           | VARCHAR(100) | Customer’s city |
| `StoreType`       | VARCHAR(50)  | Type of store (Online, Physical) |
| `CustomerAge`     | INT          | Age of the customer |
| `CustomerGender`  | VARCHAR(10)  | Gender of the customer |
| `LoyaltyPoints`   | INT          | Customer loyalty points |
| `ProductName`     | VARCHAR(100) | Name of the purchased product |
| `Region`         | VARCHAR(100) | Customer’s region |
| `Returned`        | VARCHAR(10)  | Whether the product was returned (Yes/No) |
| `FeedbackScore`   | INT          | Customer feedback score |
| `ShippingCost`    | DOUBLE       | Cost of shipping the product |
| `DeliveryTimeDays` | INT         | Days taken for delivery |
| `IsPromotional`   | VARCHAR(10)  | Whether the purchase was part of a promotion |

---

## 🟤 **Step 2: Creating the Bronze Layer (Raw Data Ingestion)**
The **Bronze Layer** is where we store raw data without modifications. This is the first step in the Medallion Architecture.

### **📜 Creating the `bronze_transactions` Table**
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

---

## 🔄 **Step 3: Loading Data into the Bronze Layer**
I copied all raw data from the `assessment_dataset` into the newly created `bronze_transactions` table.

```sql
INSERT INTO TRANSACTIONS.bronze_transactions
SELECT * FROM TRANSACTIONS.assessment_dataset;
```

However, some **data cleaning issues** were identified:
- **Dates were in an incorrect format** (needed conversion)
- **Empty or invalid values in CustomerID and TransactionDate** (needed fixing)
- **Some fields contained non-numeric values** where numbers were expected

---

## 🔍 **Step 4: Data Cleaning in the Bronze Layer**
### **✅ Fixing Date Format**
The `TransactionDate` column had inconsistent formats. I converted it to a **standard DATETIME format**:
```sql
UPDATE TRANSACTIONS.assessment_dataset
SET TransactionDate = STR_TO_DATE(TransactionDate, '%m/%d/%Y %H:%i')
WHERE TransactionDate IS NOT NULL AND TransactionDate <> '';
```

### **✅ Handling Missing CustomerIDs**
Some `CustomerID` values were empty or contained non-numeric characters. I set them to `NULL`:
```sql
UPDATE TRANSACTIONS.assessment_dataset
SET CustomerID = NULL
WHERE CustomerID = '' OR CustomerID REGEXP '[^0-9]';
```

### **✅ Checking for Incorrect Time Zone Settings**
To ensure date values were correctly interpreted, I checked and adjusted the time zone:
```sql
SELECT @@global.time_zone, @@session.time_zone;
SET time_zone = '+00:00';
```

### **✅ Validating Date Format in Bronze Layer**
To ensure `TransactionDate` is correctly formatted as `YYYY-MM-DD HH:MM:SS`, I ran:
```sql
SELECT TransactionDate 
FROM TRANSACTIONS.assessment_dataset 
WHERE TransactionDate NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$';
```

---

## ✅ **Final Steps: Ensuring Data Integrity**
After fixing issues, I inserted the cleaned data into `bronze_transactions`:

```sql
INSERT INTO TRANSACTIONS.bronze_transactions
SELECT * FROM TRANSACTIONS.assessment_dataset;
```

To confirm everything worked as expected:
```sql
SELECT * FROM TRANSACTIONS.bronze_transactions;
```

---

## 📂 **Project Structure**
```
📂 assessment-medallion-sql/
├── 📜 README.md                  # Project Documentation
├── 📂 sql-scripts/
│   ├── 🟤 bronze_layer.sql        # Raw data ingestion queries
│   ├── ⚪ silver_layer.sql         # Cleansed & transformed data queries (*Future Work*)
│   ├── 🟡 gold_layer.sql          # Business insights & reporting queries (*Future Work*)
│   ├── 📜 exploratory_analysis.sql  # Ad-hoc queries for data exploration
├── 📂 documentation/
│   ├── 📜 design_decisions.md     # Why Medallion Architecture?
│   ├── 📜 best_practices.md       # SQL Optimization & Indexing Strategies
```

---

## 🚀 **Next Steps**
Now that the **Bronze Layer** is set up, the next steps will be:
1. **Transforming data into the Silver Layer** (cleaning, deduplication, and structuring)
2. **Building the Gold Layer** (aggregations, insights, and business reporting)
3. **Optimizing queries for performance** (indexing, partitioning, and caching)

---

## 🏁 **Conclusion**
This project successfully implemented **the first phase of Medallion Architecture** by ingesting raw transactional data into the **Bronze Layer**. The next step is to process and clean this data for the **Silver Layer**.  

This approach ensures **scalability, data integrity, and efficiency** in analytics workflows! 🔥  

---

## 💡 **Want to Contribute?**
If you have suggestions for improvements or optimizations, feel free to open an issue or a pull request! 🚀  

---

This README is **structured, engaging, and professional** while keeping it **easy to read**. Let me know if you need modifications! 🔥
