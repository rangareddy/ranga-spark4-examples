# Spark 4.1 | A loop of joins with a fixed depth, the form recursive CTEs replace | SPARK-24497
# Run: ./run.sh 4.1 spark-4.1/13_recursive_cte_before.py
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, lit

spark = SparkSession.builder.getOrCreate()
spark.sql("CREATE OR REPLACE TEMP VIEW emp AS SELECT * FROM VALUES "
          "('ceo', CAST(NULL AS STRING)), ('vp', 'ceo'), ('dir', 'vp'), ('mgr', 'dir') AS t(name, boss)")

emp = spark.table("emp")
level = spark.sql("SELECT name, 0 AS lvl FROM emp WHERE boss IS NULL")
result = level
for i in range(1, 4):                       # the depth has to be known up front
    level = (level.alias("o").join(emp.alias("e"), col("e.boss") == col("o.name"))
             .select(col("e.name").alias("name"), lit(i).alias("lvl")))
    result = result.union(level)
result.orderBy("lvl").show()                # ceo 0, vp 1, dir 2, mgr 3
