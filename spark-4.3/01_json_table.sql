-- Spark 4.3 | JSON_TABLE | SPARK-58366
SELECT t.* FROM JSON_TABLE(
  '{"items":[{"id":1,"n":"a"},{"id":2,"n":"b"}]}',
  '$.items[*]'
  COLUMNS (
    seq  FOR ORDINALITY,
    id   INT    PATH '$.id',
    name STRING PATH '$.n'
  )
) AS t;

SELECT * FROM JSON_TABLE(
  '{"rows":[{"id":10,"opt":1},{"id":20}]}',
  '$.rows[*]'
  COLUMNS (id INT, hasOpt BOOLEAN EXISTS PATH '$.opt')
) AS t;
