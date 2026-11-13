# Spark 4.1 | Spark Declarative Pipelines | SPARK-51727
from pyspark import pipelines as dp
from pyspark.sql import DataFrame, SparkSession

spark = SparkSession.active()


@dp.materialized_view
def orders() -> DataFrame:
    return spark.sql("SELECT * FROM VALUES (1,'eu',10.0D),(2,'us',20.0D),"
                     "(3,'eu',30.0D),(4,'us',5.0D) AS t(id, region, amount)")
