-- Spark 4.1 | Recursive common table expressions | SPARK-24497
WITH RECURSIVE t(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM t WHERE n < 5
) SELECT n FROM t;

CREATE OR REPLACE TEMP VIEW emp AS SELECT * FROM VALUES
  ('ceo', CAST(NULL AS STRING)), ('vp', 'ceo'), ('dir', 'vp'), ('mgr', 'dir') AS t(name, boss);
WITH RECURSIVE org(name, lvl) AS (
  SELECT name, 0 FROM emp WHERE boss IS NULL
  UNION ALL
  SELECT e.name, o.lvl + 1 FROM emp e JOIN org o ON e.boss = o.name
) SELECT * FROM org ORDER BY lvl;
