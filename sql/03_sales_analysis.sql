
-- ============================================================
-- OLIST E-COMMERCE CUSTOMER BEHAVIOUR & RETENTION ANALYTICS
-- FILE: 03_sales_analysis.sql
-- DATABASE: olist_analytics
-- SCHEMA: analytics
-- PURPOSE: Sales and Revenue Analysis
-- ============================================================


-- ============================================================
-- 1. OVERALL BUSINESS KPIs
-- ============================================================

SELECT
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (
        WHERE order_status = 'delivered'
    ) AS delivered_orders,
    COUNT(*) FILTER (
        WHERE order_status = 'canceled'
    ) AS canceled_orders,
    COUNT(*) FILTER (
        WHERE order_status = 'unavailable'
    ) AS unavailable_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE order_status = 'delivered'
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS delivered_order_percentage
FROM analytics.orders;


-- ============================================================
-- 2. TOTAL PRODUCT REVENUE AND FREIGHT REVENUE
-- Only delivered orders are included.
-- ============================================================

SELECT
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    ROUND(SUM(oi.price), 2) AS total_product_revenue,
    ROUND(SUM(oi.freight_value), 2) AS total_freight_value,
    ROUND(
        SUM(oi.price + oi.freight_value), 2
    ) AS total_product_and_freight_value
FROM analytics.orders o
JOIN analytics.order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';


-- ============================================================
-- 3. MONTHLY SALES AND REVENUE TREND
-- ============================================================

SELECT
    DATE_TRUNC(
        'month', o.order_purchase_timestamp
    )::DATE AS sales_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS product_revenue,
    SUM(oi.freight_value) AS freight_revenue,
    ROUND(
        SUM(oi.price), 2
    ) AS monthly_product_revenue
FROM analytics.orders o
JOIN analytics.order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_TRUNC(
    'month', o.order_purchase_timestamp
)
ORDER BY sales_month;


-- ============================================================
-- 4. AVERAGE ORDER VALUE (AOV)
-- AOV is based on product value, excluding freight.
-- ============================================================

WITH order_revenue AS (
    SELECT
        o.order_id,
        SUM(oi.price) AS order_value
    FROM analytics.orders o
    JOIN analytics.order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
)
SELECT
    COUNT(*) AS delivered_orders,
    ROUND(SUM(order_value), 2) AS total_revenue,
    ROUND(AVG(order_value), 2) AS average_order_value
FROM order_revenue;


-- ============================================================
-- 5. TOP 10 PRODUCT CATEGORIES BY REVENUE
-- ============================================================

SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.order_item_id) AS item_id_sum,
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
GROUP BY
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )
ORDER BY category_revenue DESC
LIMIT 10;


-- ============================================================
-- 6. TOP 10 PRODUCTS BY REVENUE
-- ============================================================

SELECT
    oi.product_id,
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM analytics.order_items oi
JOIN analytics.orders o
    ON oi.order_id = o.order_id
JOIN analytics.products p
    ON oi.product_id = p.product_id
LEFT JOIN analytics.category_translation ct
    ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY
    oi.product_id,
    p.product_category_name,
    ct.product_category_name_english
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- 7. TOP 10 SELLERS BY REVENUE
-- ============================================================

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS seller_revenue
FROM analytics.sellers s
JOIN analytics.order_items oi
    ON s.seller_id = oi.seller_id
JOIN analytics.orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY seller_revenue DESC
LIMIT 10;


-- ============================================================
-- 8. STATE-WISE REVENUE ANALYSIS
-- Uses the customer's state.
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM analytics.customers c
JOIN analytics.orders o
    ON c.customer_id = o.customer_id
JOIN analytics.order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


-- ============================================================
-- 9. PAYMENT METHOD ANALYSIS
-- Payments are aggregated separately from order items.
-- ============================================================

