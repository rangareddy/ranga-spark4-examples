# Spark 4.1 | A Python loop around SQL, the form SQL scripting replaces | SPARK-54499
# Run: ./run.sh 4.1 spark-4.1/12_sql_scripting_before.py
from pyspark.sql import SparkSession

spark = SparkSession.builder.getOrCreate()
spark.sql("CREATE OR REPLACE TEMP VIEW orders AS SELECT * FROM VALUES "
          "(1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D) AS t(id,region,amount)")

rows = spark.sql("""SELECT region, sum(amount) AS total
                    FROM orders GROUP BY region ORDER BY region""").collect()
print(" ".join(f"{r.region}={r.total}" for r in rows))   # eu=40.0 us=25.0
