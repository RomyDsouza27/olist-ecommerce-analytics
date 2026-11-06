SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer_id,
    COUNT(*) FILTER (WHERE customer_unique_id IS NULL) AS missing_unique_id
FROM staging.customers;

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM staging.orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM staging.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS unmatched_order_items
FROM staging.order_items oi
LEFT JOIN staging.orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS unmatched_orders
FROM staging.orders o
LEFT JOIN staging.customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM staging.orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 7. Check order items without matching products
SELECT COUNT(*) AS unmatched_products
FROM staging.order_items oi
LEFT JOIN staging.products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- 8. Check order items without matching sellers
SELECT COUNT(*) AS unmatched_sellers
FROM staging.order_items oi
LEFT JOIN staging.sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- 9. Check payments without matching orders
SELECT COUNT(*) AS unmatched_payments
FROM staging.order_payments op
LEFT JOIN staging.orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 10. Check reviews without matching orders
SELECT COUNT(*) AS unmatched_reviews
FROM staging.order_reviews r
LEFT JOIN staging.orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 11. Check invalid review scores
SELECT
    COUNT(*) AS invalid_review_scores
FROM staging.order_reviews
WHERE review_score IS NULL
   OR review_score NOT BETWEEN 1 AND 5;

-- 12. Check invalid order-item prices
SELECT
    COUNT(*) AS invalid_prices
FROM staging.order_items
WHERE price IS NULL OR price < 0;

-- 13. Check invalid freight values
SELECT
    COUNT(*) AS invalid_freight_values
FROM staging.order_items
WHERE freight_value IS NULL OR freight_value < 0;

-- 14. Check invalid payment values
SELECT
    COUNT(*) AS invalid_payment_values
FROM staging.order_payments
WHERE payment_value IS NULL OR payment_value < 0;

-- 15. Check order dates occurring after delivery dates
SELECT COUNT(*) AS invalid_order_dates
FROM staging.orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp >
      order_delivered_customer_date;

-- 16. Check missing purchase timestamps
SELECT COUNT(*) AS missing_purchase_dates
FROM staging.orders
WHERE order_purchase_timestamp IS NULL;


-- 17. Duplicate product IDs
SELECT product_id, COUNT(*) AS occurrences
FROM staging.products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- 18. Duplicate seller IDs
SELECT seller_id, COUNT(*) AS occurrences
FROM staging.sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

-- 19. Duplicate order-item composite keys
SELECT order_id, order_item_id, COUNT(*) AS occurrences
FROM staging.order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- 20. Duplicate payment composite keys
SELECT order_id, payment_sequential, COUNT(*) AS occurrences
FROM staging.order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

-- 21. Duplicate category translation keys
SELECT product_category_name, COUNT(*) AS occurrences
FROM staging.category_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;

-- 22. Check duplicate review IDs (investigation only)
SELECT review_id, COUNT(*) AS occurrences
FROM staging.order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 20;


-- 23. Inspect repeated review IDs
SELECT
    COUNT(*) AS repeated_review_ids,
    SUM(cnt) AS total_records_in_groups,
    MAX(cnt) AS maximum_repetitions
FROM (
    SELECT COUNT(*) AS cnt
    FROM staging.order_reviews
    GROUP BY review_id
    HAVING COUNT(*) > 1
) x;

-- 24. Count distinct orders per repeated review ID
SELECT
    COUNT(*) AS repeated_ids,
    COUNT(*) FILTER (WHERE distinct_orders > 1)
        AS ids_used_across_multiple_orders,
    COUNT(*) FILTER (WHERE distinct_orders = 1)
        AS ids_repeated_within_same_order
FROM (
    SELECT
        review_id,
        COUNT(*) AS total_records,
        COUNT(DISTINCT order_id) AS distinct_orders
    FROM staging.order_reviews
    GROUP BY review_id
    HAVING COUNT(*) > 1
) x;

-- 25. Check exact duplicate review records
SELECT
    COUNT(*) AS duplicated_record_groups,
    COALESCE(SUM(cnt - 1), 0) AS extra_duplicate_rows
FROM (
    SELECT COUNT(*) AS cnt
    FROM staging.order_reviews
    GROUP BY
        review_id,
        order_id,
        review_score,
        review_creation_date,
        review_answer_timestamp
    HAVING COUNT(*) > 1
) x;

SELECT COUNT(*) AS duplicate_review_order_pairs
FROM (
    SELECT review_id, order_id
    FROM staging.order_reviews
    GROUP BY review_id, order_id
    HAVING COUNT(*) > 1
) x;