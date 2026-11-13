-- Spark 4.1 | VARIANT GA with colon paths | SPARK-54454, SPARK-52494
CREATE OR REPLACE TEMP VIEW ev AS SELECT parse_json(j) v FROM VALUES
  ('{"user":"a","n":3,"tags":["x","y"]}'), ('{"user":"b","n":"x"}') AS t(j);
SELECT v:user::string AS user,
       v:tags[0]::string AS first_tag,
       schema_of_variant(v:n) AS n_type
FROM ev ORDER BY 1;
