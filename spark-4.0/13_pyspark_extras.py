# Named and unnamed parameter markers, a polymorphic Python UDTF, and the plotting API.
# Run on apache/spark:4.0.5-python3 with: pip install plotly
from pyspark.sql import SparkSession
from pyspark.sql.functions import udtf
from pyspark.sql.types import StructType
from pyspark.sql.udtf import AnalyzeArgument, AnalyzeResult

spark = SparkSession.builder.getOrCreate()
spark.sparkContext.setLogLevel("ERROR")

# parameter markers: named :a and unnamed ?
print("NAMED", spark.sql("SELECT :a + :b AS s", args={"a": 1, "b": 2}).collect())
print("UNNAMED", spark.sql("SELECT ? + ? AS s", args=[1, 2]).collect())
# a value that looks like SQL stays a value
print("SAFE", spark.sql("SELECT :s AS s", args={"s": "x'; DROP TABLE t; --"}).collect())


# a polymorphic UDTF: analyze() decides the output schema from the argument
@udtf
class Echo:
    @staticmethod
    def analyze(a: AnalyzeArgument) -> AnalyzeResult:
        return AnalyzeResult(StructType().add("c1", a.dataType))

    def eval(self, a):
        yield (a,)


spark.udtf.register("echo", Echo)
print("ECHO_INT", spark.sql("SELECT * FROM echo(5)").schema.simpleString(), spark.sql("SELECT * FROM echo(5)").collect())
print("ECHO_STR", spark.sql("SELECT * FROM echo('x')").schema.simpleString())

# plotting: df.plot returns a Plotly figure
df = spark.createDataFrame([("a", 1), ("b", 3)], ["k", "v"])
figure = df.plot.bar(x="k", y="v")
print("PLOT", type(figure).__module__ + "." + type(figure).__name__)
