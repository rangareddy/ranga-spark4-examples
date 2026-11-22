# Spark 4.1 | Building the statement as a string, the form parameter markers replace | SPARK-53573
# Run: ./run.sh 4.1 spark-4.1/15_parameter_markers_before.py
from pyspark.sql import SparkSession

spark = SparkSession.builder.getOrCreate()
spark.sql("CREATE OR REPLACE TEMP VIEW orders AS SELECT * FROM VALUES "
          "(1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D) AS t(id,region,amount)")

t, n = "orders", 2
spark.sql(f"SELECT * FROM {t} ORDER BY id LIMIT {n}").show()   # works, until the input is hostile
