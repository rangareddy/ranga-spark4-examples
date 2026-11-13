-- Spark 4.2 | Metric views | SPARK-54119
CREATE SCHEMA IF NOT EXISTS sales;
DROP TABLE IF EXISTS sales.orders;
CREATE TABLE sales.orders USING parquet AS
SELECT * FROM VALUES (1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D),(5,'eu',30.0D) AS t(id,region,amount);

CREATE OR REPLACE VIEW sales.revenue_mv WITH METRICS LANGUAGE YAML AS $$
version: "0.1"
source: spark_catalog.sales.orders
dimensions:
  - name: region
    expr: region
measures:
  - name: total_amount
    expr: sum(amount)
  - name: order_count
    expr: count(1)
$$;

SELECT region, MEASURE(total_amount) AS total, MEASURE(order_count) AS n
FROM sales.revenue_mv GROUP BY region ORDER BY region;
