# ranga-spark4-examples

Runnable examples for every feature covered in the blog post
[Spark 4 in four releases](https://rangareddy.github.io/) (find it under Spark). One file per feature,
grouped by the release that introduced it: `spark-4.0/`, `spark-4.1/`, `spark-4.2/`, `spark-4.3/`.
`outputs/` holds what each example printed when it was run.

## Run an example

You need Docker. From the repo root:

```bash
./run.sh 4.2 spark-4.2/02_qualify.sql                     # a SQL file
./run.sh 4.1 spark-4.1/05_parameter_markers.py            # a PySpark file
./run.sh 4.1 spark-4.1/06_arrow_udf.py --pip "pyarrow pandas"   # installs the packages first
./run_pipeline.sh 4.2                                      # the declarative pipeline project
```

| Release | Image used by `run.sh` |
|:--|:--|
| 4.0 | `apache/spark:4.0.5-python3` |
| 4.1 | `rangareddy1988/ranga-spark4:latest` (Spark 4.1.3) |
| 4.2 | `apache/spark:4.2.1-python3` |
| 4.3 | `apache/spark:4.3.0-python3` |

Override the image with `SPARK_IMAGE=<image>`. SQL files run through `tools/run_sql.py`, which runs one
statement at a time and prints errors instead of stopping, so a file can show a failing statement on purpose
(the ANSI and `ASOF JOIN` examples do).

## Examples

| Release | File | Feature | Status |
|:--|:--|:--|:--|
| 4.0 | `00_hello_world.sql` | `SELECT version()`, the smallest check that you are on 4.0 | ran on 4.0.5 |
| 4.0 | `01_ansi_mode.sql` | ANSI mode by default | ran on 4.0.5 |
| 4.0 | `02_variant.sql` | `VARIANT` | ran on 4.0.5 |
| 4.0 | `03_pipe_syntax.sql` | SQL pipe syntax | ran on 4.0.5 |
| 4.0 | `04_sql_udf.sql` | SQL user-defined functions | ran on 4.0.5 |
| 4.0 | `05_session_variables.sql` | Session variables | ran on 4.0.5 |
| 4.0 | `06_string_collation.sql` | String collation | ran on 4.0.5 |
| 4.0 | `07_xml_functions.sql` | XML functions | ran on 4.0.5 |
| 4.0 | `08_execute_immediate.sql` | `EXECUTE IMMEDIATE` | ran on 4.0.5 |
| 4.0 | `09_python_data_source.py` | Python data source and UDTF | ran on 4.0.5 with `pyarrow pandas` |
| 4.0 | `10_group_by_map_describe_json.sql` | `GROUP BY` on maps, `DESCRIBE ... AS JSON` | ran on 4.0.5 and on 4.3.0 |
| 4.0 | `11_before_after.sql` | Pipe syntax, collation, `VARIANT` and ANSI mode next to their older forms | ran on 4.0.5 |
| 4.1 | `00_hello_world.sql` | `SELECT version()`, the smallest check that you are on 4.1 | ran on 4.1.3 |
| 4.1 | `01_sql_scripting.sql` | SQL scripting | ran on 4.1.3 |
| 4.1 | `02_recursive_cte.sql` | Recursive CTEs | ran on 4.1.3 |
| 4.1 | `03_variant_colon_paths.sql` | `VARIANT` colon paths | ran on 4.1.3 |
| 4.1 | `04_sketch_functions.sql` | Sketch functions | ran on 4.1.3 |
| 4.1 | `05_parameter_markers.py` | Parameter markers | ran on 4.1.3 |
| 4.1 | `06_arrow_udf.py` | Arrow-native UDFs | ran on 4.1.3 with `pyarrow pandas` |
| 4.1 | `07_declarative_pipelines/` | Declarative Pipelines | ran on 4.2.1 (`outputs/07_declarative_pipelines.4.2.txt`); the 4.1 image is not run here |
| 4.1 | `08_real_time_mode.scala` | Real-time mode, stateless | needs Kafka, not run by this repo |
| 4.1 | `09_before_after.sql` | `variant_get` next to the colon path | ran on 4.1.3 |
| 4.2 | `00_hello_world.sql` | `SELECT version()`, the smallest check that you are on 4.2 | ran on 4.2.1 |
| 4.2 | `01_geospatial_types.sql` | `GEOMETRY` and `GEOGRAPHY` | ran on 4.2.1 |
| 4.2 | `02_qualify.sql` | `QUALIFY` | ran on 4.2.1 |
| 4.2 | `03_nearest_by_join.sql` | `NEAREST BY` join | ran on 4.2.1 |
| 4.2 | `04_set_path.sql` | `SET PATH` | ran on 4.2.1 |
| 4.2 | `05_metric_views.sql` | Metric views | ran on 4.2.1 |
| 4.2 | `06_time_bucket_ignore_nulls.sql` | `time_bucket`, `IGNORE NULLS` | ran on 4.2.1 |
| 4.2 | `07_topk_max_by.sql` | Top-K `max_by`, `min_by` | ran on 4.2.1 |
| 4.2 | `08_vector_functions.sql` | Vector similarity and distance functions | ran on 4.2.1 and on 4.3.0 |
| 4.2 | `09_sql_cursors.sql` | Cursors in SQL scripts | ran on 4.2.1 (Scala API) and on 4.3.0, with two internal flags set |
| 4.2 | `10_changes_clause.sql` | The `CHANGES` clause on a built-in table | ran on 4.2.1 and on 4.3.0; fails with `UNSUPPORTED_FEATURE.CHANGE_DATA_CAPTURE` by design |
| 4.2 | `11_vector_similarity_join.sql` | `NEAREST BY` with `vector_cosine_similarity` | ran on 4.2.1 and on 4.3.0 |
| 4.2 | `12_before_after.sql` | `QUALIFY`, `NEAREST BY` and `time_bucket` next to their older forms | ran on 4.2.1 |
| 4.3 | `00_hello_world.sql` | `SELECT version()`, the smallest check that you are on 4.3 | ran on 4.3.0 (release tarball) |
| 4.3 | `01_json_table.sql` | `JSON_TABLE` | ran on 4.3.0 |
| 4.3 | `02_asof_join.sql` | `ASOF JOIN` | ran on 4.3.0 |
| 4.3 | `03_unnest.sql` | `UNNEST` in `FROM` | ran on 4.3.0 |
| 4.3 | `04_variant_editing.sql` | `VARIANT` editing functions | ran on 4.3.0 |
| 4.3 | `05_time_and_nanosecond_types.sql` | `TIME(p)`, nanosecond timestamps | ran on 4.3.0 |
| 4.3 | `06_new_functions.sql` | `counter_diff` and others | ran on 4.3.0 |
| 4.3 | `07_stateful_real_time_mode.scala` | Stateful real-time mode | needs Kafka, not run by this repo |
| 4.3 | `08_auto_cdc_scd2.sql` | Auto CDC SCD Type 2 | pipeline SQL; needs a connector with row-level `MERGE`, not run |
| 4.3 | `09_bin_by.sql` | `BIN BY` | ran on 4.3.0 (release tarball) |
| 4.3 | `10_archive_reader.sql` | Reading tar and zip archives | ran on 4.3.0 (release tarball); build `arc/data.tar` and `arc/data.zip` first, see the file header |
| 4.3 | `11_dataframe_zip.scala` | `DataFrame.zip` | ran on 4.3.0 (release tarball) with `spark-shell -i` |
| 4.3 | `12_before_after.sql` | the older forms of `JSON_TABLE`, `UNNEST`, `ASOF JOIN`, `VARIANT` editing, `BIN BY` and the timestamp cast | ran on 4.3.0 (release tarball) |
| 4.3 | `14_before_dataframe_zip.scala` | the window-and-join form that `DataFrame.zip` replaces | ran on 4.3.0 (release tarball) |

Apache Spark, Apache Kafka, Apache Iceberg and Apache are trademarks of The Apache Software Foundation.

## Running on release tarballs

To run the examples on the plain Apache release tarballs instead of Docker, with the download and checksum script, the SQL runner, one smoke test per release, the PySpark scripts and the Kafka real-time scripts, see [RUNNING_ON_TARBALLS.md](RUNNING_ON_TARBALLS.md).
