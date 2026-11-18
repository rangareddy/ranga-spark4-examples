-- The CHANGES clause (SPARK-55668) is engine syntax; the catalog must implement change data capture.
-- Run for this post on Spark 4.3.0 against a built-in Parquet table. Introduced in 4.2.0.
CREATE TABLE ev (id INT, v STRING) USING parquet;
INSERT INTO ev VALUES (1, 'a');
SELECT * FROM ev CHANGES FROM VERSION 1 TO VERSION 2;
