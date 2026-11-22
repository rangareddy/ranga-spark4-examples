-- Spark 4.0 | to_json(m) to group by a map, the form GROUP BY m replaces | SPARK-47430
-- Run: ./run.sh 4.0 spark-4.0/22_group_by_map_before.sql
SELECT to_json(m) AS m, count(*) AS n
FROM VALUES (map('k', 1)), (map('k', 1)), (map('k', 2)) AS t(m)
GROUP BY to_json(m) ORDER BY n;
