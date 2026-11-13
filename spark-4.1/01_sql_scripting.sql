-- Spark 4.1 | SQL scripting, on by default | SPARK-54499
CREATE OR REPLACE TEMP VIEW orders AS SELECT * FROM VALUES (1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D) AS t(id,region,amount);

BEGIN
  DECLARE total INT DEFAULT 0;
  DECLARE i INT DEFAULT 1;
  WHILE i <= 5 DO
    SET total = total + i;
    SET i = i + 1;
  END WHILE;
  SELECT total, i;
END;

BEGIN
  DECLARE result DOUBLE DEFAULT 0;
  DECLARE EXIT HANDLER FOR DIVIDE_BY_ZERO
  BEGIN
    SET result = -1;
    SELECT 'caught divide by zero' AS status, result;
  END;
  SET result = 1 / 0;
  SELECT 'not reached' AS status, result;
END;

BEGIN
  DECLARE msg STRING DEFAULT '';
  FOR r AS SELECT region, sum(amount) AS total FROM orders GROUP BY region ORDER BY region DO
    SET msg = msg || r.region || '=' || CAST(r.total AS STRING) || ' ';
  END FOR;
  SELECT trim(msg) AS summary;
END;
