-- Before and after for QUALIFY, NEAREST BY and time_bucket. Run for this post on apache/spark:4.2.1-python3.
CREATE OR REPLACE TEMP VIEW orders_t AS SELECT * FROM VALUES
  (1,'eu',10.0D),(2,'us',20.0D),(3,'eu',30.0D),(4,'us',5.0D),(5,'eu',30.0D) AS t(id,region,amount);
-- QUALIFY. Before: a subquery around the window. After: QUALIFY.
SELECT id, region, amount FROM (
  SELECT id, region, amount, row_number() OVER (PARTITION BY region ORDER BY amount DESC, id) AS rn FROM orders_t
) WHERE rn = 1 ORDER BY region;
SELECT id, region, amount FROM orders_t
QUALIFY row_number() OVER (PARTITION BY region ORDER BY amount DESC, id) = 1 ORDER BY region;

CREATE OR REPLACE TEMP VIEW pts AS SELECT * FROM VALUES ('q1',1.0D),('q2',9.0D) AS t(q,x);
CREATE OR REPLACE TEMP VIEW base AS SELECT * FROM VALUES ('a',0.0D),('b',2.0D),('c',8.0D),('d',20.0D) AS t(name,y);
-- NEAREST BY. Before: a cross join, a window to rank, and a filter. After: one join clause.
SELECT q, x, name, y FROM (
  SELECT q, x, name, y, row_number() OVER (PARTITION BY q ORDER BY abs(x - y)) AS rn FROM pts CROSS JOIN base
) WHERE rn <= 2 ORDER BY q, abs(x - y);
SELECT q, x, name, y FROM pts JOIN base EXACT NEAREST 2 BY DISTANCE abs(x - y) ORDER BY q, abs(x - y);

-- time_bucket. Before: date_trunc, which only covers calendar units. After: any fixed width.
SELECT date_trunc('HOUR', TIMESTAMP_NTZ '2026-11-01 10:40:00') AS before_hour,
       time_bucket(INTERVAL '15' MINUTE, TIMESTAMP_NTZ '2026-11-01 10:40:00') AS after_15_minutes;
