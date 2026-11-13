-- Spark 4.2 | QUALIFY clause | SPARK-31561
CREATE OR REPLACE TEMP VIEW orders_t AS SELECT * FROM VALUES
  (1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D),(5,'eu',30.0D) AS t(id,region,amount);

SELECT id, region, amount FROM orders_t
QUALIFY row_number() OVER (PARTITION BY region ORDER BY amount DESC, id) = 1
ORDER BY region;

SELECT id, region, rank() OVER (PARTITION BY region ORDER BY amount DESC) AS r
FROM orders_t QUALIFY r = 1 ORDER BY id;
