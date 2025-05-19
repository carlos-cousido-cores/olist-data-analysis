/*
===============================================================================
DATA CLEANING
===============================================================================
Purpose:
    - Create cleaned versions of raw datasets 
    - Prepare data for modeling, reporting, and analysis
===============================================================================
*/



/* ============================================================================
   Table: olist_order_reviews_dataset
   -- Description:
      - Create a cleaned table keeping only the most recent review per order
      - Ensures one review per order, even if a review_id appears across multiple orders
============================================================================ */

-- Rows: 98,673
WITH ranked_reviews AS (
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY review_answer_timestamp DESC) AS rank_review
	FROM dbo.olist_order_reviews_dataset
)
-- Create a new cleaned table with one review per order
SELECT *
INTO dbo.olist_order_reviews_dataset_clean
FROM ranked_reviews
WHERE rank_review = 1;



/* ============================================================================
   Table: product_category_name_translation
   -- Description:
     - Fix column names and remove extra row
     - Create a new table with the 3 missing categories
============================================================================ */

SELECT * 
FROM dbo.product_category_name_translation

-- Rename columns
EXEC sp_rename 'dbo.product_category_name_translation.column1', 'product_category_name', 'COLUMN'
EXEC sp_rename 'dbo.product_category_name_translation.column2', 'product_category_name_english', 'COLUMN'

-- Drop first row
DELETE FROM dbo.product_category_name_translation 
WHERE product_category_name = 'product_category_name' AND product_category_name_english = 'product_category_name_english'

-- Create a new table and add the 3 missing categories
SELECT *
INTO dbo.product_category_name_translation_complete
FROM dbo.product_category_name_translation;

INSERT INTO dbo.product_category_name_translation_complete (product_category_name, product_category_name_english)
VALUES 
    ('pc_gamer', 'pc_gamer'),
    ('portateis_cozinha_e_preparadores_de_alimentos', 'kitchen_appliances_preparers'),
    ('unknown', 'unknown');

/* ============================================================================
   Table: olist_products_dataset
   -- Description:
     - Create a cleaned product table
     - Remove 1 fully empty row (all fields NULL)
     - Replace NULLs in product_category_name with 'unknown'
     - Replace NULLs in name, description, and photo length columns with 0
     - Impute missing physical dimensions for a known product
	 - Add English product category

  -- Note: Use 'Unlisted / Missing' to distinguish products with missing category values
           from those labeled as 'unknown' in the translation table
============================================================================ */

-- Rows: 32,950
SELECT 
  product_id,
  COALESCE(p.product_category_name, 'Unlisted / Missing') AS product_category_name,
  COALESCE(t.product_category_name_english, 'Unlisted / Missing') AS product_category_name_english,
  COALESCE(product_name_lenght, 0) AS product_name_lenght,
  COALESCE(product_description_lenght, 0) AS product_description_lenght,
  COALESCE(product_photos_qty, 0) AS product_photos_qty,
  CASE WHEN product_id = '6fd08d44046ab994b96ff38ad6fcfba1' THEN 500 ELSE product_weight_g END AS product_weight_g,
  CASE WHEN product_id = '6fd08d44046ab994b96ff38ad6fcfba1' THEN 23 ELSE product_length_cm END AS product_length_cm,
  CASE WHEN product_id = '6fd08d44046ab994b96ff38ad6fcfba1' THEN 23 ELSE product_height_cm END AS product_height_cm,
  CASE WHEN product_id = '6fd08d44046ab994b96ff38ad6fcfba1' THEN 23 ELSE product_width_cm END AS product_width_cm
INTO dbo.olist_products_dataset_clean
FROM dbo.olist_products_dataset p
LEFT JOIN dbo.product_category_name_translation_complete t ON p.product_category_name = t.product_category_name
WHERE NOT (
  p.product_category_name IS NULL AND
  p.product_name_lenght IS NULL AND
  p.product_description_lenght IS NULL AND
  p.product_photos_qty IS NULL AND
  p.product_weight_g IS NULL AND
  p.product_length_cm IS NULL AND
  p.product_height_cm IS NULL AND
  p.product_width_cm IS NULL
);