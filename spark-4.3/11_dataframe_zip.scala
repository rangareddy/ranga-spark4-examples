// Spark 4.3 | DataFrame.zip merges DataFrames that are projections of ONE plan (SPARK-55886).
// Run: spark-shell -i 11_dataframe_zip.scala   (pyspark 4.3.0 or the 4.3.0 tarball, SPARK_HOME unset)
import scala.util.control.NonFatal

val a = spark.range(3).toDF("id")
val b = a.selectExpr("id * 10 AS tenfold")          // computed from a: same plan, different projection
a.zip(b).show()

// Two DataFrames built from the same range also share a plan, so this works too.
val c = spark.range(3).toDF("x")
a.zip(c).show()

// Anything that is not a projection of the same plan fails with ZIP_PLANS_NOT_MERGEABLE.
def attempt(name: String)(f: => Unit): Unit =
  try { f; println(name + ": ok") }
  catch { case NonFatal(e) => println(name + ": " + e.getMessage.takeWhile(_ != '.').take(80)) }

attempt("different length")   { a.zip(spark.range(5).toDF("y")).collect() }
attempt("unrelated source")   { a.zip(Seq(7, 8, 9).toDF("z")).collect() }
attempt("repartitioned copy") { a.zip(a.repartition(3).selectExpr("id * 10 AS t")).collect() }
sys.exit(0)
