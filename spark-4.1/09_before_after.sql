-- Before and after for VARIANT colon paths. Run for this post on apache/spark:4.1.3-python3.
CREATE OR REPLACE TEMP VIEW ev AS SELECT parse_json(j) v FROM VALUES
  ('{"user":"a","n":3,"tags":["x","y"]}'), ('{"user":"b","n":"x"}') AS t(j);
-- Before (4.0): variant_get with a path and a type. After (4.1): a colon path and a cast.
SELECT variant_get(v, '$.user', 'string') AS user_before, v:user::string AS user_after,
       variant_get(v, '$.tags[0]', 'string') AS tag_before, v:tags[0]::string AS tag_after
FROM ev ORDER BY 1;
