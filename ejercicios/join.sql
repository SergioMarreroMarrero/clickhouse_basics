
CREATE TABLE SQL_EXAMPLES.employee(
    name String,
    city  Nullable(String)
)
Engine = MergeTree
ORDER BY name;

CREATE TABLE SQL_EXAMPLES.salary(
    salary Nullable(UInt32),
    month  Nullable(String),
    name    String
)
Engine = MergeTree
ORDER BY name;


INSERT INTO SQL_EXAMPLES.employee VALUES ('a', 'city1'), ('b', Null), ('c', 'city3');
INSERT INTO SQL_EXAMPLES.salary VALUES (1200, 'Nov', 'a'), (1000, 'Jan', 'b'), (800, Null, 'd') ;



SELECT employee.name, employee.city,
       salary.salary, salary.month, salary.name
FROM SQL_EXAMPLES.employee AS employee
INNER JOIN SQL_EXAMPLES.salary AS salary
ON employee.name = salary.name;


SELECT employee.name
FROM SQL_EXAMPLES.employee
UNION ALL
SELECT salary.name
FROM SQL_EXAMPLES.salary