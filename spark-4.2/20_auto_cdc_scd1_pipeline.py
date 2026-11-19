# Spark 4.2 | Auto CDC with SCD Type 1 in a Declarative Pipeline | SPARK-56249, SPARK-56651
# A pipeline definition, not a standalone script: put it in transformations/ of a pipeline project and run `spark-pipelines run`.
# The target needs a connector with row-level operations. The expected result comes from AutoCdcScd1SinglePipelineSuite in the Spark source:
# an upsert, a delete and a re-upsert for one key at sequences 1, 2 and 3 end as (id 1, alice2, version 3).
from pyspark import pipelines as dp

dp.create_streaming_table("customers")

dp.create_auto_cdc_flow(
    target="customers",
    source="cdc_events",
    keys=["id"],
    sequence_by="version",
    apply_as_deletes="op = 'DELETE'",
    except_column_list=["op"],
    stored_as_scd_type=1,
)
