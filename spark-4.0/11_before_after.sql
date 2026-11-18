-- Before and after for four 4.0 features. Run for this post on apache/spark:4.0.5-python3.
CREATE OR REPLACE TEMP VIEW orders AS SELECT * FROM VALUES (1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D) AS t(id,region,amount);

-- Pipe syntax. Before: the conventional query. After: the same query read top to bottom.
SELECT region, sum(amount) AS total FROM orders WHERE amount > 5 GROUP BY region ORDER BY total DESC;
FROM orders |> WHERE amount > 5 |> AGGREGATE sum(amount) AS total GROUP BY region |> ORDER BY total DESC;

-- Collation. Before: lower() on both sides. After: a collation on the comparison.
SELECT lower('Apple') = lower('apple') AS before_lower, 'Apple' COLLATE UTF8_LCASE = 'apple' AS after_collate;

-- VARIANT. Before: get_json_object returns a STRING. After: variant_get returns the type you ask for.
SELECT typeof(get_json_object('{"a":1,"b":[1,2,3]}', '$.b[1]')) AS before_type,
       typeof(variant_get(parse_json('{"a":1,"b":[1,2,3]}'), '$.b[1]', 'int')) AS after_type;

-- ANSI mode. Before 4.0 (ANSI off): a bad cast and a divide by zero return NULL. After: both raise.
SET spark.sql.ansi.enabled=false;
SELECT CAST('abc' AS INT) AS bad_cast, 1/0 AS div_zero;
SET spark.sql.ansi.enabled=true;
