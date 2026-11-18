-- ### setup
CREATE OR REPLACE TEMP VIEW orders AS SELECT * FROM VALUES (1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D) AS t(id,region,amount)
;;
-- ### ANSI mode: try_cast tolerates a bad value (a plain CAST would raise CAST_INVALID_INPUT)
SELECT try_cast('abc' AS INT)
;;
-- ### VARIANT
SELECT variant_get(parse_json('{"a":1,"b":[1,2,3]}'), '$.b[1]', 'int')
;;
-- ### pipe syntax
FROM orders |> WHERE amount > 5 |> AGGREGATE sum(amount) AS total GROUP BY region |> ORDER BY total DESC
;;
-- ### SQL user-defined function
CREATE OR REPLACE TEMPORARY FUNCTION add_tax(x DOUBLE) RETURNS DOUBLE RETURN x * 1.18
;;
SELECT id, add_tax(amount) AS gross FROM orders ORDER BY id
;;
-- ### session variable
DECLARE OR REPLACE VARIABLE threshold DOUBLE DEFAULT 15.0
;;
SELECT id FROM orders WHERE amount > threshold ORDER BY id
;;
-- ### string collation
SELECT 'Apple' COLLATE UTF8_LCASE = 'apple'
;;
-- ### XML
SELECT from_xml('<p><name>Ana</name><age>30</age></p>', 'name STRING, age INT')
