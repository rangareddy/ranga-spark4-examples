# Spark 4.3 | Spark Connect: operation id on a DataFrame, and the REST endpoints for sessions and operations.
# Start a local Connect server first (pyspark 4.3.0 installed, SPARK_HOME unset):
#   pip install "pyspark[connect]==4.3.0"
#   $(python -c "import pyspark;print(pyspark.__path__[0])")/sbin/start-connect-server.sh --conf spark.connect.grpc.binding.port=15002
# Then:  python 16_connect_operation_ids.py   (the UI is on port 4040, or the next free port, see the server log)
import json
import os
import urllib.request

from pyspark.sql import SparkSession

UI = os.environ.get("UI", "http://localhost:4040")   # set UI=http://localhost:4041 if the log says SparkUI started on 4041

with SparkSession.builder.remote("sc://localhost:15002").getOrCreate() as spark:
    df = spark.sql("SELECT count(*) AS n FROM range(1000000)")
    df.collect()
    print("operation_id:", df.executionInfo.operation_id)

app_id = json.load(urllib.request.urlopen(f"{UI}/api/v1/applications"))[0]["id"]
for path in ("sessions", "operations"):
    rows = json.load(urllib.request.urlopen(f"{UI}/api/v1/applications/{app_id}/connect/{path}"))
    print(path, "->", len(rows), "row(s); keys:", sorted(rows[0]))
