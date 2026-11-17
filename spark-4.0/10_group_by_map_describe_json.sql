-- GROUP BY on MAP columns (SPARK-47430) and DESCRIBE ... AS JSON (SPARK-50541), introduced in 4.0.
-- Run for this post on Spark 4.3.0.
SELECT m, count(*) AS n
FROM VALUES (map('k', 1)), (map('k', 1)), (map('k', 2)) AS t(m)
GROUP BY m ORDER BY n;
CREATE TABLE people (id INT, name STRING) USING parquet;
DESCRIBE EXTENDED people AS JSON;
