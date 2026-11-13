-- Spark 4.2 | Top-K max_by and min_by
CREATE OR REPLACE TEMP VIEW orders AS SELECT * FROM VALUES (1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D) AS t(id,region,amount);
SELECT max_by(id, amount, 2) AS top2, min_by(id, amount, 2) AS bottom2 FROM orders;
