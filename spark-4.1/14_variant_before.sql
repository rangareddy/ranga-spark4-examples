-- Spark 4.1 | variant_get with a path and a type, the form colon paths replace | SPARK-52494
-- Run: ./run.sh 4.1 spark-4.1/14_variant_before.sql
CREATE OR REPLACE TEMP VIEW ev AS SELECT parse_json(j) v FROM VALUES
  ('{"user":"a","n":3,"tags":["x","y"]}'), ('{"user":"b","n":"x"}') AS t(j);

SELECT variant_get(v, '$.user', 'string') AS user,
       variant_get(v, '$.tags[0]', 'string') AS first_tag
FROM ev ORDER BY 1;
