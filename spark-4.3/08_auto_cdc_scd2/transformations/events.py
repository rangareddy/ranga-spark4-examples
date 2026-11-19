import os

from pyspark import pipelines as dp
from pyspark.sql import SparkSession

spark = SparkSession.active()
SRC = os.environ.get("CDC_SRC", os.path.join(os.getcwd(), "src"))


@dp.table
def cdc_events():
    return spark.readStream.schema("id int, city string, version int, op string").json(SRC)
