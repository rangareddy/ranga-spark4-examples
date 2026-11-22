-- Spark 4.0 | The conventional query next to its pipe-syntax form | SPARK-49555
-- Run: ./run.sh 4.0 spark-4.0/16_pipe_syntax_before.sql
CREATE OR REPLACE TEMP VIEW orders AS SELECT * FROM VALUES (1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D) AS t(id,region,amount);
SELECT region, sum(amount) AS total FROM orders WHERE amount > 5 GROUP BY region ORDER BY total DESC;
