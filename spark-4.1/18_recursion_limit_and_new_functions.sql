-- Spark 4.1 | New functions, and the recursion limit | SPARK-53654, SPARK-24497
-- Run: ./run.sh 4.1 spark-4.1/18_recursion_limit_and_new_functions.sql
SELECT chr(65) AS c, try_to_date('not a date') AS d, uuid(42) = uuid(42) AS same;

-- fails with RECURSION_LEVEL_LIMIT_EXCEEDED by design
WITH RECURSIVE t(n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM t) SELECT count(*) FROM t;
