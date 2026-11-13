# Spark 4.1 | Parameter markers nearly anywhere | SPARK-53573
from pyspark.sql import SparkSession

spark = SparkSession.builder.getOrCreate()
spark.sql("CREATE OR REPLACE TEMP VIEW orders AS SELECT * FROM VALUES "
          "(1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D) AS t(id,region,amount)")

spark.sql("SELECT * FROM IDENTIFIER(:t) ORDER BY id LIMIT :n",
          args={"t": "orders", "n": 2}).show()

spark.sql("""BEGIN
  DECLARE x INT DEFAULT :start;
  SET x = x + 1;
  SELECT x;
END""", args={"start": 41}).show()
