-- Spark 4.0 | VARIANT type (GA in 4.1) | SPARK-45827
SELECT parse_json('{"a":1,"b":[1,2,3],"c":{"d":"x"}}') AS v;
SELECT variant_get(parse_json('{"a":1,"b":[1,2,3]}'), '$.b[1]', 'int');
SELECT schema_of_variant(parse_json('{"a":1,"b":[1,2,3]}'));
