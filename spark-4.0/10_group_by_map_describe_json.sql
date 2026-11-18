-- GROUP BY on MAP columns (SPARK-47430) and DESCRIBE ... AS JSON (SPARK-50541), introduced in 4.0.
-- Run on apache/spark:4.0.5-python3, and also on the 4.3.0 release tarball.
SELECT m, count(*) AS n
FROM VALUES (map('k', 1)), (map('k', 1)), (map('k', 2)) AS t(m)
GROUP BY m ORDER BY n;
CREATE TABLE people (id INT, name STRING) USING parquet;
DESCRIBE EXTENDED people AS JSON;
