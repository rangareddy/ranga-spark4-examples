-- Spark 4.0 | EXECUTE IMMEDIATE with bound parameters | SPARK-46246
CREATE OR REPLACE TEMP VIEW orders AS SELECT * FROM VALUES (1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D) AS t(id,region,amount);

EXECUTE IMMEDIATE 'SELECT count(*) FROM orders WHERE amount > ?' USING 8;
