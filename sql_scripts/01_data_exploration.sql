/*
===============================================================================
DATA EXPLORATION
===============================================================================
Purpose:
    - Explore the structure and content of each table in the database
    - Identify null values, duplicates, and data integrity issues
    - Understand table relationships and unique keys
===============================================================================
*/


/* ============================================================================
   Table: olist_customers_dataset
============================================================================ */

-- Preview table structure
-- Columns: customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state
SELECT TOP 50 *
FROM dbo.olist_customers_dataset; 

-- Checking null values: No null values
-- Total rows: 99,441
SELECT 
	COUNT(*) AS total_rows,
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
	SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS customer_unique_id_nulls,
	SUM(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS customer_zip_code_prefix_nulls,
	SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS customer_city_nulls,
	SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS customer_state_nulls
FROM dbo.olist_customers_dataset;

-- Checking duplicates for customer_id: No duplicates
SELECT 
	COUNT(DISTINCT customer_id) AS unique_customers
FROM dbo.olist_customers_dataset;

-- Checking duplicates for customer_unique_id: 96,096 unique customers
-- customer_unique_id is not unique, indicating that some customers have placed multiple orders
SELECT COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM dbo.olist_customers_dataset;
 
-- Top 5 states with the most customers: SP, RJ, MG, RS, PR
-- The total amount of customers by state is 96,136. This indicates that some customers are located in more than one state
-- 96,136 - 96,096 = 40 cases
SELECT 
	customer_state,
	COUNT(DISTINCT customer_unique_id) AS customer_by_state
FROM dbo.olist_customers_dataset
GROUP BY customer_state 
ORDER BY customer_by_state DESC; 

-- The overcount of 40 is caused by 39 customers:
-- 38 in 2 states (+1 each)
-- 1 in 3 states (+2)
SELECT 
	customer_unique_id,
	COUNT(DISTINCT customer_state) AS num_states
FROM dbo.olist_customers_dataset
GROUP BY customer_unique_id
HAVING COUNT(DISTINCT customer_state) > 1
ORDER BY num_states DESC;



/* ============================================================================
   Table: olist_order_items_dataset
============================================================================ */

-- Preview table structure
-- Columns: order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value
SELECT TOP 50 *
FROM dbo.olist_order_items_dataset; 

-- The price and freight_value columns were not imported properly: values are missing a decimal point (e.g., 5890 instead of 58.9)
UPDATE dbo.olist_order_items_dataset
SET 
	price = price / 100.0,
	freight_value = freight_value / 100.0;

-- Checking null values: No null values
-- Total rows: 112,650
SELECT 
	COUNT(*) AS total_rows,
	SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
	SUM(CASE WHEN order_item_id IS NULL THEN 1 ELSE 0 END) AS order_item_id_nulls,
	SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
	SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS seller_id_nulls,
	SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS shipping_limit_date_nulls,
	SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_nulls,
	SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS freight_value_nulls
FROM dbo.olist_order_items_dataset;

-- Checking duplicates for order_id: 98,666 unique orders
SELECT 
	COUNT(DISTINCT order_id) AS unique_orders
FROM dbo.olist_order_items_dataset;

-- Checking duplicates for product_id: 32,950 unique orders
SELECT 
	COUNT(DISTINCT product_id) AS unique_products
FROM dbo.olist_order_items_dataset;

-- Checking number of items per order
-- Around 90% (88863/98666) of orders have 1 item 
SELECT 
	COUNT(order_id) number_orders,
	items_per_order
FROM ( 
	SELECT 
		order_id,
		COUNT(order_item_id) AS items_per_order
	FROM dbo.olist_order_items_dataset
	GROUP BY order_id) AS order_item_counts
GROUP BY items_per_order
ORDER BY items_per_order;

-- Calculate average items per order: 1.14
SELECT
	ROUND(1.0 * COUNT(*) / COUNT(DISTINCT order_id), 2) AS avg_items_per_order
FROM dbo.olist_order_items_dataset



/* ============================================================================
   Table: olist_order_payments_dataset
============================================================================ */

-- Preview table structure
-- Columns: order_id, payment_sequential, payment_type, payment_installments, payment_value
SELECT TOP 50 *
FROM dbo.olist_order_payments_dataset
ORDER BY order_id, payment_sequential; 

-- The payment_value column was not imported properly: values are missing a decimal point (e.g., 9933 instead of 99.33)
UPDATE dbo.olist_order_payments_dataset
SET payment_value = payment_value / 100.0;

-- Checking null values: No null values
-- Total rows: 103,886
SELECT 
	COUNT(*) AS total_rows,
	SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
	SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END) AS payment_sequential_nulls,
	SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS payment_type_nulls,
	SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS payment_installments_nulls,
	SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS payment_value_nulls
