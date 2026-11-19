// Spark 4.2 | The CHANGES clause succeeding on Spark's in-memory test catalog | SPARK-55948, SPARK-55949
// Follows ChangelogEndToEndSuite in the Spark source. Needs the tests jar:
//   curl -LO https://repo1.maven.org/maven2/org/apache/spark/spark-catalyst_2.13/4.2.1/spark-catalyst_2.13-4.2.1-tests.jar
//   spark-shell --jars spark-catalyst_2.13-4.2.1-tests.jar -i spark-4.2/18_changes_clause_catalog.scala
import java.util
import org.apache.spark.sql.catalyst.InternalRow
import org.apache.spark.sql.connector.catalog._
import org.apache.spark.sql.connector.catalog.Changelog._
import org.apache.spark.sql.types.{LongType, StringType}
import org.apache.spark.unsafe.types.UTF8String

// register the catalog and create a table with two columns
spark.conf.set("spark.sql.catalog.cdc", classOf[InMemoryChangelogCatalog].getName)
val cat = spark.sessionState.catalogManager.catalog("cdc").asInstanceOf[InMemoryChangelogCatalog]
val ident = Identifier.of(Array.empty, "orders")
cat.createTable(ident, Array(Column.create("id", LongType), Column.create("data", StringType)),
  Array.empty, new util.HashMap[String, String]())

// three recorded changes: two inserts and a delete
def row(id: Long, data: String, kind: String, version: Long, ts: Long) =
  InternalRow(id, UTF8String.fromString(data), UTF8String.fromString(kind), version, ts)
cat.addChangeRows(ident, Seq(
  row(1L, "a", CHANGE_TYPE_INSERT, 1L, 1000000L),
  row(2L, "b", CHANGE_TYPE_INSERT, 2L, 2000000L),
  row(2L, "b", CHANGE_TYPE_DELETE, 3L, 3000000L)))

spark.sql("SELECT * FROM cdc.orders CHANGES FROM VERSION 1 TO VERSION 3").show(false)
// +---+----+------------+---------------+-------------------+
// |id |data|_change_type|_commit_version|_commit_timestamp  |
// +---+----+------------+---------------+-------------------+
// |1  |a   |insert      |1              |1970-01-01 00:00:01|
// |2  |b   |insert      |2              |1970-01-01 00:00:02|
// |2  |b   |delete      |3              |1970-01-01 00:00:03|
// +---+----+------------+---------------+-------------------+

// the same feed through the DataFrame API, with an ending version
spark.read.option("startingVersion", "1").option("endingVersion", "2").changes("cdc.orders").show(false)
// the rows with _commit_version 1 and 2

sys.exit(0)
