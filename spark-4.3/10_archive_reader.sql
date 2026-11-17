-- Spark 4.3: read the entries of a tar or zip archive as if they were separate files.
-- Build the archives first:  printf 'id,name\n1,ana\n2,bob\n' > a.csv; printf 'id,name\n3,cy\n' > b.csv
--                            tar -cf data.tar a.csv b.csv; zip -q data.zip a.csv b.csv
-- Default is off. Without the flag the tar is parsed as plain CSV text: count(*) returned 4 and no error.
SET spark.sql.files.archive.reader.enabled=true;
CREATE OR REPLACE TEMP VIEW t_tar USING csv OPTIONS (path 'arc/data.tar', header 'true');
SELECT * FROM t_tar ORDER BY id;
CREATE OR REPLACE TEMP VIEW t_zip USING csv OPTIONS (path 'arc/data.zip', header 'true');
SELECT count(*) AS rows_in_zip FROM t_zip;
