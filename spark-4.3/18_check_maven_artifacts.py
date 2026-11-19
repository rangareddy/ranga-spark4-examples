# Check that the connector artifacts your job needs exist for Spark 4.3.0. Edit ARTIFACTS to match spark.jars.packages.
import urllib.request

ARTIFACTS = [
    ("org.apache.spark", "spark-sql-kafka-0-10_2.13"),
    ("org.apache.spark", "spark-avro_2.13"),
]
SPARK = "4.3.0"

for group, artifact in ARTIFACTS:
    base = f"https://repo1.maven.org/maven2/{group.replace('.', '/')}/{artifact}"
    try:
        urllib.request.urlopen(f"{base}/{SPARK}/{artifact}-{SPARK}.pom", timeout=10)
        print(f"OK       {artifact}:{SPARK}")
    except Exception:
        print(f"MISSING  {artifact}  -> no {SPARK} build published")
