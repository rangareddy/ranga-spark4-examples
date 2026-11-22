// Spark 4.1 | Real-time mode next to the micro-batch trigger, stateless, Scala only | SPARK-53736
// Needs a Kafka broker and the Kafka source:
//   spark-shell --packages org.apache.spark:spark-sql-kafka-0-10_2.13:4.1.4 -i spark-4.1/11_real_time_before_and_after.scala
// Change BOOT and TOPIC for your broker. Run the two queries one after the other.
import org.apache.spark.sql.functions._
import org.apache.spark.sql.streaming.Trigger

val BOOT = sys.env.getOrElse("BOOT", "kafka:29092")
val TOPIC = sys.env.getOrElse("TOPIC", "events")
spark.conf.set("spark.sql.shuffle.partitions", "4")

// stateless: uppercase every record
val out = spark.readStream.format("kafka")
  .option("kafka.bootstrap.servers", BOOT)
  .option("subscribe", TOPIC).option("startingOffsets", "latest").load()
  .select(upper(col("value").cast("string")).alias("v"))

// 1. micro-batch trigger: rows appear when each batch ends
val q1 = out.writeStream.format("console").outputMode("update")
  .option("checkpointLocation", "/tmp/ckpt_micro")
  .trigger(Trigger.ProcessingTime("5 seconds")).start()
Thread.sleep(20000)
q1.stop()

// 2. the real-time trigger replaces the micro-batch trigger
val q2 = out.writeStream.format("console").outputMode("update")
  .option("checkpointLocation", "/tmp/ckpt_rtm")
  .trigger(Trigger.RealTime("5 seconds")).start()
Thread.sleep(20000)
q2.stop()
