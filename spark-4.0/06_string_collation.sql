-- Spark 4.0 | String collation | SPARK-46830
SELECT 'Apple' = 'apple';
SELECT 'Apple' COLLATE UTF8_LCASE = 'apple';
SELECT collation('x' COLLATE UNICODE_CI);

CREATE OR REPLACE TEMP VIEW names AS SELECT * FROM VALUES ('Ana'),('ana'),('ANA'),('Bob') AS t(n);
SELECT count(DISTINCT n COLLATE UTF8_LCASE) FROM names;
