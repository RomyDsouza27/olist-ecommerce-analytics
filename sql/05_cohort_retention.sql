
DROP TABLE IF EXISTS analytics.customer_cohort_retention;

CREATE TABLE analytics.customer_cohort_retention AS

WITH delivered_orders AS (
    SELECT
        o.order_id,
        c.customer_unique_id,
        DATE_TRUNC('month', o.order_purchase_timestamp)::date
            AS purchase_month
    FROM analytics.orders o
    JOIN analytics.customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp IS NOT NULL
),

customer_first_purchase AS (
    SELECT
        customer_unique_id,
        MIN(purchase_month) AS cohort_month
    FROM delivered_orders
    GROUP BY customer_unique_id
),

customer_activity AS (
    SELECT DISTINCT
        customer_unique_id,
        purchase_month
    FROM delivered_orders
),

cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(*) AS cohort_customers
    FROM customer_first_purchase
    GROUP BY cohort_month
),

cohort_activity AS (
    SELECT
        fp.cohort_month,
        ca.purchase_month,
        (
            (EXTRACT(YEAR FROM ca.purchase_month)
             - EXTRACT(YEAR FROM fp.cohort_month)) * 12
            +
            (EXTRACT(MONTH FROM ca.purchase_month)
             - EXTRACT(MONTH FROM fp.cohort_month))
        )::integer AS months_since_first_purchase,
        ca.customer_unique_id
    FROM customer_first_purchase fp
    JOIN customer_activity ca
        ON fp.customer_unique_id = ca.customer_unique_id
    WHERE ca.purchase_month >= fp.cohort_month
),

cohort_counts AS (
    SELECT
        cohort_month,
        months_since_first_purchase,
        COUNT(DISTINCT customer_unique_id) AS active_customers
    FROM cohort_activity
    GROUP BY cohort_month, months_since_first_purchase
),

max_month AS (
    SELECT MAX(purchase_month) AS last_purchase_month
    FROM delivered_orders
),

cohort_grid AS (
    SELECT
        cs.cohort_month,
        cs.cohort_customers,
        gs.month_number AS months_since_first_purchase
    FROM cohort_sizes cs
    CROSS JOIN max_month mm
    CROSS JOIN LATERAL GENERATE_SERIES(
        0,
        (
            (EXTRACT(YEAR FROM mm.last_purchase_month)
             - EXTRACT(YEAR FROM cs.cohort_month)) * 12
            +
            (EXTRACT(MONTH FROM mm.last_purchase_month)
             - EXTRACT(MONTH FROM cs.cohort_month))
        )::integer
    ) AS gs(month_number)
)

SELECT
    cg.cohort_month,
    cg.months_since_first_purchase,
    cg.cohort_customers,
    COALESCE(cc.active_customers, 0) AS active_customers,
    ROUND(
        100.0 * COALESCE(cc.active_customers, 0)
        / NULLIF(cg.cohort_customers, 0),
        2
    ) AS retention_rate_pct
FROM cohort_grid cg
LEFT JOIN cohort_counts cc
    ON cg.cohort_month = cc.cohort_month
   AND cg.months_since_first_purchase =
       cc.months_since_first_purchase;

CREATE INDEX idx_cohort_month
    ON analytics.customer_cohort_retention(cohort_month);

CREATE INDEX idx_cohort_period
    ON analytics.customer_cohort_retention(
        months_since_first_purchase
    );

ANALYZE analytics.customer_cohort_retention;


-- 1. Check total cohort records and cohorts
SELECT
    COUNT(*) AS total_cohort_records,
    COUNT(DISTINCT cohort_month) AS total_cohorts,
    MAX(months_since_first_purchase) AS maximum_months_observed
FROM analytics.customer_cohort_retention;


-- 2. Correct weighted retention by month
SELECT
    months_since_first_purchase,
    SUM(active_customers) AS total_returning_customers,
    SUM(cohort_customers) AS total_eligible_cohort_customers,
    ROUND(
        100.0 * SUM(active_customers)
        / NULLIF(SUM(cohort_customers), 0),
        2
    ) AS weighted_retention_pct
FROM analytics.customer_cohort_retention
WHERE months_since_first_purchase BETWEEN 1 AND 3
GROUP BY months_since_first_purchase
ORDER BY months_since_first_purchase;


-- 3. View the full cohort retention matrix
SELECT
    cohort_month,
    months_since_first_purchase,
    cohort_customers,
    active_customers,
    retention_rate_pct
FROM analytics.customer_cohort_retention
ORDER BY cohort_month, months_since_first_purchase;


-- 4. Month-1 retention by cohort
SELECT
    cohort_month,
    cohort_customers,
    active_customers,
    retention_rate_pct
FROM analytics.customer_cohort_retention
WHERE months_since_first_purchase = 1
ORDER BY cohort_month;

SELECT
    cohort_month,
    months_since_first_purchase,
    cohort_customers,
    active_customers,
    retention_rate_pct
FROM analytics.customer_cohort_retention
ORDER BY cohort_month, months_since_first_purchase
LIMIT 20;


SELECT
    MIN(retention_rate_pct) AS minimum_retention,
    MAX(retention_rate_pct) AS maximum_retention,
    AVG(retention_rate_pct) AS average_retention
FROM analytics.customer_cohort_retention;