FROM dbo.olist_order_payments_dataset;

-- Checking duplicates for order_id: 99,440 unique orders
SELECT 
	COUNT(DISTINCT order_id) AS unique_orders
FROM dbo.olist_order_payments_dataset;


/* ============================================================================
   Table: olist_order_reviews_dataset
============================================================================ */

-- Preview table structure
-- Columns: review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp
-- NOTE: 
-- review_creation_date shows the date in which the satisfaction survey was sent to the customer
-- review_answer_timestamp shows satisfaction survey answer timestamp
SELECT TOP 50 *
FROM dbo.olist_order_reviews_dataset; 

-- Checking null values: not all reviews have comments
-- Total rows: 99,224
SELECT 
	COUNT(*) AS total_rows,
	SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS review_id_nulls,
	SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
	SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS review_score_nulls,
	SUM(CASE WHEN review_comment_title IS NULL THEN 1 ELSE 0 END) AS review_comment_title_nulls,
	SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS review_comment_message_nulls,
	SUM(CASE WHEN review_creation_date IS NULL THEN 1 ELSE 0 END) AS review_creation_date_nulls,
	SUM(CASE WHEN review_answer_timestamp IS NULL THEN 1 ELSE 0 END) AS review_answer_timestamp_nulls
FROM dbo.olist_order_reviews_dataset;

-- Checking duplicates for review_id: 98,410 unique reviews
SELECT 
	COUNT(DISTINCT review_id) AS unique_reviews
FROM dbo.olist_order_reviews_dataset;

-- Checking duplicates for order_id: 98,673 unique orders
SELECT 
	COUNT(DISTINCT order_id) AS unique_orders
FROM dbo.olist_order_reviews_dataset;

-- Checking multiple reviews per order: 547 orders have have more than 1 review
SELECT 
    order_id,
    COUNT(*) AS num_reviews
FROM dbo.olist_order_reviews_dataset
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY num_reviews DESC;

-- Inspecting an order with multiple reviews
SELECT *
FROM dbo.olist_order_reviews_dataset
WHERE order_id = '03c939fd7fd3b38f8485a0f95798f1f6'; -- in this example, one order has 3 reviews assigned

-- Duplicate reviews: 789 unique reviews were used in more than one order
SELECT 
	review_id,
	COUNT(review_id) AS dup_reviews
FROM dbo.olist_order_reviews_dataset
GROUP BY review_id
HAVING COUNT(review_id) > 1
ORDER BY dup_reviews DESC;

-- Example of a duplicate review_id
SELECT *
FROM dbo.olist_order_reviews_dataset
WHERE review_id = '69a1068c3128a14994e3e422e4539e04'; -- the same review is used in 3 different orders


/* ============================================================================
   Table: olist_orders_dataset
============================================================================ */

-- Preview table structure
-- Columns: order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, 
--          order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date
SELECT TOP 50 *
FROM dbo.olist_orders_dataset; 

-- Checking null values: Some null values in approval and delivery timestamps
-- Total rows: 99,441
SELECT 
	COUNT(*) AS total_rows,
	SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
	SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS order_status_nulls,
	SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS order_purchase_timestamp_nulls,
	SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS order_approved_at_nulls,
	SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS order_delivered_carrier_date_nulls,
	SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS order_delivered_customer_date_nulls,
	SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS order_estimated_delivery_date_nulls
FROM dbo.olist_orders_dataset;

-- Checking duplicates for order_id: 99,441 unique orders
SELECT 
	COUNT(DISTINCT order_id) AS unique_orders
FROM dbo.olist_orders_dataset;

-- Checking timeframe: from 2016-09-04 to 2018-10-17
SELECT 
   MIN(order_purchase_timestamp) AS first_purchase,
   MAX(order_purchase_timestamp) AS last_purchase
FROM dbo.olist_orders_dataset;

/****** Order Status ******/
-- 8 types of order status: approved, delivered, created, processing, invoiced, unavailable, canceled, shipped
-- Most orders were delivered: 96,478 (97%)
-- Cancelled and unavailable orders: 1,234 (1.2%)
SELECT 
	order_status,
	COUNT(*) AS total_orders
FROM dbo.olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC; 

