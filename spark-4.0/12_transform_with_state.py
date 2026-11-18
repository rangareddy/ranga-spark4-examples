# transformWithState (SPARK-46815) read back through the state data source (SPARK-45511).
# Run on apache/spark:4.0.5-python3. Two prerequisites, each of which fails with its own error if missing:
#   pip install pyarrow pandas protobuf grpcio grpcio-status googleapis-common-protos
#   --conf spark.sql.streaming.stateStore.providerClass=org.apache.spark.sql.execution.streaming.state.RocksDBStateStoreProvider
import shutil
import time

import pandas as pd
from pyspark.sql import SparkSession
from pyspark.sql.streaming import StatefulProcessor, StatefulProcessorHandle
from pyspark.sql.types import IntegerType, StructField, StructType

spark = SparkSession.builder.config("spark.sql.shuffle.partitions", "2").getOrCreate()
spark.sparkContext.setLogLevel("ERROR")


class CountProcessor(StatefulProcessor):
    def init(self, handle: StatefulProcessorHandle) -> None:
        # one integer of state per key
        self.count = handle.getValueState("count", StructType([StructField("value", IntegerType(), True)]))

    def handleInputRows(self, key, rows, timerValues):
        total = self.count.get()[0] if self.count.exists() else 0
        for pdf in rows:
            total += len(pdf)
        self.count.update((total,))
        yield pd.DataFrame({"id": [key[0]], "count": [total]})

    def close(self) -> None:
        pass


checkpoint = "/tmp/ckpt_tws"
shutil.rmtree(checkpoint, ignore_errors=True)
stream = spark.readStream.format("rate").option("rowsPerSecond", 6).load().selectExpr("CAST(value % 3 AS STRING) AS id")
counts = stream.groupBy("id").transformWithStateInPandas(
    statefulProcessor=CountProcessor(), outputStructType="id STRING, count INT", outputMode="Update", timeMode="None")
query = (counts.writeStream.format("memory").queryName("counts").outputMode("Update")
         .option("checkpointLocation", checkpoint).start())
time.sleep(40)
query.stop()

print("COUNTS", sorted(tuple(r) for r in spark.sql("SELECT id, max(count) FROM counts GROUP BY id").collect()))
state = spark.read.format("statestore").option("stateVarName", "count").load(checkpoint)
print("STATE_SCHEMA", state.schema.simpleString())
print("STATE_ROWS", sorted((r.key.id, r.value.value) for r in state.collect()))
