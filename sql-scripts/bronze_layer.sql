DROP TABLE IF EXISTS TRANSACTIONS.bronze_transactions;

CREATE TABLE bronze_transactions (
    TransactionID INT PRIMARY KEY,
    CustomerID TEXT NULL,
    TransactionDate VARCHAR(255),
    TransactionAmount TEXT NULL,
    PaymentMethod VARCHAR(255) NULL,
    Quantity INT NULL,
    DiscountPercent TEXT NULL,
    City VARCHAR(255) NULL,
    StoreType VARCHAR(255) NULL,
    CustomerAge TEXT NULL,
    CustomerGender VARCHAR(255) NULL,
    LoyaltyPoints INT,
    ProductName VARCHAR(255),
    Region VARCHAR(255),
    Returned VARCHAR(255),
    FeedbackScore INT,
    ShippingCost TEXT NULL,
    DeliveryTimeDays INT,
    IsPromotional VARCHAR(255)
);


select * from TRANSACTIONS.bronze_transactions;


ALTER TABLE bronze_transactions ADD COLUMN TransactionDate_new DATETIME NULL;

UPDATE bronze_transactions
SET TransactionDate = NULL
WHERE TransactionDate = '';

UPDATE bronze_transactions
SET TransactionDate_new = STR_TO_DATE(TransactionDate, '%m/%d/%Y %H:%i')
WHERE TransactionDate IS NOT NULL;

ALTER TABLE bronze_transactions DROP COLUMN TransactionDate;
ALTER TABLE bronze_transactions CHANGE COLUMN TransactionDate_new TransactionDate DATETIME NULL;

SELECT TransactionDate FROM bronze_transactions LIMIT 10 offset 50000;


SELECT CustomerID FROM bronze_transactions WHERE CustomerID = '';

UPDATE bronze_transactions
SET CustomerID = NULL
WHERE CustomerID = '';

SELECT CustomerID FROM bronze_transactions WHERE CustomerID IS NULL;

ALTER TABLE bronze_transactions
MODIFY COLUMN CustomerID INT NULL,
MODIFY COLUMN TransactionAmount DECIMAL(10,2) NULL,
MODIFY COLUMN DiscountPercent DECIMAL(5,2) NULL,
MODIFY COLUMN CustomerAge INT NULL,
MODIFY COLUMN ShippingCost DECIMAL(10,2) NULL; -- When I run this sql code i got the error so i check the data again

SELECT CustomerAge FROM bronze_transactions WHERE CustomerAge = '';

UPDATE bronze_transactions SET CustomerAge = NULL WHERE CustomerAge = '';

SELECT CustomerAge FROM bronze_transactions WHERE CustomerAge IS NULL;

ALTER TABLE bronze_transactions
MODIFY COLUMN CustomerID INT NULL,
MODIFY COLUMN TransactionAmount DECIMAL(10,2) NULL,
MODIFY COLUMN DiscountPercent DECIMAL(5,2) NULL,
MODIFY COLUMN CustomerAge INT NULL,
MODIFY COLUMN ShippingCost DECIMAL(10,2) NULL;


select * from TRANSACTIONS.bronze_transactions;

SELECT CustomerID, TransactionDate,PaymentMethod,StoreType,CustomerAge,CustomerGender,ProductName,Region    FROM bronze_transactions WHERE CustomerAge IS NULL;

SELECT ProductName FROM bronze_transactions WHERE ProductName='';

UPDATE bronze_transactions SET ProductName = NULL WHERE ProductName= '';
UPDATE bronze_transactions SET PaymentMethod = NULL WHERE PaymentMethod = '';
UPDATE bronze_transactions SET StoreType = NULL WHERE StoreType = '';
UPDATE bronze_transactions SET CustomerGender = NULL WHERE CustomerGender = '';
UPDATE bronze_transactions SET Region = NULL WHERE Region = '';

SELECT 
    PaymentMethod, StoreType, CustomerGender, Region
FROM bronze_transactions
WHERE PaymentMethod IS NULL
   OR StoreType IS NULL
   OR CustomerGender IS NULL
   OR Region IS NULL;



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




SELECT 
    'TransactionID' AS ColumnName, ROUND((SUM(CASE WHEN TransactionID IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS NullPercentage
FROM bronze_transactions
UNION ALL
SELECT 
    'CustomerID', ROUND((SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions
UNION ALL
SELECT 
    'TransactionDate', ROUND((SUM(CASE WHEN TransactionDate IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions
UNION ALL
SELECT 
    'TransactionAmount', ROUND((SUM(CASE WHEN TransactionAmount IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions
UNION ALL
SELECT 
    'PaymentMethod', ROUND((SUM(CASE WHEN PaymentMethod IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions
UNION ALL
SELECT 
    'Quantity', ROUND((SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions
UNION ALL
SELECT 
    'DiscountPercent', ROUND((SUM(CASE WHEN DiscountPercent IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions
UNION ALL
SELECT 
    'City', ROUND((SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions
UNION ALL
SELECT 
    'StoreType', ROUND((SUM(CASE WHEN StoreType IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions
UNION ALL
SELECT 
    'CustomerAge', ROUND((SUM(CASE WHEN CustomerAge IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions
UNION ALL
SELECT 
    'CustomerGender', ROUND((SUM(CASE WHEN CustomerGender IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions
UNION ALL
SELECT 
    'LoyaltyPoints', ROUND((SUM(CASE WHEN LoyaltyPoints IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions
UNION ALL
SELECT 
    'ProductName', ROUND((SUM(CASE WHEN ProductName IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions
UNION ALL
SELECT 
    'Region', ROUND((SUM(CASE WHEN Region IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions
UNION ALL
SELECT 
    'Returned', ROUND((SUM(CASE WHEN Returned IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions
UNION ALL
SELECT 
    'FeedbackScore', ROUND((SUM(CASE WHEN FeedbackScore IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions
UNION ALL
SELECT 
    'ShippingCost', ROUND((SUM(CASE WHEN ShippingCost IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions
UNION ALL
SELECT 
    'DeliveryTimeDays', ROUND((SUM(CASE WHEN DeliveryTimeDays IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions
UNION ALL
SELECT 
    'IsPromotional', ROUND((SUM(CASE WHEN IsPromotional IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) 
FROM bronze_transactions;


