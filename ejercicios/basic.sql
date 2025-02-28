-- DQL
SELECT * FROM system.functions LIMIT 10;
SELECT DISTINCT name FROM system.functions LIMIT 100;
SELECT name FROM system.functions WHERE name='sum';
SELECT COUNT(name), is_aggregate FROM system.functions WHERE origin='System' GROUP BY is_aggregate;
SELECT COUNT(name), is_aggregate FROM system.functions  WHERE origin='System' GROUP BY is_aggregate ORDER BY is_aggregate DESC;

-- DDL
-- CREATE DATABASE
CREATE DATABASE SQL_EXAMPLES;
SHOW DATABASES;

-- CREATE TABLES
CREATE TABLE SQL_EXAMPLES.table1(
    Column1 String
                                )
ENGINE = Log;

CREATE TABLE SQL_EXAMPLES.table2(
    Column1 String,
    Column2 String
)ENGINE = MergeTree
ORDER BY Column1;

-- RENAME
RENAME TABLE SQL_EXAMPLES.table1 TO SQL_EXAMPLES.table11;
RENAME TABLE SQL_EXAMPLES.table11 TO SQL_EXAMPLES.table1;

-- INSERTS
INSERT INTO SQL_EXAMPLES.table1 VALUES ('a'), ('b');
INSERT INTO SQL_EXAMPLES.table2 VALUES ('a', 'a'), ('b', 'b');

-- SELECT
SELECT * FROM SQL_EXAMPLES.table2;
SELECT * FROM SQL_EXAMPLES.table1;

-- SHOW TABLES
SHOW TABLES FROM SQL_EXAMPLES;

-- TRUNCATE
TRUNCATE TABLE SQL_EXAMPLES.table2;

-- DROP
DROP TABLE SQL_EXAMPLES.table2;

-- DROP DATABASE
DROP DATABASE SQL_EXAMPLES;




--- ALTER COLUMNS and DML
CREATE DATABASE SQL_EXAMPLES;
CREATE TABLE SQL_EXAMPLES.table1(
    Column1 String
)ENGINE = Log;

CREATE TABLE SQL_EXAMPLES.table2(
    Column1 String,
    Column2 String
)ENGINE = MergeTree ORDER BY Column1;
INSERT INTO SQL_EXAMPLES.table1(Column1) VALUES ('a'), ('b');
INSERT INTO SQL_EXAMPLES.table2(Column1, Column2) VALUES ('a', 'b'), ('a', 'b');

SELECT * FROM SQL_EXAMPLES.table2;

-- ALTER
ALTER TABLE SQL_EXAMPLES.table2 UPDATE Column2 = 'apple' WHERE Column2 = 'a';
-- ALTER DELETE
ALTER TABLE SQL_EXAMPLES.table2 DELETE WHERE Column2 = 'apple';
-- LIGHWEIGHT DELETE: solo funciona para ENGINE = MergeTree. Es un borrado logico (la columna se marca a False)
DELETE FROM SQL_EXAMPLES.table2 WHERE Column2 = 'b';
-- ADD COLUMN
ALTER TABLE SQL_EXAMPLES.table2 ADD COLUMN Column3 Nullable(String);
INSERT INTO SQL_EXAMPLES.table2 VALUES ('c', 'c', 'cat');
SELECT * FROM SQL_EXAMPLES.table2;

ALTER TABLE SQL_EXAMPLES.table2 ADD COLUMN Column4 Nullable(String);
ALTER TABLE SQL_EXAMPLES.table2 CLEAR COLUMN Column4;
ALTER TABLE SQL_EXAMPLES.table2 DROP COLUMN Column4;

ALTER TABLE SQL_EXAMPLES.table2 RENAME COLUMN Column3 TO Column4;


ALTER TABLE SQL_EXAMPLES.table2 DROP COLUMN Column4;

select *
from SQL_EXAMPLES.table2;

