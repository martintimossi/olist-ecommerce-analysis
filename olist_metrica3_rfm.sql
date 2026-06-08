WITH
join_table AS     
(
  SELECT 
   customer_id,
   order_purchase_timestamp,
   price
  FROM `disco-parsec-461018-f6.Olist.ordesrs` AS o
  INNER JOIN `disco-parsec-461018-f6.Olist.order_items` AS i
  ON o.order_id = i.order_id
),

group_customer AS    
(
  SELECT 
   customer_id,
   DATE_DIFF(DATE('2018-09-03'), DATE(MAX(order_purchase_timestamp)), DAY) AS recency,
   COUNT(order_purchase_timestamp) AS frecuency,
   ROUND(SUM(price), 2) AS monetary
  FROM join_table
  GROUP BY customer_id 
),

rfm_scores AS   
(
  SELECT
   customer_id,
   recency,
   frecuency,
   monetary,
   NTILE(4) OVER (ORDER BY recency ASC) AS r_score,
   NTILE(4) OVER (ORDER BY frecuency DESC) AS f_score,
   NTILE(4) OVER (ORDER BY monetary DESC) AS m_score 
  FROM group_customer
),

rfm_segment AS   
(
  SELECT 
   customer_id,
   recency,
   frecuency,
   rfm_scores.monetary,
   r_score,
   f_score,
   m_score,
  CASE
    WHEN r_score = 1 AND f_score = 1 AND m_score = 1 THEN 'best_customer' --Compró reciente y muchas veces
    WHEN r_score <= 2 AND f_score <= 2 THEN 'loyal' --Buen cliente, algo menos activo
    WHEN r_score = 1 AND f_score >= 3 THEN 'potential' --Compró reciente pero pocas veces, tiene potencial
    WHEN r_score >= 3 AND f_score <= 2 THEN 'at risk' --Solía comprar pero hace tiempo que no
    WHEN r_score = 4 THEN 'lost' --No compra hace mucho
    ELSE 'others' --Casos intermedios
  END AS CATEGORY
  FROM rfm_scores
)

SELECT 
 CATEGORY,
 COUNT (customer_id) AS total_customer_types
FROM rfm_segment
GROUP BY CATEGORY
ORDER BY total_customer_types
LIMIT 5