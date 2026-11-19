# Spark 4.3 | PySpark real-time query with a watermark, dropDuplicates and a windowed count.
# Needs a Kafka broker. Run (verified on 4.3.0 with a broker on localhost:9092, Python 3.11 workers):
#   PYSPARK_PYTHON=python3.11 spark-submit --master 'local[8]' \
#     --packages org.apache.spark:spark-sql-kafka-0-10_2.13:4.3.0 07b_real_time_dedup_window.py
# Slots: Kafka reader tasks + shuffle partitions of each stateful step = 1 + 2 + 2 = 5 free slots.
# Delete the checkpoint between runs: rm -rf /tmp/rtm_clicks (a stale one resumes old offsets).
import json
import os
import time

from pyspark.sql import SparkSession, functions as F

BOOT = os.environ.get("BOOT", "localhost:9092")   # inside the Docker network: kafka:29092
TOPIC = os.environ.get("TOPIC", "clicks")

spark = SparkSession.builder.getOrCreate()
spark.conf.set("spark.sql.shuffle.partitions", "2")


def produce(rows):
    (spark.createDataFrame([(json.dumps(r),) for r in rows], "value string")
          .write.format("kafka").option("kafka.bootstrap.servers", BOOT).option("topic", TOPIC).save())


produce([{"event_id": "seed", "aisle": "x", "ts": "2026-11-01 10:00:00"}])   # creates the topic

clicks = (spark.readStream.format("kafka")
    .option("kafka.bootstrap.servers", BOOT)
    .option("subscribe", TOPIC).option("startingOffsets", "latest").load()
    .select(F.from_json(F.col("value").cast("string"),
                        "event_id STRING, aisle STRING, ts TIMESTAMP").alias("e"))
    .select("e.*"))

trending = (clicks
    .withWatermark("ts", "10 seconds")
    .dropDuplicates(["event_id"])                      # resent clicks count once
    .groupBy(F.window("ts", "10 seconds"), "aisle")
    .count())

q = (trending.writeStream.format("console")
    .outputMode("update")                              # required by real-time mode
    .option("checkpointLocation", "/tmp/rtm_clicks")
    .trigger(realTime="30 seconds")                    # the whole change
    .start())

time.sleep(15)
produce([{"event_id": "e1", "aisle": "milk", "ts": "2026-11-01 10:00:02"},
         {"event_id": "e1", "aisle": "milk", "ts": "2026-11-01 10:00:02"},   # resent: counted once
         {"event_id": "e2", "aisle": "milk", "ts": "2026-11-01 10:00:04"},
         {"event_id": "e3", "aisle": "eggs", "ts": "2026-11-01 10:00:05"}])
time.sleep(25)
print("exception =", q.exception())                    # None; milk reaches 2 and eggs 1
q.stop()
