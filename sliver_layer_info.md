# 🥈 Silver Layer - Data Transformation & Enrichment

## 📌 Overview

The **Silver Layer** is the **cleaned, structured, and transformed** version of the raw data ingested into the **Bronze Layer**. This layer refines, standardizes, and enhances data to ensure **data integrity, consistency, and usability** for analytics and reporting.

In this layer, we focus on:

✅ **Data Type Standardization**  
✅ **Data Enrichment (Feature Engineering)**  
✅ **Handling Missing & Inconsistent Data**  
✅ **Financial & Customer Segmentation Transformations**  
✅ **Data Quality Checks**  

---

## ⚙️ Key Steps in Silver Layer Processing

### 🔹 **Step 1: Creating the Silver Table**

Before transforming the data, we first create a **silver_transactions** table with proper data types.  

**Why?**  
In the **Bronze Layer**, many fields were stored as `TEXT` or `VARCHAR(255)`, which affected data accuracy and performance. This step ensures that the columns have **appropriate data types**.

```sql
CREATE TABLE silver_transactions (
    TransactionID INT PRIMARY KEY,
    CustomerID INT NULL,
    TransactionDate DATETIME NULL,
    TransactionAmount DECIMAL(10,2) NULL,
    PaymentMethod VARCHAR(255) NULL,
    CustomerAge INT NULL,
    LoyaltyPoints INT,
    ProductName VARCHAR(255),
    Region VARCHAR(255),
    StoreType VARCHAR(255) NULL,
    DiscountPercent DECIMAL(5,2) NULL,
    ShippingCost DECIMAL(10,2) NULL,
    DeliveryTimeDays INT,
    Returned VARCHAR(255),
    FeedbackScore INT,
    IsPromotional VARCHAR(255)
);
```
This schema ensures:
- **Correct numeric formats** for `TransactionAmount`, `DiscountPercent`, `ShippingCost`.
- **NULL handling** for optional fields like `CustomerAge` and `LoyaltyPoints`.
- **Categorical fields** (`Returned`, `IsPromotional`, `StoreType`) remain as `VARCHAR` for easy transformations later.

---

### 🔹 **Step 2: Inserting Data from Bronze Layer**

We move data from **bronze_transactions** to **silver_transactions** while keeping the structure intact.

```sql
INSERT INTO silver_transactions
SELECT * FROM bronze_transactions;
```

**Why?**  
This allows us to work on a **separate, cleaned version** without modifying the raw ingested data.

---

### 🔹 **Step 3: Adding New Columns for Enrichment**

We add derived columns for **better analytics**:

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
ADD COLUMN data_quality_score DECIMAL(5,2);
```

**Why?**
- **Time-based features** (`transaction_year`, `transaction_month`, `transaction_quarter`, `day_of_week`, `is_weekend`) help analyze trends.
- **Financial Metrics** (`total_sale_value`, `discount_amount`, `net_revenue`) enable business performance tracking.
- **Customer Segmentation** (`customer_segment`, `age_group`) enhances personalization.
- **Data Quality Scoring** (`data_quality_score`) helps identify incomplete or inaccurate records.

---

### 🔹 **Step 4: Time-Based Feature Engineering**

Extracting **year, month, quarter, and weekday** from `TransactionDate`.

```sql
UPDATE silver_transactions
SET 
    transaction_year = YEAR(TransactionDate),
    transaction_month = MONTH(TransactionDate),
    transaction_quarter = QUARTER(TransactionDate),
    day_of_week = DAYNAME(TransactionDate),
    is_weekend = CASE WHEN DAYOFWEEK(TransactionDate) IN (1, 7) THEN TRUE ELSE FALSE END;
```

**Why?**
- Helps in **seasonal analysis**, **trends detection**, and **weekend vs weekday comparisons**.
- Supports **time-series modeling** for **future sales predictions**.

---

### 🔹 **Step 5: Financial Calculations**

Calculating **discount amount**, **total sale value**, and **net revenue**.

```sql
UPDATE silver_transactions
SET 
    discount_amount = CASE 
        WHEN DiscountPercent IS NOT NULL THEN (TransactionAmount * (DiscountPercent / 100))
        ELSE 0 
    END,
    total_sale_value = CASE 
        WHEN ShippingCost IS NOT NULL THEN TransactionAmount + ShippingCost
        ELSE TransactionAmount 
    END;
