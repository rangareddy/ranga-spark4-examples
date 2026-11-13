#!/usr/bin/env bash
# Run one example in a Spark container.
#   ./run.sh <4.0|4.1|4.2|4.3> <file.sql|file.py> [--pip "pkg1 pkg2"]
# 4.0, 4.2 and 4.3 use the official apache/spark images; 4.1 uses rangareddy1988/ranga-spark4
# (Spark 4.1.3). Override with SPARK_IMAGE=<image>.
set -euo pipefail
rel="$1"; file="$2"; shift 2
pip_pkgs=""
if [ "${1:-}" = "--pip" ]; then pip_pkgs="$2"; fi
case "$rel" in
  4.0) image="apache/spark:4.0.5-python3" ;;
  4.1) image="rangareddy1988/ranga-spark4:latest" ;;
  4.2) image="apache/spark:4.2.1-python3" ;;
  4.3) image="apache/spark:4.3.0-python3" ;;
  *) echo "release must be 4.0, 4.1, 4.2 or 4.3"; exit 1 ;;
esac
image="${SPARK_IMAGE:-$image}"
case "$file" in
  *.sql) cmd="/opt/spark/bin/spark-submit --master local[2] --conf spark.sql.shuffle.partitions=2 /work/tools/run_sql.py /work/$file" ;;
  *.py)  cmd="/opt/spark/bin/spark-submit --master local[2] --conf spark.sql.shuffle.partitions=2 /work/$file" ;;
  *) echo "run .sql or .py files"; exit 1 ;;
esac
if [ -n "$pip_pkgs" ]; then
  cmd="pip install -q --disable-pip-version-check --target /tmp/pylib $pip_pkgs >/dev/null 2>&1 && PYTHONPATH=/tmp/pylib $cmd"
fi
docker run --rm --entrypoint bash -v "$(pwd):/work" -w /work "$image" -c "$cmd" 2>&1 | grep -v -E "WARN|INFO|SLF4J|^\{\"ts\"|^$|Setting default log level|To adjust logging|log4j"
