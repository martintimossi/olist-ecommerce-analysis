WITH
tables_join AS
(
  SELECT
   order_delivered_customer_date,
   order_estimated_delivery_date,
   customer_state
  FROM `disco-parsec-461018-f6.Olist.customers` AS c
  INNER JOIN `disco-parsec-461018-f6.Olist.ordesrs` AS o
  ON c.customer_id = o.customer_id
  WHERE order_delivered_customer_date IS NOT NULL
),

category_table AS
(
  SELECT
   order_delivered_customer_date,
   order_estimated_delivery_date,
   customer_state,
   DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) AS desviation
  FROM tables_join
),

delivery_status AS     
(
  SELECT
   customer_state,
   order_estimated_delivery_date,
   order_delivered_customer_date,
   CASE
    WHEN category_table.desviation < 0 THEN 'early'
    WHEN category_table.desviation > 0 THEN 'delayed'
    WHEN category_table.desviation = 0 THEN 'on time'     
   END AS category
  FROM category_table
),

resume_delivery AS
(
  SELECT
   customer_state,
   COUNTIF(category = 'early') AS early,
   COUNTIF(category = 'on time') AS on_time,
   COUNTIF(category = 'delayed') AS delayed,
   COUNT(*) AS total,
  FROM delivery_status
  GROUP BY customer_state
),

percent_delivery AS
(
  SELECT
   customer_state,
   ROUND(early / total * 100, 2) AS ptc_aearly,
   ROUND(on_time / total * 100, 2) AS ptc_on_time,
   ROUND(delayed / total * 100, 2) AS ptc_delayed,
   total
  FROM resume_delivery
)

SELECT *
FROM percent_delivery