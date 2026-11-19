-- Spark 4.2 | The array arithmetic that vector_inner_product and vector_cosine_similarity replace
-- Run: ./run.sh 4.2 spark-4.2/14_vector_functions_before.sql
-- inner product of [1,2] and [3,4]
SELECT aggregate(zip_with(ARRAY(1.0F, 2.0F), ARRAY(3.0F, 4.0F), (x, y) -> x * y),
                 0.0F, (acc, v) -> acc + v) AS dot;                      -- 11.0

-- cosine similarity of [1,0] and [1,1]
WITH t AS (SELECT ARRAY(1.0F, 0.0F) AS a, ARRAY(1.0F, 1.0F) AS b)
SELECT aggregate(zip_with(a, b, (x, y) -> x * y), 0.0F, (acc, v) -> acc + v)
       / (sqrt(aggregate(transform(a, x -> x * x), 0.0F, (acc, v) -> acc + v))
        * sqrt(aggregate(transform(b, x -> x * x), 0.0F, (acc, v) -> acc + v))) AS cosine FROM t;
-- 0.7071067811865475
