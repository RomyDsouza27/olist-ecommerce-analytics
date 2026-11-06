
-- =====================================================
-- OLIST ANALYTICS RELATIONAL MODEL
-- Source: staging schema
-- Target: analytics schema
-- =====================================================

BEGIN;

CREATE SCHEMA IF NOT EXISTS analytics;

-- 1. CUSTOMERS
CREATE TABLE analytics.customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state VARCHAR(2)
);

INSERT INTO analytics.customers
SELECT * FROM staging.customers;


-- 2. ORDERS
CREATE TABLE analytics.orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    CONSTRAINT fk_orders_customers
        FOREIGN KEY (customer_id)
        REFERENCES analytics.customers(customer_id)
);

INSERT INTO analytics.orders
SELECT * FROM staging.orders;


-- 3. PRODUCTS
CREATE TABLE analytics.products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name TEXT,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

INSERT INTO analytics.products
SELECT * FROM staging.products;


-- 4. SELLERS
CREATE TABLE analytics.sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city TEXT,
    seller_state VARCHAR(2)
);

INSERT INTO analytics.sellers
SELECT * FROM staging.sellers;


-- 5. ORDER ITEMS
SELECT
    COALESCE(ct.product_category_name_english,
             p.product_category_name) AS product_category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS total_items_sold,
    ROUND(SUM(oi.price), 2) AS category_revenue
FROM analytics.order_items oi
JOIN analytics.orders o
    ON oi.order_id = o.order_id
JOIN analytics.products p
    ON oi.product_id = p.product_id
LEFT JOIN analytics.category_translation ct
    ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY category_revenue DESC
LIMIT 10;


-- 6. ORDER PAYMENTS
CREATE TABLE analytics.order_payments (
    order_id VARCHAR(50),
    payment_sequential INTEGER,
    payment_type VARCHAR(50),
    payment_installments INTEGER,
    payment_value NUMERIC(12,2),

    PRIMARY KEY (order_id, payment_sequential),

    FOREIGN KEY (order_id)
        REFERENCES analytics.orders(order_id)
);

INSERT INTO analytics.order_payments
SELECT * FROM staging.order_payments;


-- 7. ORDER REVIEWS
CREATE TABLE analytics.order_reviews (
    review_record_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    review_id VARCHAR(50),
    order_id VARCHAR(50) NOT NULL,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,

    CONSTRAINT uq_review_order
        UNIQUE (review_id, order_id),

    FOREIGN KEY (order_id)
        REFERENCES analytics.orders(order_id)
);

INSERT INTO analytics.order_reviews (
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
)
SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM staging.order_reviews;


-- 8. CATEGORY TRANSLATION
CREATE TABLE analytics.category_translation (
    product_category_name TEXT PRIMARY KEY,
    product_category_name_english TEXT
);

INSERT INTO analytics.category_translation
SELECT * FROM staging.category_translation;


-- 9. GEOLOCATION
CREATE TABLE analytics.geolocation (
    geolocation_record_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat NUMERIC(12,8),
    geolocation_lng NUMERIC(12,8),
    geolocation_city TEXT,
    geolocation_state VARCHAR(2)
);

INSERT INTO analytics.geolocation (
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
)
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM staging.geolocation;


-- 10. INDEXES FOR PERFORMANCE

CREATE INDEX idx_orders_customer
ON analytics.orders(customer_id);

CREATE INDEX idx_orders_purchase_date
ON analytics.orders(order_purchase_timestamp);

CREATE INDEX idx_orders_status
ON analytics.orders(order_status);

CREATE INDEX idx_customers_unique_id
ON analytics.customers(customer_unique_id);

CREATE INDEX idx_items_product
ON analytics.order_items(product_id);

CREATE INDEX idx_items_seller
ON analytics.order_items(seller_id);

CREATE INDEX idx_reviews_order
ON analytics.order_reviews(order_id);

CREATE INDEX idx_products_category
ON analytics.products(product_category_name);

CREATE INDEX idx_geolocation_zip
ON analytics.geolocation(geolocation_zip_code_prefix);


-- 11. UPDATE TABLE STATISTICS

ANALYZE analytics.customers;
ANALYZE analytics.orders;
ANALYZE analytics.products;
ANALYZE analytics.sellers;
ANALYZE analytics.order_items;
ANALYZE analytics.order_payments;
ANALYZE analytics.order_reviews;
ANALYZE analytics.category_translation;
ANALYZE analytics.geolocation;

COMMIT;
