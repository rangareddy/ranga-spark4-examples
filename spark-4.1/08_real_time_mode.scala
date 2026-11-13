// Spark 4.1 | Structured Streaming real-time mode, stateless, Scala only | SPARK-53736
// Needs Kafka. Not run by run.sh. Paste into spark-shell on a Spark 4.1 cluster with a Kafka topic.
import org.apache.spark.sql.streaming.Trigger
import org.apache.spark.sql.functions._

val out = spark.readStream.format("kafka")
  .option("kafka.bootstrap.servers", "kafka:29092")
  .option("subscribe", "rtm_demo_in2").option("startingOffsets", "latest").load()
  .select(upper(col("value").cast("string")).alias("v"))

val q = out.writeStream.format("console").outputMode("update")
  .trigger(Trigger.RealTime("5 seconds")).start()
