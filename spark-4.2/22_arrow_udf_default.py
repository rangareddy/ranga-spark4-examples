# Spark 4.2 | Arrow-optimized Python UDFs are the default | SPARK-54555
# Run: ./run.sh 4.2 spark-4.2/22_arrow_udf_default.py --pip "pyarrow pandas"
# Without PyArrow and pandas the default falls back to the old path with a RuntimeWarning.
# 1. the default in 4.2: the Arrow path
from pyspark.sql import SparkSession
from pyspark.sql.functions import udf

spark = SparkSession.builder.getOrCreate()
df = spark.createDataFrame([(1,), (None,), (3,)], "x int")

print(spark.conf.get("spark.sql.execution.pythonUDF.arrow.enabled"))   # true, the default

to_int = udf(lambda x: None if x is None else str(x), "int")
df.select(to_int("x")).explain()
# ArrowEvalPython [<lambda>(x)], [pythonUDF0], 101
print([r[0] for r in df.select(to_int("x")).collect()])                # [1, None, 3]

# 2. the old path, selected with the setting (it stays set for the rest of the session)
from pyspark.sql import SparkSession
from pyspark.sql.functions import udf

spark = SparkSession.builder.getOrCreate()
df = spark.createDataFrame([(1,), (None,), (3,)], "x int")

spark.conf.set("spark.sql.execution.pythonUDF.arrow.enabled", "false")
to_int = udf(lambda x: None if x is None else str(x), "int")
print([r[0] for r in df.select(to_int("x")).collect()])   # [None, None, None]
