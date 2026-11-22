-- Spark 4.0 | get_json_object returns a STRING, variant_get returns the type you ask for | SPARK-45827
-- Run: ./run.sh 4.0 spark-4.0/15_variant_before.sql
SELECT typeof(get_json_object('{"a":1,"b":[1,2,3]}', '$.b[1]')) AS before_type,
       typeof(variant_get(parse_json('{"a":1,"b":[1,2,3]}'), '$.b[1]', 'int')) AS after_type;
