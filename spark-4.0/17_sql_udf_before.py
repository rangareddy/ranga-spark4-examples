# Spark 4.0 | A Python UDF next to a SQL UDF, and the plan of each | SPARK-46057
# Run: ./run.sh 4.0 spark-4.0/17_sql_udf_before.py
from pyspark.sql import SparkSession

spark = SparkSession.builder.getOrCreate()
spark.sql("CREATE OR REPLACE TEMP VIEW orders AS SELECT * FROM VALUES "
          "(1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D) AS t(id,region,amount)")

spark.udf.register("add_tax_py", lambda x: x * 1.18, "double")
spark.sql("SELECT id, add_tax_py(amount) AS gross FROM orders").explain()   # Project [... pythonUDF0 ...]

spark.sql("CREATE OR REPLACE TEMPORARY FUNCTION add_tax(x DOUBLE) RETURNS DOUBLE RETURN x * 1.18")
spark.sql("SELECT id, add_tax(amount) AS gross FROM orders").explain()      # LocalTableScan, body inlined
spark.sql("SELECT id, add_tax(amount) AS gross FROM orders ORDER BY id").show()