SELECT
    op.payment_type,
    COUNT(*) AS payment_records,
    COUNT(DISTINCT op.order_id) AS unique_orders,
    ROUND(SUM(op.payment_value), 2) AS total_payment_value,
    ROUND(AVG(op.payment_value), 2) AS average_payment_value
FROM analytics.order_payments op
JOIN analytics.orders o
    ON op.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY op.payment_type
ORDER BY total_payment_value DESC;


-- ============================================================
-- 10. CUSTOMER REVENUE CONTRIBUTION
-- Uses customer_unique_id to identify actual customers.
-- ============================================================

WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_frequency,
        SUM(oi.price) AS total_revenue
    FROM analytics.customers c
    JOIN analytics.orders o
        ON c.customer_id = o.customer_id
    JOIN analytics.order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    order_frequency,
    ROUND(total_revenue, 2) AS total_revenue
FROM customer_revenue
ORDER BY total_revenue DESC
LIMIT 20;


-- ============================================================
-- 11. REPEAT CUSTOMER ANALYSIS
-- ============================================================

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM analytics.customers c
    JOIN analytics.orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (
        WHERE total_orders > 1
    ) AS repeat_customers,
    COUNT(*) FILTER (
        WHERE total_orders = 1
    ) AS one_time_customers,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE total_orders > 1
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS repeat_customer_percentage
FROM customer_orders;


-- ============================================================
-- 12. YEAR-WISE REVENUE ANALYSIS
-- ============================================================

SELECT
    EXTRACT(
        YEAR FROM o.order_purchase_timestamp
    )::INTEGER AS sales_year,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    ROUND(SUM(oi.price), 2) AS yearly_revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM analytics.orders o
JOIN analytics.order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY EXTRACT(
    YEAR FROM o.order_purchase_timestamp
)
ORDER BY sales_year;


-- ============================================================
-- 13. MONTH-OVER-MONTH REVENUE GROWTH
-- ============================================================

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC(
            'month', o.order_purchase_timestamp
        )::DATE AS sales_month,
        SUM(oi.price) AS monthly_revenue
    FROM analytics.orders o
    JOIN analytics.order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY DATE_TRUNC(
        'month', o.order_purchase_timestamp
    )
),
revenue_comparison AS (
    SELECT
        sales_month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue
    FROM monthly_sales
)
SELECT
    sales_month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        100.0 * (
            monthly_revenue - previous_month_revenue
        ) / NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_growth_percentage
FROM revenue_comparison
ORDER BY sales_month;


-- ============================================================
-- 14. DELIVERY PERFORMANCE ANALYSIS
-- ============================================================

SELECT
    CASE
        WHEN order_delivered_customer_date IS NULL
            THEN 'Not Delivered'
        WHEN order_estimated_delivery_date IS NULL
            THEN 'Unknown Estimate'
        WHEN order_delivered_customer_date
             <= order_estimated_delivery_date
            THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS total_orders,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM analytics.orders
GROUP BY
    CASE
        WHEN order_delivered_customer_date IS NULL
            THEN 'Not Delivered'
        WHEN order_estimated_delivery_date IS NULL
            THEN 'Unknown Estimate'
        WHEN order_delivered_customer_date
             <= order_estimated_delivery_date
            THEN 'On Time'
        ELSE 'Late'
    END
ORDER BY total_orders DESC;


-- ============================================================
-- 15. FREIGHT COST ANALYSIS BY CUSTOMER STATE
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.freight_value), 2) AS total_freight,
    ROUND(AVG(oi.freight_value), 2) AS average_item_freight,
    ROUND(
        SUM(oi.freight_value) /
        NULLIF(SUM(oi.price), 0) * 100,
        2
    ) AS freight_to_product_revenue_percentage
FROM analytics.customers c
JOIN analytics.orders o
    ON c.customer_id = o.customer_id
JOIN analytics.order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_freight DESC;


-- ============================================================
-- END OF SALES ANALYSIS
-- ============================================================
