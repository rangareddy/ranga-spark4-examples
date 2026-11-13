-- Spark 4.3 | VARIANT editing functions | SPARK-57804
SELECT variant_set(parse_json('{"a":1,"tags":["x"]}'), '$.b', 3);
SELECT variant_insert(parse_json('["a","b","c"]'), '$[1]', 'z');
SELECT variant_delete(parse_json('{"a":1,"b":2,"items":[1,2,3]}'), '$.a', '$.items[0]');
SELECT variant_array_append(parse_json('{"a":[1,2]}'), '$.a', 3);
SELECT variant_strip_nulls(parse_json('{"a":1,"b":null,"c":[1,null]}'));
