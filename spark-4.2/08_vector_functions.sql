-- Vector similarity and distance functions (SPARK-54713, SPARK-55030, SPARK-55031), introduced in 4.2.
-- Run on apache/spark:4.2.1-python3, and also on the 4.3.0 release tarball. Arguments are ARRAY<FLOAT>; the norm degree must be FLOAT too.
SELECT vector_cosine_similarity(ARRAY(1.0F, 0.0F), ARRAY(1.0F, 1.0F)) AS cosine,
       vector_l2_distance(ARRAY(1.0F, 2.0F), ARRAY(4.0F, 6.0F))        AS l2,
       vector_inner_product(ARRAY(1.0F, 2.0F), ARRAY(3.0F, 4.0F))      AS dot,
       vector_norm(ARRAY(3.0F, 4.0F), 2.0F)                            AS norm;
SELECT vector_avg(v) AS avg_vec
FROM VALUES (ARRAY(1.0F, 2.0F)), (ARRAY(3.0F, 4.0F)) AS t(v);
