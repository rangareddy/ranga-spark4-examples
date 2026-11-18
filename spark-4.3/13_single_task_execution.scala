// Project Feather: opt-in single-task execution for small queries (SPARK-57851).
// Run on apache/spark:4.3.0-python3 with spark-shell, feeding this file on standard input.
def operators(sql: String): String = {
  val plan = spark.sql("EXPLAIN FORMATTED " + sql).collect().map(_.getString(0)).mkString("\n")
  "\\(\\d+\\) (\\w+)".r.findAllMatchIn(plan).map(_.group(1)).mkString(" > ")
}
val query = "SELECT region, sum(amount) AS total FROM VALUES (1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D) AS t(id,region,amount) GROUP BY region ORDER BY region"
spark.conf.set("spark.sql.adaptive.enabled", "false")
println("OFF " + operators(query))
spark.conf.set("spark.sql.optimizer.singleTaskExecution.enabled", "true")
println("ON  " + operators(query))
println("RESULT " + spark.sql(query).collect().mkString(" "))
sys.exit(0)
