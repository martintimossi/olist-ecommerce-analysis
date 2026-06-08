WITH 

join_table AS 
(
  SELECT 
   t1.order_purchase_timestamp, 
   t2.price
  FROM `disco-parsec-461018-f6.Olist.ordesrs` AS t1
  INNER JOIN `disco-parsec-461018-f6.Olist.order_items` AS t2
  ON t1.order_id = t2.order_id
),

trunc_moth AS
(
  SELECT
   DATE_TRUNC(order_purchase_timestamp, MONTH) AS month,
   price
  FROM join_table

),
add_month AS
(
  SELECT
   month,
   ROUND(SUM(price),2) AS total_price
  FROM trunc_moth
  GROUP BY month
),

lag_month AS
(
  SELECT
   month,
   total_price,
   LAG(total_price) OVER (ORDER BY month) AS last_month
  FROM add_month
),

gvm_month AS
(
  SELECT
   month,
   total_price,
   last_month,
   ROUND(((total_price - last_month) / last_month) * 100, 2) AS gvm
  FROM lag_month
)

SELECT *
FROM gvm_month
WHERE gvm < 1000

