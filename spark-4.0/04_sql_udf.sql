-- Spark 4.0 | SQL user-defined functions, scalar and table | SPARK-46057
CREATE OR REPLACE TEMP VIEW orders AS SELECT * FROM VALUES (1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D) AS t(id,region,amount);

CREATE OR REPLACE TEMPORARY FUNCTION add_tax(x DOUBLE) RETURNS DOUBLE RETURN x * 1.18;
SELECT id, add_tax(amount) AS gross FROM orders ORDER BY id;

CREATE OR REPLACE TEMPORARY FUNCTION big_orders(min_amt DOUBLE)
  RETURNS TABLE (id INT, amount DOUBLE)
  RETURN SELECT id, amount FROM orders WHERE amount >= min_amt;
SELECT * FROM big_orders(20.0);
