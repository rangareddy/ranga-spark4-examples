import scala.io.Source

val specPath = sys.env("SPEC")
val statements = Source.fromFile(specPath).mkString.split("\n;;\n").map(_.trim).filter(_.nonEmpty)
println("SPARK " + spark.version + " | Scala " + scala.util.Properties.versionNumberString + " | Java " + System.getProperty("java.version"))

statements.foreach { block =>
  val lines = block.linesIterator.toList
  // A leading "-- ### title" line is printed as a heading; whatever follows it is the SQL.
  val (heading, sql) =
    if (lines.head.startsWith("-- ###")) (Some(lines.head.drop(7)), lines.tail.mkString("\n").trim)
    else (None, block)
  heading.foreach(h => println("\n### " + h))
  if (sql.nonEmpty) {
    println(sql.linesIterator.next().take(110))
    try spark.sql(sql).collect().take(12).foreach(r => println("   " + r.mkString(" | ")))
    catch { case e: Throwable => println("   ERROR: " + e.getMessage.linesIterator.next().take(200)) }
  }
}
sys.exit(0)
