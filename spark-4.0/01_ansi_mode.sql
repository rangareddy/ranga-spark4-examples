-- Spark 4.0 | ANSI mode on by default | SPARK-44444
SET spark.sql.ansi.enabled;
SELECT try_cast('abc' AS INT);          -- NULL
SELECT try_divide(1, 0);                -- NULL
-- The next two statements fail on purpose (CAST_INVALID_INPUT, DIVIDE_BY_ZERO):
SELECT CAST('abc' AS INT);
SELECT 1/0;
