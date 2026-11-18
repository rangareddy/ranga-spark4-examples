-- Top-K similarity search in plain SQL: NEAREST BY (SPARK-56395) driven by vector_cosine_similarity (SPARK-54713).
-- Run for this post on Spark 4.3.0, the release tarball. Both features were introduced in 4.2.0.
CREATE OR REPLACE TEMP VIEW queries AS
SELECT * FROM VALUES ('q1', ARRAY(1.0F, 0.0F)), ('q2', ARRAY(0.0F, 1.0F)) AS queries(q, qe);
CREATE OR REPLACE TEMP VIEW docs AS
SELECT * FROM VALUES ('d1', ARRAY(0.9F, 0.1F)), ('d2', ARRAY(0.1F, 0.9F)), ('d3', ARRAY(0.7F, 0.7F)) AS docs(doc, de);
SELECT q, doc
FROM queries JOIN docs EXACT NEAREST 2 BY SIMILARITY vector_cosine_similarity(qe, de)
ORDER BY q, doc;
