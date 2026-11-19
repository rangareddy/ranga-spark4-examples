-- The target table's connector must support row-level operations (MERGE).
CREATE STREAMING TABLE customers_history
FLOW AUTO CDC
FROM STREAM(cdc_events)
KEYS (id)
APPLY AS DELETE WHEN op = 'DELETE'
SEQUENCE BY version
COLUMNS * EXCEPT (op)
STORED AS SCD TYPE 2;
-- To also keep history only for one column, end the statement with:
--   STORED AS SCD TYPE 2
--   TRACK HISTORY ON (city);
