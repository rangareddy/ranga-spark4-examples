-- Spark 4.3 | ASOF JOIN variants: LEFT, USING, strict and forward matches, ties, NULLs, asymmetry
-- Reference: https://spark.apache.org/docs/4.3.0/sql-ref-syntax-qry-select-asof-join.html
SET spark.sql.join.asofJoin.enabled = true;

-- setup: the 02 data plus a GOOG trade with no quote, a trade exactly on a quote time, and a NULL timestamp
CREATE OR REPLACE TEMP VIEW trades AS SELECT * FROM VALUES
  (1,'AAPL',TIMESTAMP_NTZ '2026-11-01 10:00:05'),
  (2,'AAPL',TIMESTAMP_NTZ '2026-11-01 10:00:20'),
  (3,'MSFT',TIMESTAMP_NTZ '2026-11-01 10:00:07'),
  (4,'GOOG',TIMESTAMP_NTZ '2026-11-01 10:00:15'),
  (5,'MSFT',TIMESTAMP_NTZ '2026-11-01 10:00:06'),
  (6,'AAPL',CAST(NULL AS TIMESTAMP_NTZ)) AS t(id,sym,ts);
CREATE OR REPLACE TEMP VIEW quotes AS SELECT * FROM VALUES
  ('AAPL',TIMESTAMP_NTZ '2026-11-01 10:00:00',100.0D),
  ('AAPL',TIMESTAMP_NTZ '2026-11-01 10:00:10',101.0D),
  ('MSFT',TIMESTAMP_NTZ '2026-11-01 10:00:06',200.0D) AS q(sym,ts,bid);

-- 1. INNER (the default) drops trades with no match: GOOG (id 4) and the NULL timestamp (id 6)
SELECT t.id, t.sym, q.ts AS quote_ts, q.bid
FROM trades t ASOF JOIN quotes q MATCH_CONDITION (t.ts >= q.ts) ON t.sym = q.sym
ORDER BY t.id;

-- 2. LEFT keeps them, with NULL on the quote side
SELECT t.id, t.sym, q.ts AS quote_ts, q.bid
FROM trades t LEFT ASOF JOIN quotes q MATCH_CONDITION (t.ts >= q.ts) ON t.sym = q.sym
ORDER BY t.id;

-- 3. USING (sym) is the same equality as ON t.sym = q.sym
SELECT t.id, sym, q.ts AS quote_ts, q.bid
FROM trades t LEFT ASOF JOIN quotes q MATCH_CONDITION (t.ts >= q.ts) USING (sym)
ORDER BY t.id;

-- 4. >= takes a quote at the same instant, > needs a strictly earlier one (trade 5 is at 10:00:06)
SELECT t.id, 'at_or_before' AS op, q.ts AS quote_ts, q.bid
FROM trades t LEFT ASOF JOIN quotes q MATCH_CONDITION (t.ts >= q.ts) ON t.sym = q.sym
WHERE t.id = 5
UNION ALL
SELECT t.id, 'strictly_before', q.ts, q.bid
FROM trades t LEFT ASOF JOIN quotes q MATCH_CONDITION (t.ts > q.ts) ON t.sym = q.sym
WHERE t.id = 5;

-- 5. Forward match: <= takes the first quote at or after the trade
SELECT t.id, t.sym, t.ts, q.ts AS next_quote_ts, q.bid
FROM trades t LEFT ASOF JOIN quotes q MATCH_CONDITION (t.ts <= q.ts) ON t.sym = q.sym
ORDER BY t.id;

-- 6. Ties: three versions share one timestamp, so a struct condition with a sequence number decides
CREATE OR REPLACE TEMP VIEW events AS SELECT * FROM VALUES
  (1, TIMESTAMP_NTZ '2026-11-01 10:00:10', 2) AS e(id, ts, seq);
CREATE OR REPLACE TEMP VIEW versions AS SELECT * FROM VALUES
  (TIMESTAMP_NTZ '2026-11-01 10:00:10', 1, 'a'),
  (TIMESTAMP_NTZ '2026-11-01 10:00:10', 2, 'b'),
  (TIMESTAMP_NTZ '2026-11-01 10:00:10', 3, 'c') AS v(ts, seq, label);
SELECT e.id, v.label
FROM events e ASOF JOIN versions v MATCH_CONDITION ((e.ts, e.seq) >= (v.ts, v.seq));

-- 7. The left side drives the lookup, so swapping the tables changes the result
SELECT q.sym, q.ts AS quote_ts, t.id AS trade_id, t.ts AS trade_ts
FROM quotes q LEFT ASOF JOIN trades t MATCH_CONDITION (q.ts >= t.ts) ON q.sym = t.sym
ORDER BY q.sym, q.ts;
