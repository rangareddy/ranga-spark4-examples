# Declarative pipeline example (Spark 4.1)

Needs the pipelines CLI packages. From the repo root:

```bash
./run_pipeline.sh 4.1
```

The script installs `pyyaml grpcio grpcio-status protobuf googleapis-common-protos zstandard pandas pyarrow`
inside the container, then runs `spark-pipelines dry-run` and `spark-pipelines run`.
