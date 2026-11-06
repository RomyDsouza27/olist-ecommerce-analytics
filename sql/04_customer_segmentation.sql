
-- ============================================================
-- PROJECT: OLIST E-COMMERCE CUSTOMER BEHAVIOUR ANALYTICS
-- FILE: 04_customer_segmentation.sql
-- PURPOSE: RFM CUSTOMER SEGMENTATION
-- DATABASE: olist_analytics
-- ============================================================

-- STEP 1: Remove previous RFM table if it exists

DROP TABLE IF EXISTS analytics.customer_rfm;


-- STEP 2: Calculate customer-level RFM metrics

CREATE TABLE analytics.customer_rfm AS

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        SUM(oi.price) AS order_value
    FROM analytics.orders o
    JOIN analytics.customers c
        ON o.customer_id = c.customer_id
    JOIN analytics.order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp
),

customer_metrics AS (
    SELECT
        customer_unique_id,

        MAX(order_purchase_timestamp) AS last_purchase_date,

        COUNT(DISTINCT order_id) AS frequency,

        SUM(order_value) AS monetary,

        (
            SELECT MAX(order_purchase_timestamp) + INTERVAL '1 day'
            FROM analytics.orders
            WHERE order_status = 'delivered'
        ) AS analysis_date

    FROM customer_orders
    GROUP BY customer_unique_id
),

rfm_values AS (
    SELECT
        customer_unique_id,
        last_purchase_date,
        analysis_date,

        (analysis_date::date - last_purchase_date::date)
            AS recency,

        frequency,

        ROUND(monetary::numeric, 2) AS monetary

    FROM customer_metrics
),

rfm_scores AS (
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY recency DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY monetary ASC
        ) AS m_score

    FROM rfm_values
)

SELECT
    customer_unique_id,
    last_purchase_date,
    analysis_date,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,

    CONCAT(r_score, f_score, m_score) AS rfm_score,

    CASE

        WHEN r_score >= 4
             AND f_score >= 4
             AND m_score >= 4
            THEN 'Champions'

        WHEN r_score >= 3
             AND f_score >= 4
            THEN 'Loyal Customers'

        WHEN r_score >= 4
             AND f_score BETWEEN 2 AND 3
            THEN 'Potential Loyalists'

        WHEN r_score = 5
             AND f_score = 1
            THEN 'Recent Customers'

        WHEN r_score = 4
             AND f_score = 1
            THEN 'Promising'

        WHEN r_score BETWEEN 2 AND 3
             AND f_score BETWEEN 2 AND 3
            THEN 'Need Attention'

        WHEN r_score <= 2
             AND f_score >= 3
            THEN 'At Risk'

        WHEN r_score <= 2
             AND f_score <= 2
            THEN 'Hibernating'

        ELSE 'Others'

    END AS customer_segment

FROM rfm_scores;


-- STEP 3: Create indexes for faster analysis

CREATE INDEX idx_customer_rfm_unique_id
ON analytics.customer_rfm(customer_unique_id);

CREATE INDEX idx_customer_rfm_segment
ON analytics.customer_rfm(customer_segment);


-- STEP 4: Overall RFM summary

SELECT
    COUNT(*) AS total_customers,
    ROUND(AVG(recency), 2) AS average_recency_days,
    ROUND(AVG(frequency), 2) AS average_frequency,
    ROUND(AVG(monetary), 2) AS average_customer_spending
FROM analytics.customer_rfm;


-- STEP 5: Customer segment distribution

SELECT
    customer_segment,
    COUNT(*) AS total_customers,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage,

    ROUND(SUM(monetary), 2) AS total_revenue,

    ROUND(AVG(monetary), 2) AS average_customer_value

FROM analytics.customer_rfm

GROUP BY customer_segment

ORDER BY total_customers DESC;


-- STEP 6: Top 20 valuable customers

SELECT
    customer_unique_id,
    recency,
    frequency,
    monetary,
    rfm_score,
    customer_segment

FROM analytics.customer_rfm

ORDER BY monetary DESC

LIMIT 20;


-- STEP 7: Customers with high purchase frequency

SELECT
    customer_unique_id,
    frequency,
    monetary,
    recency,
    customer_segment

FROM analytics.customer_rfm

WHERE frequency >= 2

ORDER BY frequency DESC, monetary DESC

LIMIT 20;


-- STEP 8: At-risk customers

SELECT
    customer_unique_id,
    recency,
    frequency,
    monetary,
    rfm_score,
    customer_segment

FROM analytics.customer_rfm

WHERE customer_segment = 'At Risk'

ORDER BY monetary DESC

LIMIT 20;


-- STEP 9: Verify customer segmentation

SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(recency), 2) AS avg_recency,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary

FROM analytics.customer_rfm

GROUP BY customer_segment

ORDER BY customer_count DESC;

SELECT COUNT(*) FROM analytics.customer_rfm;
SELECT *
FROM analytics.customer_rfm
LIMIT 10;

SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(SUM(monetary), 2) AS revenue
FROM analytics.customer_rfm
GROUP BY customer_segment
ORDER BY revenue DESC;
-- ============================================================
-- END OF CUSTOMER SEGMENTATION ANALYSIS
-- ============================================================
