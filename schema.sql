-- Olist E-Commerce Dataset Schema
-- Run this once to create all tables before loading data.

DROP TABLE IF EXISTS olist_order_reviews_dataset CASCADE;
DROP TABLE IF EXISTS olist_order_payments_dataset CASCADE;
DROP TABLE IF EXISTS olist_order_items_dataset CASCADE;
DROP TABLE IF EXISTS olist_orders_dataset CASCADE;
DROP TABLE IF EXISTS olist_products_dataset CASCADE;
DROP TABLE IF EXISTS olist_sellers_dataset CASCADE;
DROP TABLE IF EXISTS olist_customers_dataset CASCADE;
DROP TABLE IF EXISTS olist_geolocation_dataset CASCADE;
DROP TABLE IF EXISTS product_category_name_translation CASCADE;

-- Customers
CREATE TABLE olist_customers_dataset (
    customer_id VARCHAR(64) PRIMARY KEY,
    customer_unique_id VARCHAR(64),
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

-- Sellers
CREATE TABLE olist_sellers_dataset (
    seller_id VARCHAR(64) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(10),
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

-- Products
CREATE TABLE olist_products_dataset (
    product_id VARCHAR(64) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght NUMERIC,
    product_description_lenght NUMERIC,
    product_photos_qty NUMERIC,
    product_weight_g NUMERIC,
    product_length_cm NUMERIC,
    product_height_cm NUMERIC,
    product_width_cm NUMERIC
);

-- Category name translation
CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);

-- Geolocation
CREATE TABLE olist_geolocation_dataset (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat NUMERIC,
    geolocation_lng NUMERIC,
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);

-- Orders
CREATE TABLE olist_orders_dataset (
    order_id VARCHAR(64) PRIMARY KEY,
    customer_id VARCHAR(64) REFERENCES olist_customers_dataset(customer_id),
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- Order items
CREATE TABLE olist_order_items_dataset (
    order_id VARCHAR(64) REFERENCES olist_orders_dataset(order_id),
    order_item_id INTEGER,
    product_id VARCHAR(64) REFERENCES olist_products_dataset(product_id),
    seller_id VARCHAR(64) REFERENCES olist_sellers_dataset(seller_id),
    shipping_limit_date TIMESTAMP,
    price NUMERIC,
    freight_value NUMERIC,
    PRIMARY KEY (order_id, order_item_id)
);

-- Payments
CREATE TABLE olist_order_payments_dataset (
    order_id VARCHAR(64) REFERENCES olist_orders_dataset(order_id),
    payment_sequential INTEGER,
    payment_type VARCHAR(30),
    payment_installments INTEGER,
    payment_value NUMERIC,
    PRIMARY KEY (order_id, payment_sequential)
);

-- Reviews
CREATE TABLE olist_order_reviews_dataset (
    review_id VARCHAR(64),
    order_id VARCHAR(64) REFERENCES olist_orders_dataset(order_id),
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    PRIMARY KEY (review_id, order_id)
);
