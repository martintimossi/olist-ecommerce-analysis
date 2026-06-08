WITH
order_table AS
(
  SELECT
    seller_id,
    price,
    review_score
  FROM `disco-parsec-461018-f6.Olist.ordesrs` AS o
  INNER JOIN `disco-parsec-461018-f6.Olist.order_items` AS i
  ON o.order_id = i.order_id
  INNER JOIN `disco-parsec-461018-f6.Olist.order_reviews` AS r
  ON o.order_id = r.order_id
),

seller_table AS
(
  SELECT
    seller_id,
    COUNT (*) AS total_orders,
    ROUND(SUM(price), 2) AS gmv,
    ROUND(AVG(review_score), 2) AS avg_review
  FROM order_table
  GROUP BY seller_id
),

rank_table AS
(
  SELECT
    seller_id,
    total_orders,
    gmv,
    avg_review,
    DENSE_RANK() OVER (ORDER BY total_orders DESC) AS seller_rank
  FROM seller_table
)

SELECT *
FROM rank_table
WHERE total_orders > 50
  AND avg_review < 3
ORDER BY total_orders DESC
