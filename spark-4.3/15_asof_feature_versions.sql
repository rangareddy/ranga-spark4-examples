-- Spark 4.3 | ASOF JOIN against feature versions: a prediction never sees a later feature version.
-- Predictions made at 10:03 and 10:07; feature versions published at 10:00 and 10:05.
CREATE OR REPLACE TEMP VIEW predictions AS SELECT * FROM VALUES
  (1, TIMESTAMP_NTZ '2026-11-01 10:03:00', 0.91D),
  (2, TIMESTAMP_NTZ '2026-11-01 10:07:00', 0.42D) AS p(id, made_at, score);
CREATE OR REPLACE TEMP VIEW feature_versions AS SELECT * FROM VALUES
  ('v1', TIMESTAMP_NTZ '2026-11-01 10:00:00'),
  ('v2', TIMESTAMP_NTZ '2026-11-01 10:05:00') AS f(version, published_at);

SET spark.sql.join.asofJoin.enabled = true;
SELECT p.id, p.made_at, p.score, f.version AS features_used, f.published_at
FROM predictions p
ASOF JOIN feature_versions f
  MATCH_CONDITION (p.made_at >= f.published_at)
ORDER BY p.id;
-- 1  2026-11-01 10:03:00  0.91  v1  2026-11-01 10:00:00
-- 2  2026-11-01 10:07:00  0.42  v2  2026-11-01 10:05:00

-- The plain join the post compares with returns three rows (v1, v1, v2):
SELECT p.id, f.version FROM predictions p JOIN feature_versions f ON p.made_at >= f.published_at ORDER BY p.id, f.version;
