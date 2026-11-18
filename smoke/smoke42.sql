-- ### setup
CREATE OR REPLACE TEMP VIEW orders AS SELECT * FROM VALUES (1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D),(5,'eu',30.0D) AS t(id,region,amount)
;;
CREATE OR REPLACE TEMP VIEW pts AS SELECT * FROM VALUES ('q1',1.0D),('q2',9.0D) AS t(q,x)
;;
CREATE OR REPLACE TEMP VIEW base AS SELECT * FROM VALUES ('a',0.0D),('b',2.0D),('c',8.0D),('d',20.0D) AS t(name,y)
;;
-- ### geospatial
SELECT typeof(ST_GeomFromWKB(X'0101000000000000000000F03F0000000000000040'))
;;
-- ### QUALIFY
SELECT id, region, amount FROM orders QUALIFY row_number() OVER (PARTITION BY region ORDER BY amount DESC, id) = 1 ORDER BY region
;;
-- ### NEAREST BY
SELECT q, name FROM pts JOIN base EXACT NEAREST BY DISTANCE abs(x - y) ORDER BY q
;;
-- ### SET PATH (behind a flag)
SET spark.sql.path.enabled=true
;;
SET PATH = DEFAULT_PATH
;;
SELECT current_path()
;;
-- ### time_bucket
SELECT time_bucket(INTERVAL '15' MINUTE, TIMESTAMP_NTZ '2026-11-01 11:27:00')
;;
-- ### metric view
CREATE SCHEMA IF NOT EXISTS sales
;;
CREATE TABLE sales.orders USING parquet AS SELECT * FROM orders
;;
CREATE OR REPLACE VIEW sales.revenue_mv WITH METRICS LANGUAGE YAML AS $$
version: "0.1"
source: spark_catalog.sales.orders
dimensions:
  - name: region
    expr: region
measures:
  - name: total_amount
    expr: sum(amount)
$$
;;
SELECT region, MEASURE(total_amount) AS total FROM sales.revenue_mv GROUP BY region ORDER BY region
