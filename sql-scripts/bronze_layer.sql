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
---- INSERT INTO TRANSACTIONS.bronze_transactions
SELECT * FROM TRANSACTIONS.assessment_dataset;


INSERT INTO TRANSACTIONS.bronze_transactions
SELECT * FROM TRANSACTIONS.assessment_dataset;

---- Fixing TransactionDate format
UPDATE TRANSACTIONS.assessment_dataset
SET TransactionDate = STR_TO_DATE(TransactionDate, '%m/%d/%Y %H:%i')
WHERE TransactionDate IS NOT NULL AND TransactionDate <> '';

---- Setting empty CustomerID values to NULL

UPDATE TRANSACTIONS.assessment_dataset
SET CustomerID = NULL
WHERE CustomerID = '' OR CustomerID REGEXP '[^0-9]';


------ Checking for Incorrect Date Format

SELECT TransactionDate 
FROM TRANSACTIONS.assessment_dataset 
WHERE TransactionDate NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$';


--Final Data Load into Bronze Layer

INSERT INTO TRANSACTIONS.bronze_transactions
SELECT * FROM TRANSACTIONS.assessment_dataset;


----- Confirming Data is Loaded Correctly
SELECT * FROM TRANSACTIONS.bronze_transactions;
