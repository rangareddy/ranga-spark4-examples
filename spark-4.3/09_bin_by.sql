SET spark.sql.binByRelationOperator.enabled=true;
CREATE OR REPLACE TEMP VIEW calls AS
SELECT * FROM VALUES
  (1, 'ana', TIMESTAMP_NTZ'2026-11-01 10:00:00', TIMESTAMP_NTZ'2026-11-01 10:25:00', 100.0D),
  (2, 'bob', TIMESTAMP_NTZ'2026-11-01 10:05:00', TIMESTAMP_NTZ'2026-11-01 10:15:00',  30.0D)
AS calls(id, caller, started, ended, cost);
SELECT id, caller, bin_start, bin_end, cost
FROM calls
BIN BY (RANGE started TO ended BIN WIDTH INTERVAL 10 MINUTES DISTRIBUTE UNIFORM (cost)
        BIN_START AS bin_start BIN_END AS bin_end)
ORDER BY id, bin_start;
