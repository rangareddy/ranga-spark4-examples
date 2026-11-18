from pyspark.sql import SparkSession
from pyspark.sql.datasource import DataSource, DataSourceReader
from pyspark.sql.functions import udtf

spark = SparkSession.builder.appName("datasource-udtf").getOrCreate()
spark.sparkContext.setLogLevel("ERROR")


class CounterDataSource(DataSource):
    @classmethod
    def name(cls):
        return "counter"

    def schema(self):
        return "n INT, square INT"

    def reader(self, schema):
        return CounterReader(self.options)


class CounterReader(DataSourceReader):
    def __init__(self, options):
        self.limit = int(options.get("limit", 3))

    def read(self, partition):
        for i in range(1, self.limit + 1):
            yield (i, i * i)


spark.dataSource.register(CounterDataSource)
spark.read.format("counter").option("limit", 4).load().show()

spark.sql("CREATE OR REPLACE TEMP VIEW c USING counter OPTIONS (limit '3')")
spark.sql("SELECT n, square FROM c WHERE n > 1").show()


@udtf(returnType="word: string, length: int")
class SplitWords:
    def eval(self, text: str):
        for w in text.split():
            yield (w, len(w))


spark.udtf.register("split_words", SplitWords)
spark.sql("SELECT * FROM split_words('spark four point zero')").show()
