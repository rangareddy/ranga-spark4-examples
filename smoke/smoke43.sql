-- ### JSON_TABLE
SELECT t.* FROM JSON_TABLE('{"items":[{"id":1,"n":"a"},{"id":2,"n":"b"}]}', '$.items[*]' COLUMNS (seq FOR ORDINALITY, id INT PATH '$.id', name STRING PATH '$.n')) AS t
;;
-- ### UNNEST
SELECT * FROM UNNEST(array(1,2), array(10,20,30)) AS t(a, b)
;;
-- ### VARIANT editing
SELECT variant_set(parse_json('{"a":1,"tags":["x"]}'), '$.b', 3)
;;
-- ### ASOF JOIN (behind a flag)
CREATE OR REPLACE TEMP VIEW trades AS SELECT * FROM VALUES (1,'AAPL',TIMESTAMP_NTZ '2026-11-01 10:00:05'),(2,'AAPL',TIMESTAMP_NTZ '2026-11-01 10:00:20') AS t(id,sym,ts)
;;
CREATE OR REPLACE TEMP VIEW quotes AS SELECT * FROM VALUES ('AAPL',TIMESTAMP_NTZ '2026-11-01 10:00:00',100.0D),('AAPL',TIMESTAMP_NTZ '2026-11-01 10:00:10',101.0D) AS q(sym,ts,bid)
;;
SET spark.sql.join.asofJoin.enabled=true
;;
SELECT t.id, q.ts AS quote_ts, q.bid FROM trades t ASOF JOIN quotes q MATCH_CONDITION (t.ts >= q.ts) ON t.sym = q.sym ORDER BY t.id
;;
-- ### TIME(9) (behind a flag)
SET spark.sql.timeType.enabled=true
;;
SELECT typeof(CAST('10:15:30.123456789' AS TIME(9)))
