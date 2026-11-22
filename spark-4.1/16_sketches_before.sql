-- Spark 4.1 | An exact distinct count over the combined rows, the form Theta sketches replace | SPARK-52407
-- Run: ./run.sh 4.1 spark-4.1/16_sketches_before.sql
SELECT count(DISTINCT x) FROM (
  SELECT 1 AS x UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 3 UNION ALL SELECT 4);
