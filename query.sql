-- Task 01 : Data Preparation --
CREATE TABLE IF NOT EXISTS products
(
	num serial,
	product_id varchar(32) PRIMARY KEY,
	product_category_name varchar(50),
	product_name_lenght numeric,
	product_description_lenght numeric,
	product_photos_qty numeric,
	product_weight_g numeric,
	product_length_cm numeric,
	product_height_cm numeric,
	product_width_cm numeric
);

CREATE TABLE IF NOT EXISTS geolocations
(
	geolocation_zip_code_prefix varchar(5),
	geolocation_lat numeric, 
	geolocation_lng numeric, 
	geolocation_city varchar(50), 
	geolocation_state varchar(2)
);

CREATE TABLE IF NOT EXISTS customers
(
	customer_id varchar(32) PRIMARY KEY,
	customer_unique_id varchar(32),
    -- seller_zip_code_prefix refers to geolocation.geolocation_zip_code_prefix. 
    -- not a Foreign Key because reference column is not unique.
	customer_zip_code_prefix varchar(5),
	customer_city varchar(50),
	customer_state varchar(2)
);

CREATE TABLE IF NOT EXISTS sellers
(
	seller_id varchar(32) PRIMARY KEY,
    -- seller_zip_code_prefix refers to geolocation.geolocation_zip_code_prefix. 
    -- not a Foreign Key because reference column is not unique.
	seller_zip_code_prefix varchar(5), 
	seller_city varchar(50),
	seller_state varchar(2)
);

CREATE TABLE IF NOT EXISTS orders
(
	order_id varchar(32) PRIMARY KEY,
	customer_id varchar(32) references customers(customer_id),
	order_status varchar(20),
	order_purchase_timestamp timestamp,
	order_approved_at timestamp,
	order_delivered_carrier_date timestamp,
	order_delivered_customer_date timestamp,
	order_estimated_delivery_date timestamp
);

CREATE TABLE IF NOT EXISTS order_items
(
	order_id varchar(32) references orders(order_id),
	order_item_id varchar(32),
	product_id varchar(32) references product(product_id),
	seller_id varchar(32) references seller(seller_id),
	shipping_limit_date timestamp,
	price numeric,
	freight_value numeric
);

CREATE TABLE IF NOT EXISTS order_reviews
(
	review_id varchar(32),
	order_id varchar(32) references orders(order_id),
	review_score smallint,
	review_comment_title varchar(30),
	review_comment_message text,
	review_creation_date timestamp,
	review_answer_timestamp timestamp
);

CREATE TABLE IF NOT EXISTS order_payments
(
	order_id varchar(32) references orders(order_id),
	payment_sequential smallint,
	payment_type varchar(20),
	payment_installments smallint,
	payment_value numeric
);

-- Task 02 : Annual Customer Activity Growth Analysis --
WITH temp1 AS(
	-- Displays the average number of monthly active users for each year --
	WITH active_users AS(
		SELECT 
			EXTRACT (YEAR FROM o.order_purchase_timestamp) purchase_year, 
			EXTRACT(MONTH FROM o.order_purchase_timestamp) purchase_month,
			COUNT(DISTINCT c.customer_unique_id) AS monthly_active_users
		FROM 
			orders o JOIN customers c ON o.customer_id = c.customer_id
		GROUP BY 
			purchase_year, purchase_month
	)
	SELECT 
		purchase_year,
		FLOOR(AVG(monthly_active_users)) monthly_active_users
	FROM 
		active_users
	GROUP BY 
		purchase_year
),
temp2 AS(
	-- Displays the number of new customers in each year --
	WITH min_order AS (
		SELECT 
			c.customer_unique_id,
			MIN(o.order_purchase_timestamp) AS min_time_order
		FROM 
			orders o JOIN customers c ON o.customer_id = c.customer_id
		GROUP BY 
			customer_unique_id
	)
	SELECT 
		EXTRACT(YEAR FROM min_time_order ) AS purchase_year, 
		COUNT (DISTINCT customer_unique_id) new_customers
	FROM 
		min_order
	GROUP BY 
		purchase_year
),
temp3 AS(
	-- Displays the number of customers who make purchases more than once (repeat orders) in each year --
	WITH repeat_order AS(
		SELECT 
			EXTRACT(YEAR FROM o.order_purchase_timestamp) purchase_year,
			c.customer_unique_id,
			COUNT(o.order_purchase_timestamp) jumlah
		FROM 
			orders o JOIN customers c ON o.customer_id = c.customer_id
		GROUP BY purchase_year, c.customer_unique_id
		HAVING COUNT(o.order_purchase_timestamp) > 1
		ORDER BY 3 DESC
	)
	SELECT 
		purchase_year,
		COUNT(DISTINCT customer_unique_id) repeat_order_customers
	FROM repeat_order
	GROUP BY purchase_year
),
temp4 AS(
	-- Displays the average number of orders made by customers for each year --
	WITH temp AS(
		SELECT 
			EXTRACT(YEAR FROM o.order_purchase_timestamp) purchase_year,
			c.customer_unique_id,
			COUNT(order_id) order_freq
		FROM
			orders o JOIN customers c ON o.customer_id = c.customer_id
		GROUP BY
			purchase_year, c.customer_unique_id
		ORDER BY 
			order_freq DESC
	)
	SELECT 
		purchase_year,
		ROUND(AVG(order_freq), 3) avg_order_freq
	FROM 
		temp
	GROUP BY 
		purchase_year
)
-- Combine the information that has been obtained into a single table view --
SELECT 
	temp1.purchase_year,
	temp1.monthly_active_users,
	temp2.new_customers,
	temp3.repeat_order_customers,
	temp4.avg_order_freq
