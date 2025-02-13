DROP TABLE IF EXISTS gold_transactions;
CREATE TABLE gold_transactions (
    CustomerID INT,
    CustomerLifetimeValue DECIMAL(18,2),
    TotalTransactions INT,
    TotalSpent DECIMAL(18,2),
    AvgTransactionValue DECIMAL(18,2),
    ReturnRate DECIMAL(5,2),
    MostPurchasedProduct VARCHAR(100),
    PreferredPaymentMethod VARCHAR(50),
    CustomerSegment VARCHAR(50),
    Region VARCHAR(50),
    MonthlyTrend TEXT,
    YearOverYearGrowth DECIMAL(5,2)
);


DROP TEMPORARY TABLE IF EXISTS temp_gold_metrics;
CREATE TEMPORARY TABLE temp_gold_metrics AS
SELECT 
    CustomerID,
    COUNT(TransactionID) AS TotalTransactions,
    SUM(TransactionAmount) AS TotalSpent,
    ROUND(AVG(TransactionAmount), 2) AS AvgTransactionValue,
    ROUND(SUM(TransactionAmount) / NULLIF(COUNT(DISTINCT YEAR(TransactionDate)), 1), 2) AS CustomerLifetimeValue,
    ROUND(SUM(CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END) / COUNT(TransactionID) * 100, 2) AS ReturnRate,
    MAX(customer_segment) AS CustomerSegment
FROM silver_transactions
GROUP BY CustomerID;