/*
- Checking orders that have not being delivered yet to customers
- ISSUE: 8 order marked as delived without a delivery date timestamp
- Cancelled and unavailable orders are 1,228. There are 6 canceled or unavailable (1,234 - 1,228) orders 
  with a delivered to customer timestamp
*/
SELECT 
	order_status,
	COUNT(*) AS not_deliverd_orders
FROM dbo.olist_orders_dataset
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY not_deliverd_orders DESC; 

-- Finding if the other 6 orders were canceled or unavailable
-- Answer: canceled
SELECT *
FROM dbo.olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL AND
      (order_status = 'canceled' OR
	  order_status = 'unavailable')


/****** Checking Negative Time Durations ******/ 
-- 1. From purchase to approval: Payment processing time (how fast an order is confirmed)
SELECT 
	order_id,
	customer_id,
	order_status,
	order_purchase_timestamp,
	order_approved_at,
	order_delivered_carrier_date,
	order_delivered_customer_date,
	DATEDIFF(MINUTE, order_purchase_timestamp, order_approved_at) AS purchase_to_approval_min
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered' AND DATEDIFF(MINUTE, order_purchase_timestamp, order_approved_at) < 0; -- 0 cases 

-- 2. From approval to carrier: Preparation & handling time (before shipping)
SELECT 
	order_id,
	customer_id,
	order_status,
	order_purchase_timestamp,
	order_approved_at,
	order_delivered_carrier_date,
	order_delivered_customer_date,
    DATEDIFF(MINUTE, order_approved_at, order_delivered_carrier_date) AS approval_to_carrier_min
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered' AND DATEDIFF(MINUTE, order_approved_at, order_delivered_carrier_date) < 0; -- 1349 cases

-- 3. From carrier to customer: Shipping time (transit duration)
SELECT 
	order_id,
	customer_id,
	order_status,
	order_purchase_timestamp,
	order_approved_at,
	order_delivered_carrier_date,
	order_delivered_customer_date,
    DATEDIFF(MINUTE, order_delivered_carrier_date, order_delivered_customer_date) AS carrier_to_customer_min
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered' AND DATEDIFF(MINUTE, order_delivered_carrier_date, order_delivered_customer_date) < 0; -- 23 cases


/****** Incomplete Delivery Records ******/
-- 1. Delivered orders missing approval date
SELECT *
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered' AND order_approved_at IS NULL -- 14 cases

-- 2. Delivered orders missing shipping date
SELECT *
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered' AND order_delivered_carrier_date IS NULL -- 2 cases

-- 3. Delivered orders missing delivery date
SELECT *
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL -- 8 cases

-- ============================================================================
-- Finding out more about the negative timestamps
-- Description:
    -- Identify and quantify data quality issues related to delivery timelines
    -- Explore negative time intervals (e.g., shipment before approval)
    -- Analyze trends by month, year, and geography (customer and seller states)
-- ============================================================================

/**************** Preparation Time ****************/

-- 1,349 cases total with negative negative preparation time

-- Total bad orders by year: 2018 is the year with the most cases 
SELECT 
	YEAR(order_purchase_timestamp) AS year_purchase,
	COUNT(order_id) AS total_orders
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered' AND DATEDIFF(MINUTE, order_approved_at, order_delivered_carrier_date) < 0
GROUP BY YEAR(order_purchase_timestamp);

-- Total bad orders by month: July, April, and June are the peak issue months
SELECT 
	MONTH(order_purchase_timestamp) AS month_purchase,
	COUNT(order_id) AS total_orders
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered' AND DATEDIFF(MINUTE, order_approved_at, order_delivered_carrier_date) < 0
GROUP BY MONTH(order_purchase_timestamp)
ORDER BY total_orders DESC;

--------------------------------------------
-- Comparison of all orders vs bad orders --
--------------------------------------------

-- All delivered orders per month and year
WITH all_orders AS (
	SELECT
		COUNT(order_id) as total_orders,
		FORMAT(order_purchase_timestamp, 'MMMM-yyyy') AS date_purchase
	FROM dbo.olist_orders_dataset
	WHERE order_status = 'delivered'
	GROUP BY FORMAT(order_purchase_timestamp, 'MMMM-yyyy')
),
-- Orders with negative preparation time: shipment before approval
bad_orders AS (
SELECT
	COUNT(order_id) as total_bad_orders,
	FORMAT(order_purchase_timestamp, 'MMMM-yyyy') AS date_purchase
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered' AND
	  DATEDIFF(MINUTE, order_approved_at, order_delivered_carrier_date) < 0
GROUP BY FORMAT(order_purchase_timestamp, 'MMMM-yyyy')
)
-- Final comparison: % of bad prep-time orders per month and year
SELECT 
	a.date_purchase,
	a.total_orders,
	b.total_bad_orders,
	ROUND(100.0 * COALESCE(b.total_bad_orders, 0) / a.total_orders, 2) AS prcnt_bad
