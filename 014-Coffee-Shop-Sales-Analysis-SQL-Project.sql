-- DISCLAIMER: The SQL analysis presented in this project is created solely for educational and practice purposes. The
-- dataset and results are fictional and do not reflect or represent the operations, financials, or performance of
-- any actual coffee shop, company, or brand. Any similarities to real businesses are purely coincidental.

USE coffeeshopsalesanalysis;

CREATE TABLE coffeesalesdata 
(
	transaction_id INT NOT NULL,
	transaction_date DATE NOT NULL,
	transaction_time TIME NOT NULL,
	transaction_qty INT NOT NULL,
	store_id INT NOT NULL, 
	store_location VARCHAR(50) NOT NULL,
	product_id INT NOT NULL,
	unit_price DECIMAL(8,2) NOT NULL, 
	product_category VARCHAR(50) NOT NULL,
	product_type VARCHAR(50) NOT NULL,
	product_detail VARCHAR(50) NOT NULL,
	PRIMARY KEY(transaction_id)
);


SET GLOBAL local_infile = 1;


LOAD DATA LOCAL INFILE 'C:/Users/billy/Desktop/DataSets/coffeesalesanalysis/Coffee Shop Sales.xlsx - Transactions.csv'
INTO TABLE  coffeesalesdata	
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- 1. Show all sales transactions that happened on a specific date (e.g., 2025-01-01).
-- 2. Find the total sales revenue (quantity × unit price) for each transaction.
-- 3. Get the top 10 most expensive products sold (by unit_price).
-- 4 List all transactions for a specific store (e.g., store_id = 3).
-- 5 Count how many transactions happened in each store_location.
-- 6 Find the total revenue per store.
-- 7 Get the average quantity per transaction for each product category.
-- 8 Show monthly sales trends (total revenue per month).
-- 9 Which product category generated the most revenue overall?
-- 10 Find the top 5 products by sales volume (sum of transaction_qty).
-- 11 Identify the best-selling product type per store.
-- 12 Compare weekend vs weekday sales to see when sales are higher.
-- 13 Find the peak sales hour of the day (using transaction_time).
-- 14 Calculate year-over-year growth in sales (if multiple years of data exist).
-- 15 Show the product with the highest profit contribution (assuming unit_price ≈ sales price).
-- 16 Which store has the highest average transaction value?
-- 17 What percentage of revenue comes from each product_category?
-- 18 Which products are low-performing (low quantity + low revenue)?
-- 19 How much revenue did each store generate during the holiday season (e.g., December)?
-- 20 Create a ranking of store locations by total revenue.



-- 1. Show all sales transactions that happened on a specific year (e.g., 2025-01-01).
SELECT *
FROM coffeesalesdata
WHERE YEAR(transaction_date) = 2023;

-- 2. Find the total sales revenue (quantity × unit price) for each transaction.
SELECT
	SUM(transaction_qty * unit_price) AS total_revenue
FROM coffeesalesdata;

-- 3. Get the top 10 most expensive products sold (by unit_price).
SELECT
	product_id,
	unit_price
FROM coffeesalesdata
GROUP BY 
	product_id,
    unit_price
ORDER BY unit_price DESC
LIMIT 10;

-- 4 List all transactions for a specific store (e.g., store_id = 3).
SELECT *
FROM coffeesalesdata
WHERE store_id = 3;

-- 5 Count how many transactions happened in each store_location.
SELECT
	store_id,
    COUNT(*) AS total_transactions
FROM coffeesalesdata
GROUP BY store_id
ORDER BY store_id;

-- 6 Find the total revenue per store.
SELECT
	store_id,
    SUM(transaction_qty * unit_price) AS total_revenue
FROM coffeesalesdata
GROUP BY store_id
ORDER BY store_id;

-- 7 Get the average quantity per transaction for each product category.
SELECT
	product_category,
	ROUND(AVG(transaction_qty),2) AS avg_transactionQty
FROM coffeesalesdata
GROUP BY product_category
ORDER BY avg_transactionQty DESC;

-- 8 Show monthly sales trends (total revenue per month).
SELECT
	YEAR(transaction_date) AS year_,
	MONTH(transaction_date) AS num_month,
    MONTHNAME(transaction_date) AS month_name,
    SUM(transaction_qty * unit_price) AS total_sales
FROM coffeesalesdata
GROUP BY 
	YEAR(transaction_date),
    MONTH(transaction_date),
    MONTHNAME(transaction_date)
ORDER BY num_month;

-- 9 Which product category generated the most revenue overall?
SELECT
	product_category,
    SUM(transaction_qty * unit_price) AS total_sales
FROM coffeesalesdata
GROUP BY product_category
ORDER BY total_sales DESC;

-- 10 Find the top 5 products by sales volume (sum of transaction_qty).
SELECT
	product_category,
    SUM(transaction_qty) AS total_qty
