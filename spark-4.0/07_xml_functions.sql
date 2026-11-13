-- Spark 4.0 | Built-in XML functions (the xml data source is in the PySpark example) | SPARK-44265
SELECT from_xml('<p><name>Ana</name><age>30</age></p>', 'name STRING, age INT');
SELECT schema_of_xml('<p><name>Ana</name><age>30</age></p>');
