-- Step 1: Create silver_transactions table
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

-- Step 2: Insert data from bronze to silver
INSERT INTO silver_transactions
SELECT 
    TransactionID,
    CustomerID,
    TransactionDate,
    TransactionAmount,
    PaymentMethod,
    Quantity,
    DiscountPercent,
    City,
    StoreType,
    CustomerAge,
    CustomerGender,
    LoyaltyPoints,
    ProductName,
    Region,
    Returned,
    FeedbackScore,
    ShippingCost,
    DeliveryTimeDays,
    IsPromotional
FROM bronze_transactions;


-- Verify the data load
SELECT COUNT(*) as total_records FROM silver_transactions;
SELECT COUNT(*) as total_records FROM bronze_transactions;

-- Step 3: Add new columns for silver layer enrichment
ALTER TABLE silver_transactions
ADD COLUMN transaction_year INT,
ADD COLUMN transaction_month INT,
ADD COLUMN transaction_quarter INT,
ADD COLUMN total_sale_value DECIMAL(10,2),
ADD COLUMN discount_amount DECIMAL(10,2),
ADD COLUMN net_revenue DECIMAL(10,2),
ADD COLUMN customer_segment VARCHAR(50),
ADD COLUMN age_group VARCHAR(50),
ADD COLUMN is_weekend BOOLEAN,
ADD COLUMN day_of_week VARCHAR(20),
ADD COLUMN transaction_status VARCHAR(50),
ADD COLUMN data_quality_score DECIMAL(5,2);

SELECT * FROM silver_transactions;

-- Step 4: Update the new columns with transformed data
-- Time-based transformations
UPDATE silver_transactions
SET 
    transaction_year = YEAR(TransactionDate),
    transaction_month = MONTH(TransactionDate),
    transaction_quarter = QUARTER(TransactionDate),
    day_of_week = DAYNAME(TransactionDate),
    is_weekend = CASE WHEN DAYOFWEEK(TransactionDate) IN (1, 7) THEN TRUE ELSE FALSE END;

SELECT * FROM silver_transactions;


DESC silver_transactions;

ALTER TABLE silver_transactions 
MODIFY COLUMN discount_amount DECIMAL(12,4) NULL,
MODIFY COLUMN total_sale_value DECIMAL(12,4) NULL;


SELECT 
    MAX(TransactionAmount) AS MaxTransactionAmount, 
    MAX(DiscountPercent) AS MaxDiscountPercent 
FROM silver_transactions;

ALTER TABLE silver_transactions 
MODIFY COLUMN discount_amount DECIMAL(18,6) NULL,
MODIFY COLUMN total_sale_value DECIMAL(18,6) NULL;


-- Financial calculations
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

SELECT discount_amount, total_sale_value
FROM silver_transactions
WHERE discount_amount IS NULL OR total_sale_value IS NULL
LIMIT 10;


-- UPDATE silver_transactions SET net_revenue = total_sale_value - discount_amount; got error

SHOW COLUMNS FROM silver_transactions LIKE 'net_revenue';

SELECT MAX(total_sale_value - discount_amount) FROM silver_transactions;

ALTER TABLE silver_transactions MODIFY COLUMN net_revenue DECIMAL(18,6);

UPDATE silver_transactions SET net_revenue = total_sale_value - discount_amount;

SELECT * FROM silver_transactions;


SELECT DISTINCT CustomerAge, LoyaltyPoints 
FROM silver_transactions;

-- Customer segmentation
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


SELECT * FROM silver_transactions;

SELECT DISTINCT day_of_week 
FROM silver_transactions;


SELECT DISTINCT day_of_week
FROM silver_transactions
ORDER BY
  CASE
    day_of_week
    WHEN 'Monday' THEN 1
    WHEN 'Tuesday' THEN 2
    WHEN 'Wednesday' THEN 3
    WHEN 'Thursday' THEN 4
    WHEN 'Friday' THEN 5
    WHEN 'Saturday' THEN 6
    WHEN 'Sunday' THEN 7
  END;


SELECT * FROM silver_transactions;

SELECT DISTINCT Returned, DeliveryTimeDays 
FROM silver_transactions;

UPDATE silver_transactions
SET transaction_status = 
    CASE 
        WHEN Returned = 'Yes' THEN 'Returned'
        WHEN DeliveryTimeDays IS NULL THEN 'Processing'
        ELSE 'Completed'
    END;
    
SELECT * FROM silver_transactions;

-- Data quality scoring
UPDATE silver_transactions
SET data_quality_score = (
    CASE WHEN CustomerID IS NOT NULL THEN 20 ELSE 0 END +
    CASE WHEN TransactionAmount > 0 THEN 20 ELSE 0 END +
    CASE WHEN ProductName IS NOT NULL THEN 20 ELSE 0 END +
    CASE WHEN TransactionDate IS NOT NULL THEN 20 ELSE 0 END +
    CASE WHEN PaymentMethod IS NOT NULL THEN 20 ELSE 0 END
) / 100;

-- Step 5: Verify the transformations
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT CustomerID) as unique_customers,
    AVG(data_quality_score) as avg_quality_score,
    COUNT(DISTINCT customer_segment) as segment_count
FROM silver_transactions;

-- Sample data quality check
SELECT 
    customer_segment,
    COUNT(*) as segment_count,
    AVG(total_sale_value) as avg_sale_value,
    AVG(data_quality_score) as avg_quality_score
FROM silver_transactions
GROUP BY customer_segment
ORDER BY segment_count DESC;