```

Then, we calculate **net revenue**:

```sql
UPDATE silver_transactions 
SET net_revenue = total_sale_value - discount_amount;
```

**Why?**
- **Discount Calculation** ensures correct sales impact analysis.
- **Total Sale Value** includes shipping costs for accurate revenue tracking.
- **Net Revenue Calculation** helps in profitability analysis.

---

### 🔹 **Step 6: Customer Segmentation & Age Grouping**

We categorize **customers based on age** and **loyalty points**.

```sql
UPDATE silver_transactions
SET 
    age_group = CASE 
        WHEN CustomerAge IS NULL THEN 'Unknown'
        WHEN CustomerAge < 25 THEN 'Young Adult'
        WHEN CustomerAge BETWEEN 25 AND 34 THEN 'Adult'
        WHEN CustomerAge BETWEEN 35 AND 49 THEN 'Middle Age'
        WHEN CustomerAge >= 50 THEN 'Senior'
        ELSE 'Unknown'
    END,
    customer_segment = CASE 
        WHEN LoyaltyPoints IS NULL THEN 'No Loyalty'
        WHEN LoyaltyPoints > 1000 THEN 'Premium'
        WHEN LoyaltyPoints BETWEEN 500 AND 1000 THEN 'Gold'
        WHEN LoyaltyPoints BETWEEN 100 AND 499 THEN 'Silver'
        ELSE 'Bronze'
    END;
```

**Why?**
- Helps in **targeted marketing strategies**.
- Enables **customer retention analysis**.
- Supports **personalized offers and promotions**.

---

### 🔹 **Step 7: Transaction Status Classification**

Categorizing transactions as **Completed, Processing, or Returned**.

```sql
UPDATE silver_transactions
SET transaction_status = 
    CASE 
        WHEN Returned = 'Yes' THEN 'Returned'
        WHEN DeliveryTimeDays IS NULL THEN 'Processing'
        ELSE 'Completed'
    END;
```

**Why?**
- Helps in **order tracking**.
- Improves **customer service responses**.
- Identifies potential **logistical inefficiencies**.

---

### 🔹 **Step 8: Data Quality Scoring**

Assigning a **data quality score** based on completeness.

```sql
UPDATE silver_transactions
SET data_quality_score = (
    CASE WHEN CustomerID IS NOT NULL THEN 20 ELSE 0 END +
    CASE WHEN TransactionAmount > 0 THEN 20 ELSE 0 END +
    CASE WHEN ProductName IS NOT NULL THEN 20 ELSE 0 END +
    CASE WHEN TransactionDate IS NOT NULL THEN 20 ELSE 0 END +
    CASE WHEN PaymentMethod IS NOT NULL THEN 20 ELSE 0 END
) / 100;
```

**Why?**
- Helps **identify incomplete records**.
- Ensures **data reliability for analytics**.
- Enables **data cleansing decisions**.

---

## 📊 **Final Validation & Insights**

Checking **data transformation success**:

```sql
SELECT 
    COUNT(*) AS total_records,
    COUNT(DISTINCT CustomerID) AS unique_customers,
    AVG(data_quality_score) AS avg_quality_score,
    COUNT(DISTINCT customer_segment) AS segment_count
FROM silver_transactions;
```

Analyzing **customer segments**:

```sql
SELECT 
    customer_segment,
    COUNT(*) AS segment_count,
    AVG(total_sale_value) AS avg_sale_value,
    AVG(data_quality_score) AS avg_quality_score
FROM silver_transactions
GROUP BY customer_segment
ORDER BY segment_count DESC;
```

---

## 🏆 **Summary**

In the **Silver Layer**, we successfully:

✔️ **Transformed raw data into structured format**  
✔️ **Enriched the dataset with new features**  
✔️ **Handled missing & inconsistent values**  
✔️ **Implemented customer segmentation & financial analysis**  
✔️ **Ensured data quality & completeness scoring**  

This **cleaned & structured data** is now ready for **Gold Layer** processing, where we will generate **business intelligence insights, aggregations, and reporting dashboards**. 🚀

---

Would you like any additional details? 🤔
