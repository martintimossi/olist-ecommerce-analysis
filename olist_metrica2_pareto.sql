WITH
table1 AS
(
  SELECT 
    product_category_name,
    price
  FROM `disco-parsec-461018-f6.Olist.products` AS t1
  INNER JOIN `disco-parsec-461018-f6.Olist.order_items` AS t2
  ON t1.product_id = t2.product_id
  WHERE product_category_name IS NOT NULL
),
table2 AS
(
  SELECT
    product_category_name,
    ROUND (SUM (price), 2) AS gmv
  FROM table1
  GROUP BY product_category_name
  ORDER BY gmv DESC
),
table3 AS
(
  SELECT
    product_category_name,
    gmv,
    SUM (gmv) OVER (ORDER BY gmv DESC) AS gmv_acumulado,
    SUM (gmv) OVER () AS tot_acum
  FROM table2
),
table4 AS
(
  SELECT
    product_category_name,
    gmv,
    gmv_acumulado,
    ROUND (gmv_acumulado / tot_acum * 100, 2) AS prc
  FROM table3 
)

SELECT *
FROM table4
WHERE prc <= 80

/*

Query terminada y el resultado es muy limpio. 16 categorías concentran el 80% del GMV total de Olist, con beleza_saude liderando con casi 10% del revenue total.
Ese es exactamente el insight que un cliente de e-commerce quiere ver: no tiene 70 categorías importantes, tiene 16. Todo el esfuerzo de marketing, inventario y logística debería concentrarse ahí.

*/