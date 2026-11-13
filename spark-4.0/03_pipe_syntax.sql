-- Spark 4.0 | SQL pipe syntax | SPARK-49555
CREATE OR REPLACE TEMP VIEW orders AS SELECT * FROM VALUES (1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D) AS t(id,region,amount);

FROM orders
|> WHERE amount > 5
|> AGGREGATE sum(amount) AS total GROUP BY region
|> ORDER BY total DESC;

FROM orders |> EXTEND amount * 2 AS doubled |> SELECT id, doubled |> LIMIT 2;
