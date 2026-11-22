-- Spark 4.0 | lower() on both sides, the form collation replaces | SPARK-46830
-- Run: ./run.sh 4.0 spark-4.0/19_collation_before.sql
CREATE OR REPLACE TEMP VIEW names AS SELECT * FROM VALUES ('Ana'),('ana'),('ANA'),('Bob') AS t(n);
SELECT lower('Apple') = lower('apple') AS eq;
SELECT count(DISTINCT lower(n)) FROM names;
