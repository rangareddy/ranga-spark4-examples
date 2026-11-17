val a = spark.range(3).toDF("id")
val b = a.selectExpr("id * 10 AS tenfold")
a.zip(b).show()
val c = spark.range(3).toDF("x")
try { a.zip(c).show() } catch { case e: Exception => println("ERR: " + e.getMessage.take(200)) }
