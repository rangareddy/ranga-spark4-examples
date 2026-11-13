-- Spark 4.2 | SET PATH, behind spark.sql.path.enabled | SPARK-54806
SELECT current_path();

SET spark.sql.path.enabled = true;
CREATE SCHEMA IF NOT EXISTS ref;
CREATE SCHEMA IF NOT EXISTS sales;
DROP TABLE IF EXISTS ref.facts;
CREATE TABLE ref.facts USING parquet AS SELECT 2 AS id, 'ref' AS src;
DROP TABLE IF EXISTS sales.facts;
CREATE TABLE sales.facts USING parquet AS SELECT 1 AS id, 'sales' AS src;

SET PATH = spark_catalog.ref, DEFAULT_PATH;
SELECT current_path();
SELECT * FROM facts;

SET PATH = spark_catalog.sales, DEFAULT_PATH;
SELECT * FROM facts;
