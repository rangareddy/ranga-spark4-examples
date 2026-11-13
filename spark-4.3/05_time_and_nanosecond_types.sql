-- Spark 4.3 | TIME(p) and nanosecond timestamps, behind flags | SPARK-57551, SPARK-56876
SET spark.sql.timeType.enabled = true;
SET spark.sql.timestampNanosTypes.enabled = true;

SELECT typeof(CAST('10:15:30.123456789' AS TIME(9)));
SELECT CAST(CAST('2026-11-01 10:00:00.123456789' AS TIMESTAMP_NTZ(9)) AS STRING),
       typeof(CAST('2026-11-01 10:00:00.123456789' AS TIMESTAMP_NTZ(9)));
SELECT CAST('2026-11-01 10:00:00.123456789' AS TIMESTAMP_NTZ);
