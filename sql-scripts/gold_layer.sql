-- QUERIES ARE NOT TESTED YET
-- 1. Customer Analytics Table
CREATE TABLE gold_customer_analytics AS
SELECT 
    CustomerID,
    MIN(TransactionDate) as first_purchase_date,
    MAX(TransactionDate) as last_purchase_date,
    COUNT(DISTINCT TransactionID) as total_transactions,
    SUM(total_sale_value) as total_spent,
    AVG(total_sale_value) as avg_transaction_value,
    SUM(Quantity) as total_items_purchased,
    MAX(customer_segment) as customer_segment,
    MAX(age_group) as age_group,
    MAX(CustomerGender) as gender,
    MAX(LoyaltyPoints) as loyalty_points,
    COUNT(DISTINCT ProductName) as unique_products_bought,
    SUM(CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END) as total_returns,
    AVG(FeedbackScore) as avg_feedback_score
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





