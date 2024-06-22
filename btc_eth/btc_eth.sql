-- Database creation for crypto currency comparisons.

CREATE DATABASE crypto;

-- Switch mySQL to using crypto database.

USE crypto;

-- Table creation for 4-column BTC and ETH data load, featuring prices timestamp, price (to two decimal places), market capitalization at time of timestamp, and total trading volume.

CREATE TABLE bitcoin(
	snapped_at DATETIME PRIMARY KEY,
	bitcoin_price BIGINT,
	bitcoin_market_cap BIGINT,
	bitcoin_total_volume BIGINT);

CREATE TABLE ethereum(
	snapped_at DATETIME PRIMARY KEY,
	ethereum_price BIGINT,
	ethereum_market_cap BIGINT,
	ethereum_total_volume BIGINT);

-- Manual table dataload for BTC-USD-MAX.csv and ETH-USD-MAX.csv

LOAD DATA INFILE '/usr/local/btc-usd-max.csv'
INTO TABLE bitcoin
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE '/usr/local/eth-usd-max.csv'
INTO TABLE ethereum
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Verification of successful data load, existence and population of both tables, confirmation of row number for each table. Expected values 4069 (bitcoin) and 3239 (ethereum).

SELECT * FROM bitcoin;
SELECT * FROM ethereum;
SELECT COUNT(*) FROM bitcoin;
SELECT COUNT(*) FROM ethereum;

-- INNER JOIN on timestamp to connect BTC and ETH tables. Expected result 3235 (bitcoin and ethereum).

SELECT * FROM bitcoin
LEFT JOIN ethereum
ON bitcoin.snapped_at = ethereum.snapped_at;

SELECT COUNT(*) FROM bitcoin
LEFT JOIN ethereum
ON bitcoin.snapped_at = ethereum.snapped_at;

-- Calculation of average bitcoin and ethereum price over the last 4 years.

SELECT avg(bitcoin_price) AS avg_btc_price, avg(ethereum_price) AS avg_eth_price
FROM bitcoin
INNER JOIN ethereum
ON bitcoin.snapped_at = ethereum.snapped_at
WHERE bitcoin.snapped_at BETWEEN '2020-06-01' AND '2024-06-01';

-- Calculation of standard deviation of bitcoin and ethereum price over the last 4 years.

SELECT stddev_samp(bitcoin_price) AS std_btc, 
	    stddev_samp(ethereum_price) AS std_eth
FROM bitcoin
INNER JOIN ethereum
ON bitcoin.snapped_at = ethereum.snapped_at
WHERE bitcoin.snapped_at BETWEEN '2020-06-01' AND '2024-06-01';

-- Correlation coefficient of bitcoin and ethereum price over the last 4 years.

SELECT 
	corr(bitcoin_price, ethereum_price) AS 'btc_eth_corr'
FROM bitcoin
INNER JOIN ethereum
	ON bitcoin.snapped_at = ethereal.snapped_at
WHERE snapped_at BETWEEN ’2020-06-01’ AND ‘2024-06-01’;

-- Calculating daily percent change of Bitcoin price’s since June 2020.

SELECT snapped_at, (bitcoin_price-prev_day_price )/(prev_day_price) AS daily_percent_change
FROM(
		SELECT snapped_at, bitcoin_price, 
		LAG(bitcoin_price) OVER (ORDER BY snapped_at) AS prev_day_price
		FROM bitcoin
		WHERE snapped_at BETWEEN '2020-06-01' AND '2024-06-01'
) AS bitcoin_delta;

-- Calculating monthly percent change of Bitcoin’s price since June 2020.
 
SELECT snapped_at, (bitcoin_price-prev_month_price)/(prev_month_price) AS monthly_percent_change
FROM(
	SELECT snapped_at, bitcoin_price, LAG(bitcoin_price) OVER (ORDER BY snapped_at) AS prev_month_price
	FROM(
		SELECT snapped_at, bitcoin_price
		FROM bitcoin
		WHERE snapped_at LIKE '%%%%-%%-01 %%:%%:%%')
		AS monthly_bitcoin_data
    ) AS monthly_bitcoin_price_delta
WHERE snapped_at BETWEEN '2020-06-01' AND '2024-06-01'
    ;

-- Calculating average monthly growth of Bitcoin’s price since June 2020.

 SELECT
	AVG(monthly_percent_change)
	FROM
		(SELECT snapped_at, (bitcoin_price-prev_month_price)/(prev_month_price) AS monthly_percent_change
			FROM(
				SELECT snapped_at, bitcoin_price, LAG(bitcoin_price) OVER (ORDER BY snapped_at) AS prev_month_price
				FROM(
					SELECT snapped_at, bitcoin_price
					FROM bitcoin
					WHERE snapped_at LIKE '%%%%-%%-01 %%:%%:%%')
						AS monthly_bitcoin_data
				) AS monthly_bitcoin_price_delta
				WHERE snapped_at BETWEEN '2020-06-01' AND '2024-06-01'
		) AS monthly_bitcoin_percent_change;

-- Track yearly growth of Bitcoin’s price since inception.

SELECT 
	snapped_at, (bitcoin_price-prev_year_price)/(prev_year_price) AS yearly_percent_change
			FROM(
				SELECT snapped_at, bitcoin_price, LAG(bitcoin_price) OVER (ORDER BY snapped_at) AS prev_year_price
				FROM(
					SELECT snapped_at, bitcoin_price
					FROM bitcoin
					WHERE snapped_at LIKE '%%%%-06-01 %%:%%:%%')
						AS yearly_bitcoin_data
				) AS yearly_bitcoin;

-- Calculating average yearly growth of Bitcoin’s price since June 2020.

CREATE VIEW avg_bitcoin_returns_per_year AS
SELECT
	AVG(yearly_percent_change)
	FROM
		(SELECT snapped_at, (bitcoin_price-prev_year_price)/(prev_year_price) AS yearly_percent_change
			FROM(
				SELECT snapped_at, bitcoin_price, LAG(bitcoin_price) OVER (ORDER BY snapped_at) AS prev_year_price
				FROM(
					SELECT snapped_at, bitcoin_price
					FROM bitcoin
					WHERE snapped_at LIKE '%%%%-06-01 %%:%%:%%')
						AS yearly_bitcoin_data
				) AS yearly_bitcoin
		) AS yearly_bitcoin_percent_change;

-- Calculating quarterly growth of Bitcoin’s price since June 2020.

SELECT snapped_at, (bitcoin_price-prev_quarter_price)/(prev_quarter_price) AS quarterly_percent_change
			FROM(
				SELECT snapped_at, bitcoin_price, LAG(bitcoin_price) OVER (ORDER BY snapped_at) AS prev_quarter_price
				FROM(
					SELECT snapped_at, bitcoin_price
					FROM bitcoin
					WHERE snapped_at LIKE '%%%%-03-31 %%:%%:%%' OR snapped_at LIKE '%%%%-06-30 %%:%%:%%' OR snapped_at LIKE '%%%%-09-30 %%:%%:%%' OR snapped_at LIKE '%%%%-12-31 %%:%%:%%'
						)AS quarterly_bitcoin_data
							)AS quarterly_bitcoin_percent_change
			WHERE snapped_at > '2020-03-31';
                            