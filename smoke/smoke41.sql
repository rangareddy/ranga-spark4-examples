-- ### setup
CREATE OR REPLACE TEMP VIEW clicks AS SELECT * FROM VALUES ('a'),('b'),('a'),('c'),('a'),('b'),('d') AS t(page)
;;
CREATE OR REPLACE TEMP VIEW ev AS SELECT parse_json(j) v FROM VALUES ('{"user":"a","n":3,"tags":["x","y"]}'),('{"user":"b","n":"x"}') AS t(j)
;;
-- ### SQL scripting
BEGIN
  DECLARE total INT DEFAULT 0;
  DECLARE i INT DEFAULT 1;
  WHILE i <= 5 DO
    SET total = total + i;
    SET i = i + 1;
  END WHILE;
  SELECT total, i;
END
;;
-- ### recursive CTE
WITH RECURSIVE t(n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM t WHERE n < 5) SELECT n FROM t
;;
-- ### VARIANT colon path
SELECT v:user::string AS user, v:tags[0]::string AS first_tag, schema_of_variant(v:n) AS n_type FROM ev ORDER BY 1
;;
-- ### sketch functions
SELECT approx_top_k(page, 2) FROM clicks
