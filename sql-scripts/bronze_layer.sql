
CREATE TABLE bronze_transactions (
    TransactionID INT PRIMARY KEY,
    CustomerID INT,
    TransactionDate DATE,
    TransactionAmount DECIMAL(10,2),
    PaymentMethod VARCHAR(50),
    Quantity INT,
    DiscountPercent DECIMAL(5,2),
    City VARCHAR(100),
    StoreType VARCHAR(50),
    CustomerAge INT,
    CustomerGender VARCHAR(10),
    LoyaltyPoints INT,
    ProductName VARCHAR(100),
    Region VARCHAR(100),
    Returned VARCHAR(10),
    FeedbackScore INT,
    ShippingCost DECIMAL(10,2),
    DeliveryTimeDays INT,
    IsPromotional BOOLEAN
);


--- Checking first 10 rows
SELECT * FROM bronze_transactions LIMIT 10;

--- Count the Total Rows
SELECT COUNT(*) AS total_records FROM bronze_transactions;

