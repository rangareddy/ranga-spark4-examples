-- Spark 4.2 | Comparing two snapshots by hand, the form the CHANGES clause replaces | SPARK-55948
-- Run: ./run.sh 4.2 spark-4.2/17_changes_before_snapshot_diff.sql
-- setup: the table at version 1 and at a later version
CREATE OR REPLACE TEMP VIEW snap_v1 AS SELECT * FROM VALUES (1, 'a'), (2, 'b') AS t(id, data);
CREATE OR REPLACE TEMP VIEW snap_v2 AS SELECT * FROM VALUES (1, 'a'), (3, 'c') AS t(id, data);

SELECT 'insert' AS change, * FROM (SELECT * FROM snap_v2 EXCEPT SELECT * FROM snap_v1)
UNION ALL
SELECT 'delete', * FROM (SELECT * FROM snap_v1 EXCEPT SELECT * FROM snap_v2)
ORDER BY id;
-- delete  2  b
-- insert  3  c
