# Spark 4.1 | Arrow-native UDFs | SPARK-52214, SPARK-52979
# Needs pyarrow: ./run.sh 4.1 spark-4.1/06_arrow_udf.py --pip "pyarrow pandas"
import pyarrow as pa
import pyarrow.compute as pc
from pyspark.sql import SparkSession
from pyspark.sql.functions import arrow_udf, col

spark = SparkSession.builder.getOrCreate()
df = spark.sql("SELECT * FROM VALUES (1, 10.0D), (2, 20.0D) AS t(id, amount)")


@arrow_udf("double")
def with_tax(amount: pa.Array) -> pa.Array:
    return pc.multiply(amount, 1.18)


df.select("id", with_tax(col("amount")).alias("gross")).show()
