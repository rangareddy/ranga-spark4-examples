# Spark 4.0 | Check that connector artifacts exist for 4.0.5 on Maven Central
# Run: python3 spark-4.0/19_check_maven_artifacts.py
import urllib.request

# group, artifact: edit to match your spark.jars.packages
ARTIFACTS = [
    ("org.apache.spark", "spark-sql-kafka-0-10_2.13"),
    ("org.apache.spark", "spark-avro_2.13"),
]
SPARK = "4.0.5"

for group, artifact in ARTIFACTS:
    base = f"https://repo1.maven.org/maven2/{group.replace('.', '/')}/{artifact}"
    try:
        urllib.request.urlopen(f"{base}/{SPARK}/{artifact}-{SPARK}.pom", timeout=10)
        print(f"OK       {artifact}:{SPARK}")
    except Exception:
        print(f"MISSING  {artifact}  -> no {SPARK} build published")
