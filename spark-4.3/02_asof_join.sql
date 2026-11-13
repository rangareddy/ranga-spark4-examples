-- Spark 4.3 | ASOF JOIN, behind spark.sql.join.asofJoin.enabled | SPARK-58092
CREATE OR REPLACE TEMP VIEW trades AS SELECT * FROM VALUES
  (1,'AAPL',TIMESTAMP_NTZ '2026-11-01 10:00:05'),
  (2,'AAPL',TIMESTAMP_NTZ '2026-11-01 10:00:20'),
  (3,'MSFT',TIMESTAMP_NTZ '2026-11-01 10:00:07') AS t(id,sym,ts);
CREATE OR REPLACE TEMP VIEW quotes AS SELECT * FROM VALUES
  ('AAPL',TIMESTAMP_NTZ '2026-11-01 10:00:00',100.0D),
  ('AAPL',TIMESTAMP_NTZ '2026-11-01 10:00:10',101.0D),
  ('MSFT',TIMESTAMP_NTZ '2026-11-01 10:00:06',200.0D) AS q(sym,ts,bid);

-- Fails with UNSUPPORTED_FEATURE.ASOF_JOIN until the flag is set:
SELECT t.id FROM trades t ASOF JOIN quotes q MATCH_CONDITION (t.ts >= q.ts) ON t.sym = q.sym;

SET spark.sql.join.asofJoin.enabled = true;
SELECT t.id, t.sym, t.ts, q.ts AS quote_ts, q.bid
FROM trades t ASOF JOIN quotes q
  MATCH_CONDITION (t.ts >= q.ts)
  ON t.sym = q.sym
ORDER BY t.id;
