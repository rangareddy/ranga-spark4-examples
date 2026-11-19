# Spark 4.2 | Real-time mode from PySpark: a stateless Kafka filter | SPARK-54660
# Needs a Kafka broker and the Kafka source:
#   spark-submit --packages org.apache.spark:spark-sql-kafka-0-10_2.13:4.2.1 spark-4.2/23_realtime_mode_pyspark.py
# First block: the micro-batch trigger. Second block: the real-time trigger. Run them as two separate queries.
from pyspark.sql import SparkSession, functions as F

spark = SparkSession.builder.config("spark.sql.shuffle.partitions", "2").getOrCreate()

events = (spark.readStream.format("kafka")
    .option("kafka.bootstrap.servers", "localhost:9092")
    .option("subscribe", "events").option("startingOffsets", "latest").load()
    .select(F.col("value").cast("string").alias("event"))
    .where(F.col("event").startswith("ERROR")))

(events.writeStream.format("console")
    .outputMode("update")
    .option("checkpointLocation", "/tmp/ckpt_micro")
    .trigger(processingTime="5 seconds")        # micro-batch
    .start())


# needs a Kafka broker; `events` is the same source and filter as above
(events.writeStream.format("console")
    .outputMode("update")                       # required by real-time mode
    .option("checkpointLocation", "/tmp/ckpt_rtm")
    .trigger(realTime="5 seconds")              # the whole change
    .start())
