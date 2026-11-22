# Spark 4.1 | The driver-script form that Declarative Pipelines replaces | SPARK-51727
# Run: ./run.sh 4.1 spark-4.1/10_declarative_pipeline_before.py
from pyspark.sql import SparkSession

spark = SparkSession.builder.getOrCreate()

spark.sql("DROP TABLE IF EXISTS orders")
spark.sql("""CREATE TABLE orders USING parquet AS
  SELECT * FROM VALUES (1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D)
  AS t(id, region, amount)""")

# you keep the order right: this one has to come second
spark.sql("DROP TABLE IF EXISTS revenue_by_region")
spark.sql("""CREATE TABLE revenue_by_region USING parquet AS
  SELECT region, sum(amount) AS total, count(*) AS orders
  FROM orders GROUP BY region""")

spark.table("revenue_by_region").orderBy("region").show()
