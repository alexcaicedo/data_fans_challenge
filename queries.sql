
-- 1) Which product categories have the most sales?
WITH product_sales AS (
    SELECT
        product_category_name_english,
        SUM(price) AS sales
    FROM
        benvindo.items AS a
    LEFT JOIN (
        SELECT
            benvindo.products.product_id,
            benvindo.product_category_name_translation.product_category_name_english
        FROM
            benvindo.products
        LEFT JOIN
            benvindo.product_category_name_translation
        ON
            benvindo.products.product_category_name = benvindo.product_category_name_translation.product_category_name
        WHERE
            benvindo.products.product_category_name IS NOT NULL
    ) b
    ON
        a.product_id = b.product_id
    GROUP BY
        product_category_name_english
),
total_sales AS (
    SELECT
        SUM(sales) AS total_price
    FROM
        product_sales
),
sales_pct AS (
    SELECT
        product_category_name_english,
        sales,
        (sales / total_price) * 100 AS sales_percentage
    FROM
        product_sales, total_sales
),
sales_pct_cummulative AS (
    SELECT
        product_category_name_english,
        sales,
        sales_percentage,
        SUM(sales_percentage) OVER (ORDER BY sales_percentage DESC) AS cummulative_sales_percentage
    FROM
        sales_pct
),
abc AS (
    SELECT
        product_category_name_english AS product_category,
        sales,
        sales_percentage,
        cummulative_sales_percentage,
        CASE
        WHEN cummulative_sales_percentage <= 80 THEN 'A'
        WHEN cummulative_sales_percentage > 80 AND cummulative_sales_percentage <= 95 THEN 'B'
        ELSE 'C'
        END AS abc_categories
    FROM
        sales_pct_cummulative
)
SELECT * FROM abc;

-- 2) Which product categories have the highest shipping costs?
WITH product_costs AS (
    SELECT
        product_category_name_english,
        SUM(a.freight_value) AS total_freight_costs
    FROM
        benvindo.items AS a
    LEFT JOIN (
        SELECT
            benvindo.products.product_id,
            benvindo.product_category_name_translation.product_category_name_english
        FROM
            benvindo.products
        LEFT JOIN
            benvindo.product_category_name_translation
        ON
            benvindo.products.product_category_name = benvindo.product_category_name_translation.product_category_name
        WHERE
            benvindo.products.product_category_name IS NOT NULL
    ) b
    ON
        a.product_id = b.product_id
    GROUP BY
        product_category_name_english
),
total_costs AS (
    SELECT
        SUM(total_freight_costs) AS total_freight
    FROM
        product_costs
),
costs_pct AS (
    SELECT
        product_category_name_english,
        total_freight_costs,
        (total_freight_costs / total_freight) * 100 AS costs_percentage
    FROM
        product_costs, total_costs
),
costs_pct_cummulative AS (
    SELECT
        product_category_name_english,
        total_freight_costs,
        costs_percentage,
        SUM(costs_percentage) OVER (ORDER BY costs_percentage DESC) AS cummulative_costs_percentage
    FROM
        costs_pct
),
abc AS (
    SELECT
        product_category_name_english AS product_category,
        total_freight_costs AS total_costs,
        costs_percentage,
        cummulative_costs_percentage,
        CASE
        WHEN cummulative_costs_percentage <= 80 THEN 'A'
        WHEN cummulative_costs_percentage > 80 AND cummulative_costs_percentage <= 95 THEN 'B'
        ELSE 'C'
        END AS abc_categories
    FROM
        costs_pct_cummulative
)
SELECT * FROM abc;

-- 4) We think that the products with better reviews are the ones that sell more. Is this really the case?
WITH review_analysis AS (
    SELECT a.product_id, AVG(review_score) AS avg_review_score, SUM(price) AS sales
    FROM (
        SELECT r.order_id, r.review_score, i.product_id, i.price
        FROM benvindo.reviews AS r
        LEFT JOIN (
            SELECT order_id, product_id, price
            FROM benvindo.items
        ) AS i
        ON i.order_id = r.order_id
    ) AS a
    GROUP BY a.product_id
    ORDER BY sales
)
SELECT
    CASE
    WHEN avg_review_score >= 1 AND avg_review_score < 2 THEN 1
    WHEN avg_review_score >= 2 AND avg_review_score < 3 THEN 2
    WHEN avg_review_score >= 3 AND avg_review_score < 4 THEN 3
    WHEN avg_review_score >= 4 AND avg_review_score < 5 THEN 4
    ELSE 5
    END AS score_group,
    COUNT(product_id) AS product_count, SUM(sales) AS total_sales
FROM (
    SELECT product_id, avg_review_score, sales
    FROM review_analysis
) AS subquery
GROUP BY score_group
ORDER BY score_group;

-- 5) What is the customers' preferred payment type? Does it match the payment type with the amount of income?
SELECT
    benvindo.payments.payment_type,
    COUNT(benvindo.payments.payment_value) as number_pays,
    ROUND((COUNT(benvindo.payments.payment_value)* 100.0 / (SELECT COUNT(*) FROM benvindo.payments)), 2) as percentage,
    SUM(benvindo.payments.payment_value) as pays
FROM
    benvindo.payments
WHERE
    benvindo.payments.payment_type <> 'not_defined'
GROUP BY
    benvindo.payments.payment_type
ORDER BY
    percentage DESC;