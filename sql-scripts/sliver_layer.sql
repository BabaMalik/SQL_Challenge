-- Step 1: Backup existing table
CREATE TABLE silver_transactions_backup AS 
SELECT * FROM silver_transactions;

-- Step 2: Drop and recreate silver_transactions table
-- Removed TRANSACTIONS schema reference as it wasn't consistently used
DROP TABLE IF EXISTS silver_transactions;

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
    LoyaltyPoints INT NULL,  -- Added NULL constraint for consistency
    ProductName VARCHAR(255) NULL,  -- Added NULL constraint for consistency
    Region VARCHAR(255) NULL,  -- Added NULL constraint for consistency
    Returned VARCHAR(255) NULL,  -- Added NULL constraint for consistency
    FeedbackScore INT NULL,
    ShippingCost DECIMAL(10,2) NULL,
    DeliveryTimeDays INT NULL,
    IsPromotional VARCHAR(255) NULL
);

-- Step 3: Insert data from bronze table
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

-- Step 4: Add new columns (moved before data population)
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

-- Step 5: Replace NULLs with meaningful defaults
-- Split into multiple updates for better performance and error handling
UPDATE silver_transactions
SET 
    CustomerID = COALESCE(CustomerID, -1),
    TransactionDate = COALESCE(TransactionDate, '1900-01-01'),
    PaymentMethod = COALESCE(PaymentMethod, 'Unknown'),
    StoreType = COALESCE(StoreType, 'General');

UPDATE silver_transactions
SET 
    CustomerAge = COALESCE(CustomerAge, 30),
    CustomerGender = COALESCE(CustomerGender, 'Unknown'),
    ProductName = COALESCE(ProductName, 'Uncategorized'),
    Region = COALESCE(Region, 'Unknown');

UPDATE silver_transactions
SET 
    TransactionAmount = COALESCE(TransactionAmount, 0),
    DiscountPercent = COALESCE(DiscountPercent, 0),
    LoyaltyPoints = COALESCE(LoyaltyPoints, 0),
    ShippingCost = COALESCE(ShippingCost, 0),
    DeliveryTimeDays = COALESCE(DeliveryTimeDays, 5),
    Quantity = COALESCE(Quantity, 1),  -- Added Quantity default
    FeedbackScore = COALESCE(FeedbackScore, 0),  -- Added FeedbackScore default
    Returned = COALESCE(Returned, 'No'),  -- Added Returned default
    IsPromotional = COALESCE(IsPromotional, 'No');  -- Added IsPromotional default

-- Step 6: Populate date-related columns
-- Added error handling for invalid dates
UPDATE silver_transactions
SET 
    transaction_year = CASE 
        WHEN TransactionDate = '1900-01-01' THEN NULL 
        ELSE YEAR(TransactionDate) 
    END,
    transaction_month = CASE 
        WHEN TransactionDate = '1900-01-01' THEN NULL 
        ELSE MONTH(TransactionDate) 
    END,
    transaction_quarter = CASE 
        WHEN TransactionDate = '1900-01-01' THEN NULL 
        ELSE QUARTER(TransactionDate) 
    END,
    day_of_week = CASE 
        WHEN TransactionDate = '1900-01-01' THEN NULL 
        ELSE DAYNAME(TransactionDate) 
    END,
    is_weekend = CASE 
        WHEN TransactionDate = '1900-01-01' THEN NULL 
        WHEN DAYOFWEEK(TransactionDate) IN (1, 7) THEN TRUE 
        ELSE FALSE 
    END;

-- Step 7: Calculate financial metrics
-- Added validation for negative values
UPDATE silver_transactions
SET 
    discount_amount = CASE 
        WHEN TransactionAmount >= 0 AND DiscountPercent >= 0 
        THEN ROUND(TransactionAmount * (DiscountPercent / 100), 2)
        ELSE 0 
    END;

UPDATE silver_transactions
SET 
    total_sale_value = CASE 
        WHEN TransactionAmount >= 0 AND ShippingCost >= 0 
        THEN TransactionAmount + ShippingCost
        ELSE TransactionAmount 
    END,
    net_revenue = CASE 
        WHEN (TransactionAmount + ShippingCost - discount_amount) >= 0 
        THEN TransactionAmount + ShippingCost - discount_amount
        ELSE 0 
    END;

-- Step 8: Update customer segmentation
UPDATE silver_transactions
SET 
    age_group = CASE 
        WHEN CustomerAge < 0 THEN 'Invalid Age'
        WHEN CustomerAge < 25 THEN 'Young Adult'
        WHEN CustomerAge BETWEEN 25 AND 34 THEN 'Adult'
        WHEN CustomerAge BETWEEN 35 AND 49 THEN 'Middle Age'
        WHEN CustomerAge >= 50 THEN 'Senior'
        ELSE 'Unknown'
    END,
    customer_segment = CASE 
        WHEN LoyaltyPoints < 0 THEN 'Invalid'
        WHEN LoyaltyPoints >= 8000 THEN 'Premium'
        WHEN LoyaltyPoints BETWEEN 5000 AND 7999 THEN 'Gold'
        WHEN LoyaltyPoints BETWEEN 2000 AND 4999 THEN 'Silver'
        ELSE 'Bronze'
    END;

-- Step 9: Set transaction status
UPDATE silver_transactions
SET transaction_status = 
    CASE 
        WHEN Returned = 'Yes' THEN 'Returned'
        WHEN DeliveryTimeDays < 0 THEN 'Invalid Delivery Days'
        WHEN DeliveryTimeDays <= 2 THEN 'Processing'
        WHEN DeliveryTimeDays > 12 THEN 'Delayed'
        ELSE 'Completed'
    END;

-- Step 10: Set data issue flags and quality scores
-- Step 10: Set data issue flags 
UPDATE silver_transactions
SET data_issue_flag = 
    CASE 
        WHEN CustomerID = -1 THEN 'Missing Customer'
        WHEN TransactionDate = '1900-01-01' THEN 'Missing Date'
        WHEN ProductName = 'Uncategorized' THEN 'Uncategorized Product'
        WHEN PaymentMethod = 'Unknown' THEN 'Unknown Payment Method'
        WHEN TransactionAmount < 0 THEN 'Invalid Amount'
        WHEN DeliveryTimeDays < 0 THEN 'Invalid Delivery Days'
        ELSE 'Valid'
    END;




-- Step 11: Calculate data quality score with additional checks
UPDATE silver_transactions
SET data_quality_score = (
    CASE WHEN CustomerID != -1 THEN 20 ELSE 5 END +
    CASE WHEN TransactionAmount >= 0 THEN 20 ELSE 0 END +
    CASE WHEN ProductName != 'Uncategorized' THEN 20 ELSE 5 END +
    CASE WHEN TransactionDate != '1900-01-01' THEN 20 ELSE 5 END +
    CASE WHEN PaymentMethod != 'Unknown' THEN 20 ELSE 5 END +
    CASE WHEN DeliveryTimeDays >= 0 THEN 0 ELSE -10 END  -- Penalty for invalid delivery days
) / 100;

-- Step 12: Final validation queries
SELECT 
    data_quality_score, 
    COUNT(*) AS total_records,
    ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM silver_transactions), 2) AS percentage
FROM silver_transactions
GROUP BY data_quality_score
ORDER BY data_quality_score DESC;

-- Calculate percentage distribution of data issues
SELECT 
    data_issue_flag,
    COUNT(*) AS total_records,
    ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM silver_transactions), 2) AS percentage
FROM silver_transactions
GROUP BY data_issue_flag
ORDER BY percentage DESC;
