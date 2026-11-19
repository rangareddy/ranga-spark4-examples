-- Spark 4.3: read the entries of a tar or zip archive as if they were separate files.
-- Build the archives first, in the directory you run this from:  ./10_make_archives.sh
-- Default is off. Without the flag the tar is parsed as plain CSV text: count(*) returned 4 and no error.
SET spark.sql.files.archive.reader.enabled=true;
CREATE OR REPLACE TEMP VIEW t_tar USING csv OPTIONS (path 'arc/data.tar', header 'true');
SELECT * FROM t_tar ORDER BY id;
CREATE OR REPLACE TEMP VIEW t_zip USING csv OPTIONS (path 'arc/data.zip', header 'true');
SELECT count(*) AS rows_in_zip FROM t_zip;
-- Without a filter every entry is read, so t_tar above returns four rows (notes.txt adds 9,notes).
-- archivePathFilter keeps only the matching entries: notes.txt is skipped and three rows come back.
CREATE OR REPLACE TEMP VIEW only_csv USING csv OPTIONS (path 'arc/data.tar', header 'true', archivePathFilter '*.csv');
SELECT * FROM only_csv ORDER BY id;
