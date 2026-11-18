import org.apache.spark.sql.streaming.Trigger
import org.apache.spark.sql.functions._
val boot = "localhost:9092"
val topic = "rtm_tarball_41"
def produce(msgs: Seq[String]): Unit = msgs.toDF("value").write.format("kafka").option("kafka.bootstrap.servers", boot).option("topic", topic).save()
produce(Seq("seed"))
val out = spark.readStream.format("kafka").option("kafka.bootstrap.servers", boot).option("subscribe", topic).option("startingOffsets", "latest").load().select(upper(col("value").cast("string")).alias("v"))
val q = out.writeStream.format("console").outputMode("update").trigger(Trigger.RealTime("5 seconds")).start()
println("RTM41 started active=" + q.isActive)
Thread.sleep(12000)
produce(Seq("hello", "real", "time"))
Thread.sleep(14000)
println("RTM41 exception=" + q.exception)
q.stop()
sys.exit(0)
