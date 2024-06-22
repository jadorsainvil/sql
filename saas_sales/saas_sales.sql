-- Create table with 19 columns to accommodate dataset, establish first row as primary key.

CREATE TABLE SaaS_sales(
	row_id INT PRIMARY KEY,
	order_id VARCHAR(50),
	order_date VARCHAR(50),
	date_key VARCHAR(50),
	contact_name VARCHAR(50),
	country VARCHAR (50),
	city VARCHAR(50),
	region VARCHAR(50),
	subregion VARCHAR(50),
	customer VARCHAR(50),
	customer_id INT,
	industry VARCHAR(50),
	segment VARCHAR(50),
	product VARCHAR(100),
	license VARCHAR(100),
	sales NUMERIC,
	quantity INT,
	discount NUMERIC,
	profit NUMERIC);

-- Confirm accurate data load and data count (9994 rows).

SELECT * FROM SaaS_sales;
SELECT COUNT(*) FROM SaaS_sales;

-- Determine top 5 most profitable industries.

SELECT industry, sum(profit)
FROM saas_sales
GROUP BY industry
ORDER BY sum(profit) DESC;

-- Determine most profitable region.

SELECT region, sum(profit)
FROM saas_sales
GROUP BY industry
ORDER BY sum(profit) DESC;

-- Determine most profitable country.

SELECT country, sum(profit)
FROM saas_sales
GROUP BY country
ORDER BY sum(profit) DESC;

-- Highest profit margin product and region.

SELECT product, region, AVG(profit/sales)*100 AS margin
FROM SaaS_sales
GROUP BY product, region
ORDER BY margin DESC;

-- Most profitable customer grouped by industry and product in descending order.

SELECT customer, industry, product, SUM(profit)
FROM SaaS_sales
GROUP BY customer, industry, product
ORDER BY SUM(profit) DESC;