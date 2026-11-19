# Auto CDC with SCD Type 2 (Spark 4.3)

A complete pipeline: a JSON change feed in `src/`, a streaming table `cdc_events`, and the
`customers_history` Auto CDC flow from the blog post.

```bash
cd 08_auto_cdc_scd2
pip install pyyaml grpcio grpcio-status protobuf googleapis-common-protos zstandard pandas pyarrow
spark-pipelines run --spec spark-pipeline.yml          # pyspark 4.3.0, SPARK_HOME unset
```

## What was run, and what was not

Run on 4.3.0 with the default Parquet catalog. The SQL, including `TRACK HISTORY ON (city)`, parses and
plans, and the run stops where the post says it must:

```
[AUTOCDC_TARGET_DOES_NOT_SUPPORT_MERGE] Cannot start AutoCDC flow: the target table
`spark_catalog`.`default`.`customers_history` (format: parquet) does not support row-level operations.
AutoCDC requires a target backed by a connector that supports MERGE. SQLSTATE: 0A000
```

This pipeline does **not** produce the SCD Type 2 rows: that needs a catalog whose tables support row-level
operations. The Apache Iceberg 1.12.0 Spark runtime built for Spark 4.1 does not load on 4.3.0
(`class org.apache.iceberg.spark.source.SparkView can not implement org.apache.spark.sql.connector.catalog.View`),
and when this was written (2026-11-19) Maven Central had no Iceberg Spark runtime for 4.2 or 4.3.
Point the catalog at a connector built for 4.3 with `configuration:` entries in `spark-pipeline.yml`.
The expected rows for a similar input are described in the blog post, from Spark's own `AutoCdcScd2SinglePipelineSuite`;
they were not reproduced by this pipeline.
