// DataFrame.zip. Before: number the rows of both frames with a window, then join on the number.
// Run on Spark 4.3.0 with spark-shell -i. A window with no partition key moves every row to one partition.
import org.apache.spark.sql.expressions.Window
import org.apache.spark.sql.functions._

val a = spark.range(3).toDF("id")
val b = a.selectExpr("id * 10 AS tenfold")
val aw = a.withColumn("rn", row_number().over(Window.orderBy("id")))
val bw = b.withColumn("rn", row_number().over(Window.orderBy("tenfold")))
aw.join(bw, "rn").drop("rn").orderBy("id").show()
System.exit(0)
