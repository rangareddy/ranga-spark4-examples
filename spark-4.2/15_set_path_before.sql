-- Spark 4.2 | A fully qualified name, the form SET PATH replaces | SPARK-54806
-- Run: ./run.sh 4.2 spark-4.2/15_set_path_before.sql
-- setup: two schemas that each hold a table named facts
CREATE SCHEMA IF NOT EXISTS ref;
CREATE SCHEMA IF NOT EXISTS sales;
DROP TABLE IF EXISTS ref.facts;
CREATE TABLE ref.facts USING parquet AS SELECT 2 AS id, 'ref' AS src;
DROP TABLE IF EXISTS sales.facts;
CREATE TABLE sales.facts USING parquet AS SELECT 1 AS id, 'sales' AS src;

SELECT * FROM spark_catalog.ref.facts;   -- 2  ref
