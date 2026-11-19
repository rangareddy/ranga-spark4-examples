-- Spark 4.2 | GEOMETRY and GEOGRAPHY: the BINARY form before 4.2, and Parquet written by path | SPARK-51658
-- Run: ./run.sh 4.2 spark-4.2/13_geospatial_before_and_parquet.sql
-- setup: one point as WKB, x = 1.0 and y = 2.0
CREATE OR REPLACE TEMP VIEW pt AS SELECT X'0101000000000000000000F03F0000000000000040' AS wkb;

SELECT typeof(wkb) FROM pt;   -- binary

INSERT OVERWRITE DIRECTORY '/tmp/geo_pq' USING parquet
SELECT 1 AS id, ST_GeomFromWKB(wkb, 4326) AS g FROM pt;

SELECT id, typeof(g), ST_SRID(g) FROM parquet.`/tmp/geo_pq`;   -- 1  geometry(4326)  4326
