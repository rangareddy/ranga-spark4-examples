-- Spark 4.0 | xpath_* one value at a time, the form from_xml replaces | SPARK-44265
-- Run: ./run.sh 4.0 spark-4.0/20_xml_before.sql
SELECT xpath_string('<p><name>Ana</name><age>30</age></p>', 'p/name') AS name,
       xpath_int('<p><name>Ana</name><age>30</age></p>', 'p/age') AS age;
