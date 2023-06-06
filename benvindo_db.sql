DROP SCHEMA IF EXISTS benvindo CASCADE;

CREATE SCHEMA benvindo;

DROP TABLE IF EXISTS benvindo.product_category_name_translation CASCADE;

CREATE TABLE benvindo.product_category_name_translation (
	product_category_name VARCHAR(50) DEFAULT NULL,
	product_category_name_english VARCHAR(50) DEFAULT NULL,
	CONSTRAINT pk_product_category PRIMARY KEY (product_category_name)
);

DROP TABLE IF EXISTS benvindo.products CASCADE;

CREATE TABLE benvindo.products (
	product_id VARCHAR(32) DEFAULT NULL,
	product_category_name VARCHAR(50)
		REFERENCES benvindo.product_category_name_translation (product_category_name)
		ON UPDATE CASCADE,
	product_name_length INTEGER,
	product_description_length INTEGER,
	product_photos_qty INTEGER,
	product_weight_g NUMERIC,
	product_length_cm NUMERIC,
	product_height_cm NUMERIC,
	product_width_cm NUMERIC,
	CONSTRAINT pk_product PRIMARY KEY (product_id)
);

DROP TABLE IF EXISTS benvindo.orders CASCADE;

CREATE TABLE benvindo.orders (
	order_id VARCHAR(32) DEFAULT NULL,
	customer_id VARCHAR(32),
	order_status VARCHAR(12),
	order_purchase_timestamp TIMESTAMP,
	order_approved_at TIMESTAMP,
	order_delivered_carrier_date TIMESTAMP,
	order_delivered_customer_date TIMESTAMP,
	order_estimated_delivery_date TIMESTAMP,
	CONSTRAINT pk_order PRIMARY KEY (order_id)
);

DROP TABLE IF EXISTS benvindo.reviews CASCADE;

CREATE TABLE benvindo.reviews (
	review_id VARCHAR(32),
	order_id VARCHAR(32)
		REFERENCES benvindo.orders (order_id)
		ON UPDATE CASCADE,
	review_score INTEGER,
	review_comment_title VARCHAR(32),
	review_comment_message VARCHAR(270),
	review_creation_date DATE,
	review_answer_timestamp TIMESTAMP
);

DROP TABLE IF EXISTS benvindo.payments CASCADE;

CREATE TABLE benvindo.payments (
	order_id VARCHAR(32)
		REFERENCES benvindo.orders (order_id)
		ON UPDATE CASCADE,
	payment_sequential INTEGER,
	payment_type VARCHAR(20),
	payment_installments INTEGER,
	payment_value NUMERIC
);

DROP TABLE IF EXISTS benvindo.items CASCADE;

CREATE TABLE benvindo.items (
	order_id VARCHAR(32)
		REFERENCES benvindo.orders (order_id)
		ON UPDATE CASCADE,
	order_item_id INTEGER,
	product_id VARCHAR(32)
		REFERENCES benvindo.products (product_id)
		ON UPDATE CASCADE,
	seller_id VARCHAR(32),
	shipping_limit_date TIMESTAMP,
	price NUMERIC,
	freight_value NUMERIC
);

COPY benvindo.product_category_name_translation (
	product_category_name,
	product_category_name_english
)

FROM 'D:\Proyectos Personales\Archivos - Data Challenge\product_category_name_translation.csv'

DELIMITER ','
CSV HEADER;

COPY benvindo.products (
	product_id,
	product_category_name,
	product_name_length,
	product_description_length,
	product_photos_qty,
	product_weight_g,
	product_length_cm,
	product_height_cm,
	product_width_cm
)

FROM 'D:\Proyectos Personales\Archivos - Data Challenge\olist_products_dataset.csv'

DELIMITER ','
CSV HEADER;

COPY benvindo.orders (
	order_id,
	customer_id,
	order_status,
	order_purchase_timestamp,
	order_approved_at,
	order_delivered_carrier_date,
	order_delivered_customer_date,
	order_estimated_delivery_date
)

FROM 'D:\Proyectos Personales\Archivos - Data Challenge\olist_orders_dataset.csv'

DELIMITER ','
CSV HEADER;

COPY benvindo.reviews (
	review_id,
	order_id,
	review_score,
	review_comment_title,
	review_comment_message,
	review_creation_date,
	review_answer_timestamp
)

FROM 'D:\Proyectos Personales\Archivos - Data Challenge\olist_order_reviews_dataset.csv'

DELIMITER ','
CSV HEADER;

COPY benvindo.payments (
	order_id,
	payment_sequential,
	payment_type,
	payment_installments,
	payment_value
)

FROM 'D:\Proyectos Personales\Archivos - Data Challenge\olist_order_payments_dataset.csv'

DELIMITER ','
CSV HEADER;

COPY benvindo.items (
	order_id,
	order_item_id,
	product_id,
	seller_id,
	shipping_limit_date,
	price,
	freight_value
)

FROM 'D:\Proyectos Personales\Archivos - Data Challenge\olist_order_items_dataset.csv'

DELIMITER ','
CSV HEADER;

COMMIT;