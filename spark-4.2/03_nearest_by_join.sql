-- Spark 4.2 | NEAREST BY top-K ranking join | SPARK-56395
CREATE OR REPLACE TEMP VIEW pts AS SELECT * FROM VALUES ('q1',1.0D),('q2',9.0D) AS t(q,x);
CREATE OR REPLACE TEMP VIEW base AS SELECT * FROM VALUES ('a',0.0D),('b',2.0D),('c',8.0D),('d',20.0D) AS t(name,y);

SELECT q, x, name, y
FROM pts JOIN base EXACT NEAREST 2 BY DISTANCE abs(x - y)
ORDER BY q, abs(x - y);

SELECT q, name FROM pts JOIN base EXACT NEAREST BY DISTANCE abs(x - y) ORDER BY q;
