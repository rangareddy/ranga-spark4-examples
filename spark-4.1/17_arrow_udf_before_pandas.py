# Spark 4.1 | A pandas UDF, the vectorised form that arrow_udf replaces | SPARK-52214
# Run: ./run.sh 4.1 spark-4.1/17_arrow_udf_before_pandas.py --pip "pyarrow pandas"
import pandas as pd
from pyspark.sql import SparkSession
from pyspark.sql.functions import pandas_udf, col

spark = SparkSession.builder.getOrCreate()
df = spark.sql("SELECT * FROM VALUES (1, 10.0D), (2, 20.0D) AS t(id, amount)")

@pandas_udf("double")
def with_tax(amount: pd.Series) -> pd.Series:
    return amount * 1.18

df.select("id", with_tax(col("amount")).alias("gross")).show()   # 11.799999999999999, 23.599999999999998
