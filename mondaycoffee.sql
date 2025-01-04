CREATE TABLE city
(
	city_id	INT PRIMARY KEY,
	city_name VARCHAR(15),	
	population	BIGINT,
	estimated_rent	FLOAT,
	city_rank INT
);

CREATE TABLE customers
(
	customer_id INT PRIMARY KEY,	
	customer_name VARCHAR(25),	
	city_id INT,
	CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);


CREATE TABLE products
(
	product_id	INT PRIMARY KEY,
	product_name VARCHAR(35),	
	Price float
);


CREATE TABLE sales
(
	sale_id	INT PRIMARY KEY,
	sale_date	date,
	product_id	INT,
	customer_id	INT,
	total FLOAT,
	rating INT,
	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
);

--city and coffee consumers
SELECT
	CITY_NAME,
	ROUND((POPULATION * 0.25) / 1000000, 2) AS IN_MILLIONS,
	CITY_RANK
FROM
	CITY ORDER BY
	2 DESC

--total revenue in quarter 4 and year 2024
SELECT
	SUM(TOTAL)
FROM
	SALES
WHERE
	EXTRACT(
		QUARTER
		FROM
			SALE_DATE
	) = 4
	AND EXTRACT(
		YEAR
		FROM
			SALE_DATE
	) = 2023

--Number of times prodoct sold
SELECT
	PRODUCT_NAME,
	COUNT(*)
FROM
	PRODUCTS P
	JOIN SALES S ON P.PRODUCT_ID = S.PRODUCT_ID
GROUP BY
	1
ORDER BY	2 DESC

--top 5 product,count and total revenue based on sales
SELECT
	P.PRODUCT_NAME,
	COUNT(*),
	SUM(TOTAL)
FROM
	PRODUCTS P
	NATURAL JOIN SALES
GROUP BY
	1
ORDER BY
	2 DESC
limit 5

--top rated products
SELECT
	P.PRODUCT_NAME,
	ROUND(AVG(RATING), 3)
FROM
	SALES S,
	PRODUCTS P
WHERE
	S.PRODUCT_ID = P.PRODUCT_ID
GROUP BY
	1
ORDER BY
	AVG(RATING) DESC
LIMIT
	5
	
--city,distinct customer avg spend by customer for city
SELECT
	CI.CITY_NAME,
	COUNT(DISTINCT C.CUSTOMER_ID),
	SUM(TOTAL),
	SUM(TOTAL) / COUNT(DISTINCT C.CUSTOMER_ID) AS AVG_PER_CUSTOMER
FROM
	SALES S
	JOIN CUSTOMERS C ON S.CUSTOMER_ID = C.CUSTOMER_ID
	JOIN CITY CI ON CI.CITY_ID = C.CITY_ID
GROUP BY
	1
ORDER BY
	3 DESC

--find top 3 city with high sale 
SELECT
	CITY_NAME,
	SUM(TOTAL)
FROM
	CITY CI
	NATURAL JOIN CUSTOMERS C
	JOIN SALES S ON C.CUSTOMER_ID = S.CUSTOMER_ID
GROUP BY
	1 ORDER BY
	2 DESC

--what is the average rent cost for each city
SELECT
	C.CITY_NAME,
	CITY.ESTIMATED_RENT,
	COFFEE_CONSUMERS
FROM
	CITY
	NATURAL JOIN (
		SELECT
			CITY_NAME,
			(POPULATION * 0.25) AS COFFEE_CONSUMERS
		FROM
			CITY
	) AS C
ORDER BY
	3 DESC
	
--top 3 selling product in each city
SELECT
	*
FROM
	(
		SELECT
			CI.CITY_NAME,
			P.PRODUCT_NAME,
			COUNT(S.SALE_ID),
			DENSE_RANK() OVER (
				PARTITION BY
					CI.CITY_NAME
				ORDER BY
					COUNT(S.SALE_ID) DESC
			)
		FROM
			CITY CI
			JOIN CUSTOMERS C ON CI.CITY_ID = C.CITY_ID
			JOIN SALES S ON C.CUSTOMER_ID = S.CUSTOMER_ID
			JOIN PRODUCTS P ON S.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			1,
			2
		ORDER BY
			1,
			3
	)
WHERE
	DENSE_RANK <= 3

--how many unique customer in each city who purchase coffee 
SELECT
	CI.CITY_NAME,
	COUNT(DISTINCT C.CUSTOMER_ID)
FROM
	CITY CI
	JOIN CUSTOMERS C ON CI.CITY_ID = C.CITY_ID
	JOIN SALES S ON C.CUSTOMER_ID = S.CUSTOMER_ID
	JOIN PRODUCTS P ON S.PRODUCT_ID = P.PRODUCT_ID
WHERE
	P.PRODUCT_ID IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)GROUP BY
	1
ORDER BY
	2 DESC

--top cities with highest sales in quarter 4 and year 2024
SELECT
	CI.CITY_NAME,
	SUM(TOTAL) AS SALE
FROM
	SALES S
	JOIN CUSTOMERS C ON S.CUSTOMER_ID = C.CUSTOMER_ID
	JOIN CITY CI ON CI.CITY_ID = C.CITY_ID
WHERE
	EXTRACT(
		QUARTER
		FROM
			SALE_DATE
	) = 4
	AND EXTRACT(
		YEAR
		FROM
			SALE_DATE
	) = 2023
GROUP BY
	CI.CITY_NAME
ORDER BY
	SALE DESC
LIMIT
	5


--avg sale avg rent per customer
SELECT
	CITY.CITY_NAME,
	AVG_PER_CUSTOMER,
	(CITY.ESTIMATED_RENT / C)
FROM
	(
		SELECT
			CI.CITY_NAME,
			COUNT(DISTINCT C.CUSTOMER_ID) AS C,
			SUM(TOTAL),
			SUM(TOTAL) / COUNT(DISTINCT C.CUSTOMER_ID) AS AVG_PER_CUSTOMER
		FROM
			SALES S
			JOIN CUSTOMERS C ON S.CUSTOMER_ID = C.CUSTOMER_ID
			JOIN CITY CI ON CI.CITY_ID = C.CITY_ID
		GROUP BY
			1
		ORDER BY
			3 DESC
	) AS CI
	JOIN CITY ON CI.CITY_NAME = CITY.CITY_NAME




	


	
