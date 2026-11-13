// Spark 4.3 | Stateful real-time mode: aggregation, dropDuplicates, transformWithState | SPARK-58635
// Needs Kafka. Not run by run.sh. Set spark.sql.shuffle.partitions to what the cluster can run concurrently.
import org.apache.spark.sql.streaming.Trigger
import org.apache.spark.sql.functions._

val counts = spark.readStream.format("kafka")
  .option("kafka.bootstrap.servers", "kafka:29092").option("subscribe", "rtm43_demo3")
  .option("startingOffsets", "latest").load()
  .select(col("value").cast("string").alias("word"))
  .groupBy("word").count()

counts.writeStream.format("console").outputMode("update")
  .option("checkpointLocation", "/tmp/rtm43_ckpt3")
  .trigger(Trigger.RealTime("5 seconds")).start()
