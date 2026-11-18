-- The smallest check that you are on the release you think you are on.
-- Run it first. An older SPARK_HOME in the shell can silently run the wrong Spark: start with `env -u SPARK_HOME`.
SELECT version();
