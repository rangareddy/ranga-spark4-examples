-- Spark 4.1 | Sketch functions: top-k, KLL quantiles, Theta | SPARK-52515, SPARK-54199, SPARK-52407
CREATE OR REPLACE TEMP VIEW clicks AS SELECT * FROM VALUES ('a'),('b'),('a'),('c'),('a'),('b'),('d') AS t(page);
SELECT approx_top_k(page, 2) FROM clicks;

CREATE OR REPLACE TEMP VIEW lat AS SELECT id AS ms FROM range(1, 1001);
SELECT kll_sketch_get_quantile_bigint(kll_sketch_agg_bigint(ms), 0.5D) AS p50,
       kll_sketch_get_quantile_bigint(kll_sketch_agg_bigint(ms), 0.99D) AS p99
FROM lat;

SELECT theta_sketch_estimate(theta_union_agg(s)) FROM (
  SELECT theta_sketch_agg(x) s FROM VALUES (1),(2),(3) AS a(x)
  UNION ALL
  SELECT theta_sketch_agg(x)   FROM VALUES (3),(4)   AS b(x));
