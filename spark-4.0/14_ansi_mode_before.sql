-- Spark 4.0 | The 3.x default: ANSI off, bad data becomes NULL | SPARK-44444
-- Run: ./run.sh 4.0 spark-4.0/14_ansi_mode_before.sql
SET spark.sql.ansi.enabled=false;
SELECT CAST('abc' AS INT) AS bad_cast, 1/0 AS div_zero;    -- NULL, NULL
SET spark.sql.ansi.enabled=true;
