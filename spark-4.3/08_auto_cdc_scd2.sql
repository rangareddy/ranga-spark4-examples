-- Spark 4.3 | Auto CDC with SCD Type 2 | SPARK-58321, SPARK-58247, SPARK-58261
-- Pipeline SQL, not a plain script; the complete runnable pipeline is in 08_auto_cdc_scd2/. The target table's connector must support row-level
-- MERGE (for example an Apache Iceberg catalog); a default Parquet table fails with
-- AUTOCDC_TARGET_DOES_NOT_SUPPORT_MERGE. Not run by run.sh.
CREATE STREAMING TABLE customers_history
FLOW AUTO CDC
FROM STREAM(cdc_events)
KEYS (id)
APPLY AS DELETE WHEN op = 'DELETE'
SEQUENCE BY version
COLUMNS * EXCEPT (op)
STORED AS SCD TYPE 2;
