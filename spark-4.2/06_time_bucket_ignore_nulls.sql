-- Spark 4.2 | time_bucket and IGNORE NULLS | SPARK-56594, SPARK-55256
SELECT time_bucket(INTERVAL '15' MINUTE, TIMESTAMP_NTZ '2026-11-01 11:27:00');

SELECT time_bucket(INTERVAL '1' HOUR, ts) AS hour, count(*) AS n, sum(v) AS total
FROM (VALUES (TIMESTAMP_NTZ '2026-11-01 10:05:00', 1),
             (TIMESTAMP_NTZ '2026-11-01 10:40:00', 2),
             (TIMESTAMP_NTZ '2026-11-01 11:10:00', 5)) AS t(ts, v)
GROUP BY 1 ORDER BY 1;

SELECT collect_list(x) IGNORE NULLS, collect_list(x) RESPECT NULLS
FROM VALUES (1), (CAST(NULL AS INT)), (3) AS t(x);
