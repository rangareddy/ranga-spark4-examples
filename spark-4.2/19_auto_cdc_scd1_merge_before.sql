-- Spark 4.2 | The hand-written latest-event and MERGE form that Auto CDC (SCD Type 1) replaces | SPARK-56249
-- Needs a catalog with row-level operations. Spark's own in-memory test catalog works:
--   curl -LO https://repo1.maven.org/maven2/org/apache/spark/spark-catalyst_2.13/4.2.1/spark-catalyst_2.13-4.2.1-tests.jar
--   spark-sql --jars spark-catalyst_2.13-4.2.1-tests.jar \
--     --conf spark.sql.catalog.lh=org.apache.spark.sql.connector.catalog.InMemoryRowLevelOperationTableCatalog \
--     -f spark-4.2/19_auto_cdc_scd1_merge_before.sql
-- setup: the target, and a batch of events with one delete and one re-insert for key 1
CREATE TABLE lh.default.customers (id INT, name STRING, version BIGINT);

CREATE OR REPLACE TEMP VIEW cdc_events AS SELECT * FROM VALUES
  (1, 'alice',  1L, 'UPSERT'),
  (1, 'alice',  2L, 'DELETE'),
  (1, 'alice2', 3L, 'UPSERT'),
  (2, 'bob',    1L, 'UPSERT') AS e(id, name, version, op);

-- keep only the latest event per key, because one batch can carry several events for a key
CREATE OR REPLACE TEMP VIEW latest AS
SELECT id, name, version, op FROM (
  SELECT *, row_number() OVER (PARTITION BY id ORDER BY version DESC) AS rn FROM cdc_events)
WHERE rn = 1;

MERGE INTO lh.default.customers t
USING latest c ON t.id = c.id
WHEN MATCHED AND c.op = 'DELETE' AND c.version > t.version THEN DELETE
WHEN MATCHED AND c.version > t.version THEN UPDATE SET t.name = c.name, t.version = c.version
WHEN NOT MATCHED AND c.op <> 'DELETE' THEN INSERT (id, name, version) VALUES (c.id, c.name, c.version);

SELECT * FROM lh.default.customers ORDER BY id;
-- 1  alice2  3
-- 2  bob     1