FROM all_orders AS a
LEFT JOIN bad_orders as b ON a.date_purchase = b.date_purchase
WHERE COALESCE(b.total_bad_orders, 0) > 0
ORDER BY prcnt_bad DESC;


/**************** Shipping Time ****************/

-- 23 total cases with negative shipping time

-- Total bad orders by year: 2018 is the year with the most cases 
SELECT 
	YEAR(order_purchase_timestamp) AS year_purchase,
	COUNT(order_id) AS total_orders
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered' AND DATEDIFF(MINUTE, order_delivered_carrier_date, order_delivered_customer_date) < 0
GROUP BY YEAR(order_purchase_timestamp);

-- Total bad shipping orders by month: July and October are the peak issue months
SELECT 
	MONTH(order_purchase_timestamp) AS month_purchase,
	COUNT(order_id) AS total_orders
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered' AND DATEDIFF(MINUTE, order_delivered_carrier_date, order_delivered_customer_date) < 0
GROUP BY MONTH(order_purchase_timestamp)
ORDER BY total_orders DESC;

--------------------------------------------
-- Comparison of all orders vs bad orders --
--------------------------------------------

-- All delivered orders per month and year
WITH all_orders AS (
	SELECT
		COUNT(order_id) as total_orders,
		FORMAT(order_purchase_timestamp, 'MMMM-yyyy') AS date_purchase
	FROM dbo.olist_orders_dataset
	WHERE order_status = 'delivered'
	GROUP BY FORMAT(order_purchase_timestamp, 'MMMM-yyyy')
),
-- Orders with negative shipping time: delivered before being shipped
bad_orders AS (
SELECT
	COUNT(order_id) as total_bad_orders,
	FORMAT(order_purchase_timestamp, 'MMMM-yyyy') AS date_purchase
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered' AND
	  DATEDIFF(MINUTE, order_delivered_carrier_date, order_delivered_customer_date) < 0
GROUP BY FORMAT(order_purchase_timestamp, 'MMMM-yyyy')
)
-- Final comparison: % of bad shipping orders per month and year
SELECT 
	a.date_purchase,
	a.total_orders,
	b.total_bad_orders,
	ROUND(100.0 * COALESCE(b.total_bad_orders, 0) / a.total_orders, 2) AS prcnt_bad
FROM all_orders AS a
LEFT JOIN bad_orders as b ON a.date_purchase = b.date_purchase
WHERE COALESCE(b.total_bad_orders, 0) > 0
ORDER BY prcnt_bad DESC;


/**************** Preparation Time by Customer Geography ****************/

-- Top 5 states by number of customers: SP, RJ, MG, RS, PR
SELECT
	customer_state,
	COUNT(DISTINCT customer_unique_id) AS total_unique_customers
FROM dbo.olist_customers_dataset
GROUP BY customer_state 
ORDER BY total_unique_customers DESC;

-- Same top states show most preparation time issues
SELECT 
	c.customer_state,
	COUNT(*) AS num_issues
FROM dbo.olist_customers_dataset AS c
INNER JOIN olist_orders_dataset AS o ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered' AND DATEDIFF(MINUTE, o.order_approved_at, o.order_delivered_carrier_date) < 0
GROUP BY c.customer_state
ORDER BY num_issues DESC;

--------------------------------------------
-- Comparison of all orders vs bad orders --
--------------------------------------------

WITH customer_volume AS (
	SELECT 
		c.customer_state,
		COUNT(DISTINCT o.order_id) AS total_orders
	FROM dbo.olist_customers_dataset c
	INNER JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
	WHERE o.order_status = 'delivered'
	GROUP BY c.customer_state
),
bad_orders AS (
	SELECT 
		c.customer_state,
		COUNT(DISTINCT o.order_id) AS total_bad_orders
	FROM dbo.olist_customers_dataset c
	INNER JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
	WHERE o.order_status = 'delivered' AND DATEDIFF(MINUTE, o.order_approved_at, o.order_delivered_carrier_date) < 0
	GROUP BY c.customer_state
)
SELECT 
	cv.customer_state,
	cv.total_orders,
	COALESCE(bo.total_bad_orders, 0) AS total_bad_orders,
	ROUND(100.0 * COALESCE(bo.total_bad_orders, 0) / cv.total_orders, 2) AS prcnt_bad