FROM 
	temp1 
	JOIN temp2 ON temp1.purchase_year = temp2.purchase_year
	JOIN temp3 ON temp1.purchase_year = temp3.purchase_year
	JOIN temp4 ON temp1.purchase_year = temp4.purchase_year
;

-- Task 03 : Product Category Analysis --
-- Create a table that contains total company revenue/revenue information for each year -- 
CREATE TABLE total_revenue AS
	SELECT 
		EXTRACT(YEAR FROM o.order_purchase_timestamp) purchase_year,
		SUM(oi.price + oi.freight_value) revenue
	FROM 
		order_items oi JOIN orders o ON oi.order_id = o.order_id
	WHERE
		o.order_status = 'delivered'
	GROUP BY 
		purchase_year
;

-- Create a table that contains information on the total number of cancel orders for each year -- 
CREATE TABLE canceled_order_year AS
	SELECT 
		EXTRACT(YEAR FROM order_purchase_timestamp) purchase_year,
		COUNT(order_id) canceled_order
	FROM 
		orders
	WHERE
		order_status = 'canceled'
	GROUP BY 
		purchase_year
;

-- Create a table containing the product category names 
-- that provide the highest total revenue for each year
CREATE TABLE top_revenue_category AS(
	WITH revenue_category AS (
		SELECT 
			EXTRACT(YEAR FROM o.order_purchase_timestamp) purchase_year,
			p.product_category_name,
			SUM(oi.price + oi.freight_value) revenue,
			RANK() OVER (
				PARTITION BY EXTRACT(YEAR FROM o.order_purchase_timestamp)
				ORDER BY SUM(oi.price + oi.freight_value) DESC
			) revenue_rank
		FROM
			product p
			JOIN order_items oi ON p.product_id = oi.product_id
			JOIN orders o ON oi.order_id = o.order_id
		WHERE
			o.order_status = 'delivered'
		GROUP BY 1,2
	)
	SELECT 
		purchase_year,
		product_category_name,
		revenue
	FROM
		revenue_category
	WHERE
		revenue_rank = 1
)
;

-- Create a table containing the names of the product categories 
-- that have the highest number of canceled orders for each year 
CREATE TABLE most_canceled_category AS(
	WITH canceled_category AS (
		SELECT 
			EXTRACT(YEAR FROM o.order_purchase_timestamp) purchase_year,
			p.product_category_name,
			COUNT(o.order_id) total_canceled,
			RANK() OVER (
				PARTITION BY EXTRACT(YEAR FROM o.order_purchase_timestamp)
				ORDER BY COUNT(o.order_id) DESC
			) canceled_rank
		FROM
			product p
			JOIN order_items oi ON p.product_id = oi.product_id
			JOIN orders o ON oi.order_id = o.order_id
		WHERE
			o.order_status = 'canceled'
		GROUP BY 1,2
	)
	SELECT 
		purchase_year,
		product_category_name,
		total_canceled
	FROM
		canceled_category
	WHERE
		canceled_rank = 1
)
;

-- Combine the information that has been obtained into a single table view --
SELECT 
	tr.purchase_year "year",
	tr.revenue total_revenue,
	trc.product_category_name most_profitable_category,
	trc.revenue category_profit,
	co.canceled_order total_canceled_order,
	mcc.product_category_name most_canceled_category,
	mcc.total_canceled canceled_order_category
FROM 
	total_revenue tr
	JOIN top_revenue_category trc ON tr.purchase_year = trc.purchase_year
	JOIN canceled_order_year co ON tr.purchase_year = co.purchase_year
	JOIN most_canceled_category mcc ON tr.purchase_year = mcc.purchase_year
;

-- Task 04 : Analysis of Annual Payment Type Usage --
