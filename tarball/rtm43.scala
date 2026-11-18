import org.apache.spark.sql.streaming.Trigger
import org.apache.spark.sql.functions._
val boot = "localhost:9092"
val topic = "rtm_tarball_43"
def produce(msgs: Seq[String]): Unit = msgs.toDF("value").write.format("kafka").option("kafka.bootstrap.servers", boot).option("topic", topic).save()
produce(Seq("seed"))
val counts = spark.readStream.format("kafka").option("kafka.bootstrap.servers", boot).option("subscribe", topic).option("startingOffsets", "latest").load().select(col("value").cast("string").alias("word")).groupBy("word").count()
val q = counts.writeStream.format("console").outputMode("update").option("checkpointLocation", "/tmp/rtm_tarball_43_ckpt").trigger(Trigger.RealTime("5 seconds")).start()
println("RTM43 started active=" + q.isActive)
Thread.sleep(14000)
produce(Seq("a", "b", "a", "a"))
Thread.sleep(16000)
println("RTM43 exception=" + q.exception)
q.stop()
sys.exit(0)