FROM customer_volume cv
LEFT JOIN bad_orders bo ON cv.customer_state = bo.customer_state
WHERE COALESCE(bo.total_bad_orders, 0) > 0
ORDER BY prcnt_bad DESC;


/**************** Preparation Time by Seller Geography ****************/

-- Top 5 states by number of sellers: SP, PR, MG, SC, RJ
SELECT
	seller_state,
	COUNT(seller_id) AS total_sellers
FROM dbo.olist_sellers_dataset
GROUP BY seller_state 
ORDER BY total_sellers DESC;

-- Same top states show the most preparation time issues
-- However, we get 1,360 cases instead of 1,349 because orders with more than one item from different seller states are double-counted
SELECT SUM(total_bad_orders) AS total_issues
FROM (
SELECT 
	s.seller_state,
	COUNT(DISTINCT oi.order_id) AS total_bad_orders
FROM dbo.olist_orders_dataset o
INNER JOIN dbo.olist_order_items_dataset oi ON o.order_id = oi.order_id
INNER JOIN dbo.olist_sellers_dataset s ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered' AND DATEDIFF(MINUTE, o.order_approved_at, o.order_delivered_carrier_date) < 0 
GROUP BY seller_state) t;

-- Solving the overcounting issue
-- Use order_item_id = 1 to assign a single seller per order
SELECT 
	s.seller_state,
	COUNT(DISTINCT oi.order_id) AS total_bad_orders
FROM dbo.olist_orders_dataset o
INNER JOIN dbo.olist_order_items_dataset oi ON o.order_id = oi.order_id
INNER JOIN dbo.olist_sellers_dataset s ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered' AND 
	  DATEDIFF(MINUTE, o.order_approved_at, o.order_delivered_carrier_date) < 0 AND 
	  order_item_id = 1
GROUP BY seller_state
ORDER BY total_bad_orders DESC;

--------------------------------------------
-- Comparison of all orders vs bad orders --
--------------------------------------------

WITH seller_volume AS (
	SELECT 
		s.seller_state,
		COUNT(DISTINCT oi.order_id) AS total_orders
	FROM dbo.olist_orders_dataset o
	INNER JOIN dbo.olist_order_items_dataset oi ON o.order_id = oi.order_id
	INNER JOIN dbo.olist_sellers_dataset s ON oi.seller_id = s.seller_id
	WHERE o.order_status = 'delivered' AND 
		  order_item_id = 1
	GROUP BY seller_state
),
bad_orders AS (
	SELECT 
		s.seller_state,
		COUNT(DISTINCT oi.order_id) AS total_bad_orders
	FROM dbo.olist_orders_dataset o
	INNER JOIN dbo.olist_order_items_dataset oi ON o.order_id = oi.order_id
	INNER JOIN dbo.olist_sellers_dataset s ON oi.seller_id = s.seller_id
	WHERE o.order_status = 'delivered' AND 
		  DATEDIFF(MINUTE, o.order_approved_at, o.order_delivered_carrier_date) < 0 AND 
		  order_item_id = 1
	GROUP BY seller_state
)
SELECT 
	sv.seller_state,
	sv.total_orders,
	COALESCE(bo.total_bad_orders, 0) AS total_bad_orders,
	(1.0 * COALESCE(bo.total_bad_orders, 0) / sv.total_orders) * 100 AS prcnt_bad
FROM seller_volume sv
LEFT JOIN bad_orders bo ON sv.seller_state = bo.seller_state
WHERE COALESCE(bo.total_bad_orders, 0) > 0
ORDER BY prcnt_bad DESC;


/* ============================================================================
   Table: olist_products_dataset
============================================================================ */

-- Preview table structure
-- Columns: product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, 
--          product_weight_g, product_length_cm, product_height_cm, product_width_cm
SELECT TOP 50 * 
FROM dbo.olist_products_dataset; 

