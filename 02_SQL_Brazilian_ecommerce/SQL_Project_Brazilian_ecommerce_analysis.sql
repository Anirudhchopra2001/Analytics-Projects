USE brazilian_ecommerce;


SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM olist_customers_dataset
UNION ALL
SELECT 'orders', COUNT(*) FROM olist_orders_dataset
UNION ALL
SELECT 'order_items', COUNT(*) FROM olist_order_items_dataset
UNION ALL
SELECT 'order_payments', COUNT(*) FROM olist_order_payments_dataset
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM olist_order_reviews_dataset
UNION ALL
SELECT 'products', COUNT(*) FROM olist_products_dataset
UNION ALL
SELECT 'sellers', COUNT(*) FROM olist_sellers_dataset;


SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_delivered_customer_date IS NULL
             OR order_delivered_customer_date IN ('0000-00-00 00:00:00', '') THEN 1 ELSE 0 END) AS missing_delivery_date,
    SUM(CASE WHEN order_approved_at IS NULL
             OR order_approved_at IN ('0000-00-00 00:00:00', '') THEN 1 ELSE 0 END) AS missing_approval_date
FROM olist_orders_dataset;


UPDATE olist_orders_dataset
SET order_delivered_customer_date = NULL
WHERE order_delivered_customer_date = '';

ALTER TABLE olist_orders_dataset
MODIFY COLUMN order_delivered_customer_date DATETIME;


SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi 
    ON o.order_id = oi.order_id
GROUP BY order_month
ORDER BY order_month ASC;


WITH order_level AS (
    -- Ensure multi-item orders are counted as a single unique order
    SELECT
        c.customer_unique_id,
        o.order_id
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
    JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id, o.order_id
),
customer_order_counts AS (
    -- Calculate total order frequency per unique customer
    SELECT 
        customer_unique_id, 
        COUNT(order_id) AS order_count
    FROM order_level
    GROUP BY customer_unique_id
)
-- Segment customers into One-time and Repeat purchasers
SELECT
    CASE WHEN order_count > 1 THEN 'Repeat Customer' ELSE 'One-time Customer' END AS customer_type,
    COUNT(customer_unique_id) AS total_customers
FROM customer_order_counts
GROUP BY customer_type;


SELECT 
    o.order_status,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS delayed_orders
FROM olist_orders_dataset o
WHERE o.order_status = 'delivered'
GROUP BY o.order_status;


SELECT 
    t.product_category_name_english AS category_name,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS category_revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
GROUP BY category_name
ORDER BY category_revenue DESC
LIMIT 10;



SELECT
    s.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    RANK() OVER (ORDER BY SUM(oi.price) DESC) AS revenue_rank
FROM olist_sellers_dataset s
JOIN olist_order_items_dataset oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id, s.seller_state
ORDER BY revenue_rank
LIMIT 20;



