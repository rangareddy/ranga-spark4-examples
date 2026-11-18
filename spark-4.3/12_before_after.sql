-- Before and after for two 4.3 features. The "before" forms work on every Spark 4.x release.
-- Run for this post on Spark 4.3.0, the release tarball.

-- JSON to rows. Before: from_json with a schema, then explode.
SELECT j.id, j.n FROM (
  SELECT explode(from_json('{"items":[{"id":1,"n":"a"},{"id":2,"n":"b"}]}',
                           'items ARRAY<STRUCT<id: INT, n: STRING>>').items) AS j);

-- JSON to rows. After: JSON_TABLE, with an ordinality column that the before form has no direct equivalent for.
SELECT t.* FROM JSON_TABLE(
  '{"items":[{"id":1,"n":"a"},{"id":2,"n":"b"}]}', '$.items[*]'
  COLUMNS (seq FOR ORDINALITY, id INT PATH '$.id', name STRING PATH '$.n')) AS t;

-- Array to rows with a position. Before: LATERAL VIEW posexplode. Positions start at 0.
SELECT pos, value FROM (SELECT 1) LATERAL VIEW posexplode(array('a','b')) t AS pos, value;

-- Array to rows with a position. After: UNNEST ... WITH ORDINALITY. Positions start at 1.
SELECT * FROM UNNEST(array('a','b')) WITH ORDINALITY AS t(value, pos);