-- Checking null values. There are:
-- 610 rows missing all category/title/description/photo columns
-- 2 rows missing physical dimension fields
-- Total rows: 32,951
SELECT 
	COUNT(*) AS total_rows,
	SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
	SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS product_category_name_nulls,
	SUM(CASE WHEN product_name_lenght IS NULL THEN 1 ELSE 0 END) AS product_name_lenght_nulls,
	SUM(CASE WHEN product_description_lenght IS NULL THEN 1 ELSE 0 END) AS product_description_lenght_nulls,
	SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) AS product_photos_qty_nulls,
	SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS product_weight_g_nulls,
	SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS order_product_length_cm_nulls,
	SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS product_height_cm_nulls,
	SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS product_width_cm_nulls
FROM dbo.olist_products_dataset;

-- Checking products with no information: 1 case for product_id '5eb564652db742ff8f28759cd8d2652a'
SELECT *
FROM dbo.olist_products_dataset
WHERE product_category_name IS NULL AND 
	  product_name_lenght IS NULL AND 
	  product_description_lenght IS NULL AND
	  product_photos_qty IS NULL AND
	  product_weight_g IS NULL AND
	  product_length_cm IS NULL AND
	  product_height_cm IS NULL AND
	  product_width_cm IS NULL

-- Verifying that all 610 rows with missing category/title/desc/photo match together: It is the case
SELECT COUNT(*)
FROM dbo.olist_products_dataset
WHERE product_category_name IS NULL
  AND product_name_lenght IS NULL
  AND product_description_lenght IS NULL
  AND product_photos_qty IS NULL;

-- Checking if these 610 products appear in olist_order_items_dataset: All 610 were used
SELECT COUNT(DISTINCT product_id)
FROM dbo.olist_order_items_dataset
WHERE product_id IN (
    SELECT product_id
    FROM dbo.olist_products_dataset
    WHERE product_category_name IS NULL
);

-- Those 610 products don't have a match in the table product_category_name_translation
SELECT *
FROM dbo.olist_products_dataset p
LEFT JOIN dbo.product_category_name_translation t ON t.product_category_name = p.product_category_name
WHERE p.product_category_name IS NULL

/* Finding similar product with same content metadata to possibly impute dimensions:
- product_id = '09ff539a621711667c43eba6a3bd8466'
- product_category_name = 'bebes'
- product_name_lenght = 60
- product_description_lenght = 865 
*/
SELECT * 
FROM dbo.olist_products_dataset
WHERE product_weight_g IS NULL;

/* Matched product for imputation:
- product_id = '6fd08d44046ab994b96ff38ad6fcfba1'
- product_weight_g = 500
- product_length_cm = 23
- product_height_cm = 23
- product_width_cm = 23
*/
SELECT * 
FROM dbo.olist_products_dataset
WHERE product_category_name = 'bebes' AND 
	  product_name_lenght = 60 AND 
	  product_description_lenght = 865;

-- Checking duplicates for product_id: No duplicates
SELECT 
	COUNT(DISTINCT product_id) AS unique_products
FROM dbo.olist_products_dataset;



/* ============================================================================
   Table: olist_sellers_dataset
============================================================================ */

-- Preview table structure
-- Columns: seller_id, seller_zip_code_prefix, seller_city, seller_state
SELECT TOP 50 *
FROM dbo.olist_sellers_dataset; 

-- Checking null values: No nulls
-- Total rows: 3,095
SELECT 
	COUNT(*) AS total_rows,
	SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS seller_id_nulls,
	SUM(CASE WHEN seller_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS seller_zip_code_prefix_nulls,
	SUM(CASE WHEN seller_city IS NULL THEN 1 ELSE 0 END) AS seller_city_nulls,
	SUM(CASE WHEN seller_state IS NULL THEN 1 ELSE 0 END) AS seller_state_nulls
FROM dbo.olist_sellers_dataset;

-- Checking duplicates for seller_id: No duplicates
SELECT 
	COUNT(DISTINCT seller_id) AS unique_sellers
FROM dbo.olist_sellers_dataset;



/* ============================================================================
   Table: product_category_name_translation
============================================================================ */

-- Preview table structure
-- The first row should be the column name
SELECT * 
FROM dbo.product_category_name_translation;

-- There are 622 cases where the English translation is missing for: 
-- pc_gamer, portateis_cozinha_e_preparadores_de_alimentos, unknown
SELECT
	DISTINCT p.product_category_name,
	COUNT(*) AS missing_translation
FROM dbo.olist_products_dataset_clean p
LEFT JOIN dbo.product_category_name_translation t ON p.product_category_name = t.product_category_name
WHERE t.product_category_name_english IS NULL
GROUP BY p.product_category_name;
