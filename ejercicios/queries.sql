select *
FROM file('/var/lib/clickhouse/user_files/data/binance_btc_usd.csv',
          'CSV', 'open Float64, high Float64, low Float64, close Float64, volume Float64, timestamp DateTime64(3, \'UTC\')' );

-- SQL Functions

CREATE TABLE DDL.table3
(Column1 String,
Column2 FixedString(3))
ENGINE = Log;

INSERT INTO DDL.table3 VALUES ('a', 'ab'), ('b', 'bc');

SELECT toDate('1965-01-01');
SELECT toDate32('1865-01-01');

CREATE TABLE DDL.dt
(
    date_time1 DateTime('Europe/Brussels'),
    date_time2 DateTime64(2, 'Europe/Brussels')
)
ENGINE = Log;

INSERT  INTO DDL.dt VALUES (('1999-12-31 23:30:00'), ('1999-12-31 23:30:00.123456'));
INSERT  INTO DDL.dt VALUES (('1899-12-31 23:30:00'), ('1899-12-31 23:30:00.0'));

SELECT array('a', 'b', Null) AS arr;

SELECT ['a', 'b', Null] AS arr;

SELECT [1,2,3,4.0, Null] AS ARR

SELECT [toDate(1000), toDateTime64(1000, 1)] AS arr;

SELECT [toDate(1000), toDateTime64(1000, 1), 1] AS arr;

SELECT [toDate(1000), toDateTime64(1000, 1), 'a'] AS arr;

SELECT [1, 'a'] AS ARR;

SELECT tuple(toDate(1000), toDateTime64(1000, 1), 'a') AS tup;

-- Nested

CREATE TABLE nested_example
(ID UInt32,
 Code Nested
 (code_id String,
 total_count UInt32
 )
)
Engine=Log;

INSERT INTO nested_example VALUES (1, ['a', 'b', 'c'], [1,2,3]);

SELECT Code.code_id , Code.total_count  FROM nested_example;


INSERT INTO DDL.nested_example VALUES (1, ['a', 'b', 'c'], [1,2]);

--

CREATE TABLE employee
(name String,
city  Nullable(String)
)
Engine = MergeTree
ORDER BY name;

CREATE TABLE salary
(salary Nullable(UInt32),
month  Nullable(String),
name String
)
Engine = MergeTree
ORDER BY name;


INSERT INTO DDL.employee VALUES ('a', 'city1'), ('b', Null), ('c', 'city3');

INSERT INTO DDL.salary VALUES (1200, 'Nov', 'a'), (1000, 'Jan', 'b'), (800, Null, 'd') ;

SELECT employee.name, employee.city,
salary.salary, salary.month, salary.name
FROM DDL.employee AS employee
INNER JOIN salary AS salary
ON employee.name = salary.name;


SELECT <columns/expressions_list>
FROM <LEFT TABLE>
<JOIN TYPE> <RIGHT TABLE>
ON <expression_list>

SELECT * FROM DDL.salary ;

DROP TABLE  DDL.employee;
DROP TABLE DDL.salary ;

-- Enum

CREATE TABLE enum_example
(column1 Enum('a'=1, 'b'=2))
Engine = Log;

INSERT INTO enum_example
VALUES (1), (2), ('a'), ('b');

SELECT * FROM enum_example ;

INSERT INTO enum_example
VALUES (3);

DROP TABLE DDL.enum_example ;

-- LC

CREATE TABLE low_cardinality
(column1 LowCardinality(String))
Engine = Log;

DROP TABLE DDL.low_cardinality ;

-- Union

SELECT DISTINCT name FROM
(SELECT name From DDL.employee
UNION ALL
SELECT name FROM DDL.salary);

SELECT 1+2;
SELECT plus(1,2);

SELECt 1 != 2;
SELECT notEquals(1,2);

SELECT NOT 1;
SELECT not(1);

SELECT 1 AND 0;
SELECT and(1,0);

SHOW TABLES FROM DDL;

SELECT * FROM DDL.salary;

*/