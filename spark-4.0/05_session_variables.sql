-- Spark 4.0 | Session variables | SPARK-42849
CREATE OR REPLACE TEMP VIEW orders AS SELECT * FROM VALUES (1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D) AS t(id,region,amount);

DECLARE OR REPLACE VARIABLE threshold DOUBLE DEFAULT 15.0;
SELECT id FROM orders WHERE amount > threshold ORDER BY id;

SET VAR threshold = 25.0;
SELECT id FROM orders WHERE amount > threshold ORDER BY id;
