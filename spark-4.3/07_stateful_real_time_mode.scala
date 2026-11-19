// Spark 4.3 | Stateful real-time mode: a running count under Trigger.RealTime | SPARK-58635
// Needs a Kafka broker. Run (verified on 4.3.0 with a broker on localhost:9092):
//   spark-shell --master 'local[4]' --packages org.apache.spark:spark-sql-kafka-0-10_2.13:4.3.0 -i 07_stateful_real_time_mode.scala
// BOOT and TOPIC environment variables override the broker address and the topic.
//
// Slots: every task of a real-time query runs at once, so
//   free slots >= Kafka reader tasks + spark.sql.shuffle.partitions
// Here 1 reader task + 2 shuffle partitions = 3, which fits local[4]. With the default 200 partitions on
// local[2] the query fails: CONCURRENT_SCHEDULER_INSUFFICIENT_SLOT ... needs 201 concurrent task slots ... only 2 are currently free.
// Delete the checkpoint between runs: rm -rf /tmp/rtm43_ckpt3 (a stale one resumes old offsets).
import org.apache.spark.sql.streaming.Trigger
import org.apache.spark.sql.functions._

val boot  = sys.env.getOrElse("BOOT", "localhost:9092")   // inside the Docker network: BOOT=kafka:29092
val topic = sys.env.getOrElse("TOPIC", "rtm43_demo3")
spark.conf.set("spark.sql.shuffle.partitions", "2")

def produce(msgs: Seq[String]): Unit =
  msgs.toDF("value").write.format("kafka")
    .option("kafka.bootstrap.servers", boot).option("topic", topic).save()
produce(Seq("seed"))                       // creates the topic before the query subscribes

val counts = spark.readStream.format("kafka")
  .option("kafka.bootstrap.servers", boot).option("subscribe", topic)
  .option("startingOffsets", "latest").load()
  .select(col("value").cast("string").alias("word"))
  .groupBy("word").count()

// Before 4.3 this query needed Trigger.ProcessingTime("5 seconds"); only the trigger changes.
val q = counts.writeStream.format("console").outputMode("update")
  .option("checkpointLocation", "/tmp/rtm43_ckpt3")
  .trigger(Trigger.RealTime("5 seconds")).start()

Thread.sleep(15000)
produce(Seq("a", "b", "a", "a"))           // the console prints a 1, a 2, a 3, b 1
Thread.sleep(16000)
println("exception=" + q.exception)        // None
q.stop()
sys.exit(0)
