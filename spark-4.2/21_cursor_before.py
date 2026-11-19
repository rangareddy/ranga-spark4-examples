# Spark 4.2 | Row-by-row logic through the DataFrame API, the form SQL cursors replace
# Run: ./run.sh 4.2 spark-4.2/21_cursor_before.py
from pyspark.sql import SparkSession
spark = SparkSession.builder.getOrCreate()
rows = spark.sql("SELECT col1 FROM VALUES (10), (20), (30)").collect()
total = sum(r[0] for r in rows)
print(total)   # 60
