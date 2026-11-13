#!/usr/bin/env bash
# Run the Spark 4.1 declarative pipeline example: ./run_pipeline.sh 4.1
set -euo pipefail
rel="${1:-4.1}"
case "$rel" in
  4.1) image="apache/spark:4.1.3-python3" ;;
  4.2) image="apache/spark:4.2.1-python3" ;;
  4.3) image="apache/spark:4.3.0-python3" ;;
  *) echo "pipelines need 4.1, 4.2 or 4.3"; exit 1 ;;
esac
image="${SPARK_IMAGE:-$image}"
docker run --rm --entrypoint bash -v "$(pwd)/spark-4.1/07_declarative_pipelines:/work" -w /work "$image" -c \
  "pip install -q --target /tmp/pylib pyyaml grpcio grpcio-status protobuf googleapis-common-protos zstandard pandas pyarrow && \
   rm -rf /work/spark-warehouse /work/metastore_db /tmp/sdp && export PYTHONPATH=/tmp/pylib && unset SPARK_REMOTE SPARK_MASTER && \
   /opt/spark/bin/spark-pipelines dry-run --spec spark-pipeline.yml && \
   /opt/spark/bin/spark-pipelines run --spec spark-pipeline.yml" 2>&1 | grep -v WARN
