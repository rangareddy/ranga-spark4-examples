-- Spark 4.3 | counter_diff, collect_union, jaro_winkler_similarity, base32 | SPARK-56820, SPARK-57253, SPARK-58399, SPARK-58295
SELECT t, c, counter_diff(c) OVER (ORDER BY t) AS delta FROM VALUES
  (TIMESTAMP_NTZ '2026-01-01 00:00:00', 100),
  (TIMESTAMP_NTZ '2026-01-01 00:01:00', 130),
  (TIMESTAMP_NTZ '2026-01-01 00:02:00', 190) AS m(t, c);

SELECT collect_union(col) FROM VALUES (array(1,2)), (array(2,3)), (array(1)) AS tab(col);
SELECT jaro_winkler_similarity('MARTHA', 'MARHTA');
SELECT to_base32(CAST('spark' AS BINARY)),
       CAST(from_base32(to_base32(CAST('spark' AS BINARY))) AS STRING);
