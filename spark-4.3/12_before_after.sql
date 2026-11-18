-- Before and after for the 4.3 features that replace a longer query. The "before" forms work on every Spark 4.x release.
-- Run on Spark 4.3.0, the release tarball. The after forms of BIN BY and the nanosecond type need the flags shown.

-- JSON to rows. Before: from_json with a schema, then explode.
SELECT j.id, j.n FROM (
  SELECT explode(from_json('{"items":[{"id":1,"n":"a"},{"id":2,"n":"b"}]}',
                           'items ARRAY<STRUCT<id: INT, n: STRING>>').items) AS j);

-- JSON to rows. After: JSON_TABLE, with an ordinality column that the before form has no direct equivalent for.
SELECT t.* FROM JSON_TABLE(
  '{"items":[{"id":1,"n":"a"},{"id":2,"n":"b"}]}', '$.items[*]'
  COLUMNS (seq FOR ORDINALITY, id INT PATH '$.id', name STRING PATH '$.n')) AS t;

-- Array to rows with a position. Before: LATERAL VIEW posexplode. Positions start at 0.
SELECT pos, value FROM (SELECT 1) LATERAL VIEW posexplode(array('a','b')) t AS pos, value;

-- Two arrays in parallel. Before: arrays_zip, then explode. The shorter array is padded with NULL.
SELECT z.`0` AS a, z.`1` AS b FROM (SELECT explode(arrays_zip(array(1,2), array(10,20,30))) AS z);

-- Array to rows with a position. After: UNNEST ... WITH ORDINALITY. Positions start at 1.
SELECT * FROM UNNEST(array('a','b')) WITH ORDINALITY AS t(value, pos);

-- ASOF JOIN. Before: join on q.ts <= t.ts, rank with row_number, keep the first.
CREATE OR REPLACE TEMP VIEW trades AS SELECT * FROM VALUES
  (1,'AAPL',TIMESTAMP'2026-11-01 10:00:05'),(2,'AAPL',TIMESTAMP'2026-11-01 10:00:20'),
  (3,'MSFT',TIMESTAMP'2026-11-01 10:00:07') AS trades(id,sym,ts);
CREATE OR REPLACE TEMP VIEW quotes AS SELECT * FROM VALUES
  ('AAPL',TIMESTAMP'2026-11-01 10:00:00',100.0D),('AAPL',TIMESTAMP'2026-11-01 10:00:10',101.0D),
  ('MSFT',TIMESTAMP'2026-11-01 10:00:06',200.0D) AS quotes(sym,ts,bid);
SELECT id, sym, ts, quote_ts, bid FROM (
  SELECT t.id, t.sym, t.ts, q.ts AS quote_ts, q.bid,
         row_number() OVER (PARTITION BY t.id ORDER BY q.ts DESC) AS rn
  FROM trades t LEFT JOIN quotes q ON t.sym = q.sym AND q.ts <= t.ts)
WHERE rn = 1 ORDER BY id;

-- VARIANT editing. Before: rebuild the value from its parts. After: variant_set(v, '$.b', 3).
SELECT parse_json(to_json(named_struct('a', variant_get(v,'$.a','int'), 'b', 3,
                                       'tags', variant_get(v,'$.tags','variant')))) AS rebuilt
FROM (SELECT parse_json('{"a":1,"tags":["x"]}') AS v);

-- BIN BY. Before: generate the bins with sequence and prorate the overlap by hand.
CREATE OR REPLACE TEMP VIEW calls AS SELECT * FROM VALUES
  (1,TIMESTAMP'2026-11-01 10:00:00',TIMESTAMP'2026-11-01 10:25:00',100.0D),
  (2,TIMESTAMP'2026-11-01 10:05:00',TIMESTAMP'2026-11-01 10:15:00',30.0D) AS calls(id,started,ended,cost);
WITH x AS (SELECT id, cost, unix_timestamp(started) AS s, unix_timestamp(ended) AS e FROM calls),
b AS (SELECT id, cost, s, e, explode(sequence(floor(s/600), floor((e-1)/600))) AS bin FROM x)
SELECT id, timestamp_seconds(bin*600) AS bin_start, timestamp_seconds((bin+1)*600) AS bin_end,
       round(cost * (least(e,(bin+1)*600) - greatest(s,bin*600)) / (e - s), 1) AS cost
FROM b ORDER BY id, bin_start;

-- Timestamp precision. Before: the default type keeps microseconds, so the last three digits are cut.
SELECT CAST('2026-11-01 10:00:00.123456789' AS TIMESTAMP_NTZ) AS micros_only;
