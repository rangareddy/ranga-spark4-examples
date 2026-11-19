# Spark 4.3 | Arrow-native Dataset caching (static setting) and experimental transpiling of simple Python UDFs.
# Run (pyspark 4.3.0, Python 3.11):  python 17_arrow_cache_and_udf_transpile.py
from pyspark.sql import SparkSession
from pyspark.sql.functions import udf

# spark.sql.cache.serializer is static: set it when the session is built, not with spark.conf.set.
spark = (SparkSession.builder.master("local[2]")
         .config("spark.sql.cache.serializer",
                 "org.apache.spark.sql.execution.columnar.ArrowCachedBatchSerializer")
         .getOrCreate())

df = spark.range(5).selectExpr("id", "id * 2 AS d").cache()
print("cached rows:", df.count())

spark.conf.set("spark.sql.ansi.enabled", "true")
spark.conf.set("spark.sql.experimental.optimizer.transpilePyUDFs", "true")


@udf("int", useArrow=False)
def name_length(name: str) -> int:
    return len(name)


names = spark.createDataFrame([("ana",), ("bob12",)], "name string")
out = names.select(name_length("name").alias("n"))
out.show()
# _jdf is a private PySpark handle, used here only to read the physical plan for the demo.
plan = out._jdf.queryExecution().executedPlan().toString()
print("plan has a PythonUDF node:", "PythonUDF" in plan)   # False: len() became a Catalyst expression
print("NULL guard in plan:", "cannot call len() on NULL" in plan)
