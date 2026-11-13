"""Run a .sql file statement by statement with spark.sql and print each result.

A statement ends at a line ending with ';'. A script starting with an unindented BEGIN
runs until an unindented END; a $$ ... $$ block is kept whole. Errors are printed and the
run continues, so a file can show a failing statement on purpose.
"""
import re
import sys

from pyspark.sql import SparkSession


def statements(text):
    cur, depth, dollars = [], 0, 0
    for line in text.splitlines():
        s = line.strip()
        if not cur and (not s or s.startswith("--")):
            continue
        cur.append(line)
        dollars += line.count("$$")
        if re.match(r"BEGIN\b", line):
            depth += 1
        if re.match(r"END;?\s*$", line):
            depth -= 1
        code = re.sub(r"\s--.*$", "", s).rstrip()
        if code.endswith(";") and depth <= 0 and dollars % 2 == 0:
            yield "\n".join(cur).rstrip().rstrip(";")
            cur, depth, dollars = [], 0, 0
    if cur:
        yield "\n".join(cur).rstrip().rstrip(";")


spark = SparkSession.builder.config("spark.ui.enabled", "false").getOrCreate()
spark.sparkContext.setLogLevel("ERROR")
print("SPARK", spark.version)
for stmt in statements(open(sys.argv[1]).read()):
    print("\n>>> " + stmt.splitlines()[0][:110])
    try:
        for row in spark.sql(stmt).collect()[:12]:
            print("    ", " | ".join(str(c) for c in row))
    except Exception as e:  # noqa: BLE001
        print("    ERROR:", " ".join(str(e).split())[:400])
