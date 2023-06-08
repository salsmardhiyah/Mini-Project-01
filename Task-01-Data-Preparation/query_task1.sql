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
