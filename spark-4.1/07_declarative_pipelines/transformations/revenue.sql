CREATE MATERIALIZED VIEW revenue_by_region AS
SELECT region, sum(amount) AS total, count(*) AS orders
FROM orders
GROUP BY region;
