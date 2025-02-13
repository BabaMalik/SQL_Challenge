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


-- 2. Product Performance Metrics
CREATE TABLE gold_product_performance AS
SELECT 
    ProductName,
    COUNT(DISTINCT TransactionID) as total_sales,
    SUM(Quantity) as total_quantity_sold,
    SUM(total_sale_value) as total_revenue,
    AVG(DiscountPercent) as avg_discount,
    SUM(CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END) as return_count,
    (SUM(CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100 as return_rate,
    AVG(FeedbackScore) as avg_feedback_score,
    COUNT(DISTINCT CustomerID) as unique_customers
FROM silver_transactions
GROUP BY ProductName;

-- 3. Store Performance Dashboard
CREATE TABLE gold_store_performance AS
SELECT 
    StoreType,
    Region,
    City,
    COUNT(DISTINCT TransactionID) as total_transactions,
    COUNT(DISTINCT CustomerID) as unique_customers,
    SUM(total_sale_value) as total_revenue,
    SUM(net_revenue) as net_revenue,
    AVG(total_sale_value) as avg_transaction_value,
    SUM(Quantity) as total_items_sold,
    AVG(FeedbackScore) as avg_feedback_score,
    SUM(CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END) as total_returns,
    AVG(DeliveryTimeDays) as avg_delivery_time
FROM silver_transactions
GROUP BY StoreType, Region, City;





