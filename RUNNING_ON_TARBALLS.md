# Running the Spark 4 examples on release tarballs

The examples in the blog posts ran on two setups: an official `apache/spark` Docker image
(`./run.sh`, see the README) and the plain release tarball from Apache with nothing else
installed. This page is the second one, because it needs only Java and shows what a clean
install does. It is the material that used to sit in the "Spark 4 in four releases" post.

Files used below:

| File | What it is |
|:--|:--|
| `tools/runner.scala` | Reads a SQL file of statements separated by `;;` and runs each with `spark.sql` |
| `smoke/smoke40.sql` ... `smoke/smoke43.sql` | One smoke test per release, run on 4.0.5, 4.1.4, 4.2.1 and 4.3.0 |
| `tarball/datasource_udtf.py` | Python data source and UDTF, run on the 4.0.5 tarball |
| `tarball/arrow_udf.py` | `@arrow_udf`, run on the official 4.1.3 image |
| `tarball/rtm41.scala`, `tarball/rtm43.scala` | Real-time mode against Kafka on 4.1.4 and 4.3.0 |

## What you need

These are the latest releases of each line at the time of writing. The Python
column comes from each tarball's own `Requires-Python`, and all four ran on the
same Java 17 (Temurin 17.0.20), including 4.3.0.

| Line | Release | Tarball | Python for PySpark | Scala |
|:--|:--|--:|:--|:--|
| 4.0 | 4.0.5 | 523 MB | 3.9 or newer | 2.13.16 |
| 4.1 | 4.1.4 | 546 MB | 3.10 or newer | 2.13.17 |
| 4.2 | 4.2.1 | 529 MB | 3.10 or newer | 2.13.18 |
| 4.3 | 4.3.0 | 535 MB | 3.11 or newer | 2.13.18 |

The Python column decides which examples you can run from a tarball. A machine
with Python 3.9 can run the SQL and Scala examples on all four releases and the
PySpark examples on 4.0 only.

## Download and verify

The tarball comes from the Apache CDN and the checksum from the main Apache
distribution site, so the two come from different hosts. The CDN keeps only
current releases; an older patch release is under
`https://archive.apache.org/dist/spark/`. This is the script that fetched the four
files above, each one verified:

```bash
mkdir -p ~/spark-4.x && cd ~/spark-4.x
for v in 4.0.5 4.1.4 4.2.1 4.3.0; do
  f=spark-$v-bin-hadoop3.tgz
  curl -sSf -C - -O "https://dlcdn.apache.org/spark/spark-$v/$f"
  curl -sSf -o "$f.sha512" "https://downloads.apache.org/spark/spark-$v/$f.sha512"
  got=$(shasum -a 512 "$f" | awk '{print $1}')
  if tr -d ' \n\r' < "$f.sha512" | tr 'A-F' 'a-f' | grep -q "$got"; then
    echo "OK   $f"; tar -xzf "$f"
  else
    echo "BAD  $f"
  fi
done
```

## Four things that went wrong first

Each of these cost a run, so they are worth knowing before you start.

**A different Spark answers.** The first run printed `SPARK 2.4.4`. The shell had
`SPARK_HOME` pointing at an older install, and the `spark-shell` script honours
it over the directory it lives in. Every result from that run was invalid. Start
Spark with a clean environment (`env -i`) and print `spark.version` first.

**`spark-shell -i script` ran nothing.** On this setup the REPL started and quit
without executing the file. Feeding the script on standard input (`< script.scala`)
worked on all four releases.

**The driver address.** Without pinning the driver to localhost, a run hung and
logged `RpcEndpointNotFoundException: Cannot find endpoint:
spark://CoarseGrainedScheduler@...`. With `spark.driver.bindAddress` and
`spark.driver.host` set to `127.0.0.1` every run completed.

**Python is too old.** The 4.1 and 4.2 tarballs declare Python 3.10 or newer and 4.3
declares 3.11. On 4.2.1 with Python 3.9 a Python worker failed with a `TypeError`, so
a stock macOS Python runs only the 4.0 PySpark examples.

## A runner that executes a SQL file

The runner reads a file of statements separated by a line containing only `;;`.
A line starting with `-- ###` is printed as a heading, and the SQL after it runs.
It uses only `spark.sql`, so any SQL statement from the blog posts works in it.

```scala
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
```

Save it as `tools/runner.scala`, and run any SQL file with a function like this, where
`JAVA` is a JDK 17 home:

```bash
run() {   # run <release> <sql-file>
  env -i HOME="$HOME" PATH=/usr/bin:/bin JAVA_HOME="$JAVA" SPEC="$2" \
    ~/spark-4.x/spark-$1-bin-hadoop3/bin/spark-shell --master 'local[2]' \
    --conf spark.ui.enabled=false --conf spark.eventLog.enabled=false \
    --conf spark.driver.bindAddress=127.0.0.1 --conf spark.driver.host=127.0.0.1 \
    --conf spark.sql.shuffle.partitions=2 < tools/runner.scala
}
run 4.0.5 smoke40.sql
```


Run a smoke file with `run 4.0.5 smoke/smoke40.sql`, and the same for the other three releases.

## Cleaning up

Delete the extracted folders when you are done. Each unpacks to about 600 MB, so
four take roughly 2.4 GB, in addition to the tarballs.
