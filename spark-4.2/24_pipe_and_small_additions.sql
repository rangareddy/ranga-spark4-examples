-- Spark 4.2 | Pipe syntax with | and AGGREGATE, PIVOT alias, DROP TABLE on a view, top-K max_by | SPARK-51518, SPARK-54292, SPARK-55356, SPARK-55019, SPARK-55322
-- Run: ./run.sh 4.2 spark-4.2/24_pipe_and_small_additions.sql
SELECT * FROM VALUES (1, 'eu', 10.0D), (2, 'us', 20.0D), (3, 'eu', 30.0D) AS t(id, region, amount)
| WHERE amount > 5
| AGGREGATE sum(amount) AS total GROUP BY region
| ORDER BY region;
-- eu  40.0
-- us  20.0

SELECT * FROM (SELECT * FROM VALUES ('a', 'x', 1), ('a', 'y', 2), ('b', 'x', 3) AS t(k, c, v))
PIVOT (sum(v) FOR c IN ('x', 'y')) AS p ORDER BY k;
-- a  1  2
-- b  3  NULL

CREATE VIEW v1 AS SELECT 1 AS a;
DROP TABLE v1;

SELECT max_by(name, score, 2) FROM VALUES ('a', 1), ('b', 3), ('c', 2) AS t(name, score);
-- ["b","c"]
