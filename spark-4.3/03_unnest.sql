-- Spark 4.3 | UNNEST in FROM | SPARK-58419
SELECT * FROM UNNEST(array('a','b')) WITH ORDINALITY AS t(value, pos);
SELECT * FROM UNNEST(array(1,2), array(10,20,30)) AS t(a, b);
SELECT id, elem
FROM VALUES (1, array(10,20)), (2, array(30)) AS data(id, arr),
     LATERAL UNNEST(arr) AS t(elem);
