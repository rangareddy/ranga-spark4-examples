-- Cursors in SQL scripts (SPARK-54759), introduced in 4.2. Behind two internal flags in 4.3.0.
-- Run on apache/spark:4.2.1-python3 through the Scala API (the 4.2 CLI splits a script on ';'), and on the 4.3.0 tarball. Without the first flag: UNSUPPORTED_FEATURE.SQL_CURSOR.
-- With only the first flag: UNSUPPORTED_FEATURE.CONTINUE_EXCEPTION_HANDLER.
SET spark.sql.scripting.cursorEnabled=true;
SET spark.sql.scripting.continueHandlerEnabled=true;
BEGIN
  DECLARE total INT DEFAULT 0;
  DECLARE v INT;
  DECLARE done BOOLEAN DEFAULT false;
  DECLARE c CURSOR FOR SELECT col1 FROM VALUES (10), (20), (30);
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = true;
  OPEN c;
  FETCH c INTO v;
  WHILE NOT done DO
    SET total = total + v;
    FETCH c INTO v;
  END WHILE;
  CLOSE c;
  SELECT total AS cursor_total;
END;
