-- Spark 4.2 | The aggregation copied into every report, the form a metric view replaces | SPARK-54119
-- Run: ./run.sh 4.2 spark-4.2/16_metric_view_before.sql
-- setup: five orders in sales.orders
CREATE SCHEMA IF NOT EXISTS sales;
DROP TABLE IF EXISTS sales.orders;
CREATE TABLE sales.orders USING parquet AS
SELECT * FROM VALUES (1, 'eu', 10.0D), (2, 'us', 20.0D), (3, 'eu', 30.0D), (4, 'us', 5.0D), (5, 'eu', 30.0D)
AS t(id, region, amount);

SELECT region, sum(amount) AS total, count(1) AS n
FROM sales.orders GROUP BY region ORDER BY region;
-- eu  70.0  3
-- us  25.0  2
