import pyarrow as pa
import pyarrow.compute as pc
from pyspark.sql import SparkSession
from pyspark.sql.functions import arrow_udf, col

spark = SparkSession.builder.appName("arrow-udf").getOrCreate()
spark.sparkContext.setLogLevel("ERROR")


@arrow_udf("double")
def with_tax(amount: pa.Array) -> pa.Array:
    return pc.multiply(amount, 1.18)


df = spark.sql("SELECT * FROM VALUES (1,'eu',10.0D),(2,'us',20.0D) AS t(id, region, amount)")
df.select("id", with_tax(col("amount")).alias("gross")).show()
