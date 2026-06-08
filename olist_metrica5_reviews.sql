WITH
join_table AS    
(
  SELECT
    order_delivered_customer_date,
    order_estimated_delivery_date,
    review_score
  FROM `disco-parsec-461018-f6.Olist.ordesrs` AS o
  INNER JOIN `disco-parsec-461018-f6.Olist.order_reviews` AS r
  ON r.order_id = o.order_id
  WHERE order_delivered_customer_date IS NOT NULL
),

desv_table AS
(
  SELECT
    order_delivered_customer_date,
    order_estimated_delivery_date,
    DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) AS date_dif,
    review_score
  FROM join_table
),

buckets AS   
(
  SELECT
    order_delivered_customer_date,
    order_estimated_delivery_date,
    date_dif,
    review_score,
  CASE
    WHEN date_dif < 0 THEN 'early'
    WHEN date_dif = 0 THEN 'on time'
    WHEN date_dif > 0 AND date_dif <= 3 THEN '1-3 days'
    WHEN date_dif > 3 AND date_dif <= 7 THEN '4-7 days'
    WHEN date_dif > 7 THEN '+ 7 days'
  END AS category    
  FROM desv_table
),

final_table AS   
(
  SELECT
    category,
    ROUND(AVG(review_score), 2) AS avg_review,
    COUNT (*) AS total_orders
  FROM buckets
  GROUP BY category
  ORDER BY avg_review DESC
)

SELECT *
FROM final_table
LIMIT 5