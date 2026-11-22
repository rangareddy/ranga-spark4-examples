# Spark 4.0 | A driver-side list, the form a Python Data Source replaces | SPARK-44076
# Run: ./run.sh 4.0 spark-4.0/21_python_data_source_before.py
from pyspark.sql import SparkSession

spark = SparkSession.builder.getOrCreate()
spark.createDataFrame([(i, i * i) for i in range(1, 5)], "n int, square int").show()
