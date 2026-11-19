# Spark 4.2 | DataFrame.zipWithIndex | SPARK-55229
# Run: ./run.sh 4.2 spark-4.2/25_zip_with_index.py
from pyspark.sql import SparkSession
spark = SparkSession.builder.getOrCreate()
df = spark.createDataFrame([("a",), ("b",), ("c",)], "v string")
df.zipWithIndex().show()
# +---+-----+
# |  v|index|
# +---+-----+
# |  a|    0|
# |  b|    1|
# |  c|    2|
# +---+-----+