FROM coffeesalesdata
GROUP BY product_category
ORDER BY total_qty DESC;


-- 11 Identify the best-selling product type per store.
SELECT
	store_id,
    product_type,
    SUM(transaction_qty) AS total_qty
FROM coffeesalesdata
GROUP BY 
	store_id,
    product_type
ORDER BY 
	store_id,
    total_qty DESC;

-- 12 Compare weekend vs weekday sales to see when sales are higher.
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekend' 
        ELSE 'Weekday'
    END AS day_type,
    SUM(transaction_qty * unit_price) AS total_sales,
    COUNT(DISTINCT transaction_id) AS total_transactions
FROM coffeesalesdata
GROUP BY day_type
ORDER BY total_sales DESC;

-- 13 Find the peak sales hour of the day (using transaction_time).
SELECT 
    HOUR(transaction_time) AS sales_hour,
    SUM(transaction_qty * unit_price) AS total_sales,
    COUNT(DISTINCT transaction_id) AS total_transactions
FROM coffeesalesdata
GROUP BY sales_hour
ORDER BY total_sales DESC
LIMIT 1;

-- 14 Calculate year-over-year growth in sales (if multiple years of data exist).
WITH yearly_sales AS (
    SELECT 
        YEAR(transaction_date) AS sales_year,
        SUM(transaction_qty * unit_price) AS total_sales
    FROM coffeesalesdata
    GROUP BY YEAR(transaction_date)
    ORDER BY sales_year
)
SELECT 
    sales_year,
    total_sales,
    LAG(total_sales) OVER (ORDER BY sales_year) AS prev_year_sales,
    ROUND(
        ( (total_sales - LAG(total_sales) OVER (ORDER BY sales_year)) 
          / LAG(total_sales) OVER (ORDER BY sales_year) ) * 100, 2
    ) AS yoy_growth_percent
FROM yearly_sales;

-- 15 Show the product with the highest profit contribution (assuming unit_price ≈ sales price).
SELECT 
    product_id,
    product_detail,
    SUM(transaction_qty * unit_price) AS total_revenue
FROM coffeesalesdata
GROUP BY product_id, product_detail
ORDER BY total_revenue DESC
LIMIT 1;


-- 16 Which store has the highest average transaction value?
SELECT 
    store_id,
    store_location,
    ROUND(SUM(transaction_qty * unit_price) / COUNT(DISTINCT transaction_id), 2) AS avg_transactionValue
FROM coffeesalesdata
GROUP BY 
	store_id,
    store_location
ORDER BY avg_transactionValue DESC
LIMIT 1;

-- 17 What percentage of revenue comes from each product_category?
SELECT 
    product_category,
    ROUND((SUM(transaction_qty * unit_price) / 
         (SELECT SUM(transaction_qty * unit_price) FROM coffeesalesdata)) * 100, 2
		) AS revenue_percentage
FROM coffeesalesdata
GROUP BY product_category
ORDER BY revenue_percentage DESC;


-- 18 Which products are low-performing (low quantity + low revenue)?
WITH product_sales AS (
    SELECT 
        product_id,
        product_detail,
        SUM(transaction_qty) AS total_qty,
        SUM(transaction_qty * unit_price) AS total_revenue
    FROM coffeesalesdata
    GROUP BY 
		product_id,
		product_detail),
averages AS (
    SELECT 
        AVG(total_qty) AS avg_qty,
        AVG(total_revenue) AS avg_revenue
    FROM product_sales
)
SELECT 
    ps.product_id,
    ps.product_detail,
    ps.total_qty,
    ps.total_revenue
FROM product_sales ps
CROSS JOIN averages a
WHERE ps.total_qty < a.avg_qty
  AND ps.total_revenue < a.avg_revenue
ORDER BY ps.total_revenue ASC, ps.total_qty ASC;


-- 19 How much revenue did each store generate during the holiday season (e.g., December)?
SELECT 
    store_id,
    store_location,
    SUM(transaction_qty * unit_price) AS december_revenue
FROM coffeesalesdata
WHERE MONTH(transaction_date) = 12
GROUP BY 
	store_id, 
    store_location
ORDER BY december_revenue DESC;

-- 20 Create a ranking of store locations by total revenue.
SELECT 
    store_id,
    store_location,
    SUM(transaction_qty * unit_price) AS total_revenue,
    RANK() OVER (ORDER BY SUM(transaction_qty * unit_price) DESC) AS revenue_rank
FROM coffeesalesdata
GROUP BY store_id, store_location
ORDER BY total_revenue DESC;


-- DISCLAIMER: The SQL analysis presented in this project is created solely for educational and practice purposes. The
-- dataset and results are fictional and do not reflect or represent the operations, financials, or performance of
-- any actual coffee shop, company, or brand. Any similarities to real businesses are purely coincidental.