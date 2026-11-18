-- The CHANGES clause (SPARK-55668) is engine syntax; the catalog must implement change data capture.
-- Run on apache/spark:4.2.1-python3 and on the 4.3.0 tarball, against a built-in Parquet table. Introduced in 4.2.0.
CREATE TABLE ev (id INT, v STRING) USING parquet;
INSERT INTO ev VALUES (1, 'a');
SELECT * FROM ev CHANGES FROM VERSION 1 TO VERSION 2;
