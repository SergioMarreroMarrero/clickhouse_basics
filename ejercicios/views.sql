-- NORMAL VIEW
CREATE VIEW SQL_EXAMPLES.salary_view AS
    SELECT salary*2 as double_salary,
           name
    FROM SQL_EXAMPLES.salary;

SELECT * FROM SQL_EXAMPLES.salary_view;

-- PARAMETRIZED VIEW
CREATE VIEW SQL_EXAMPLES.parametrised_view AS
    select *
    from SQL_EXAMPLES.table2
    where Column1 = {Column1:String};

select * from SQL_EXAMPLES.parametrised_view(Column1='a')


-- MATERIALIZED VIEW
CREATE MATERIALIZED VIEW SQL_EXAMPLES.salary_materialized_view
    ENGINE = MergeTree()
    ORDER BY (name) AS
SELECT salary*2 as double_salary, name
FROM SQL_EXAMPLES.salary;

-- NO HAY NADA.
SELECT *
FROM SQL_EXAMPLES.salary_materialized_view;

-- Las materialized VIEWS SOLO se suscriben a los nuevos datos, y no a los antiguos.
-- Una vez los insertemos....entonces si que los veremos
INSERT INTO SQL_EXAMPLES.salary VALUES (777, 'Nov', 'z');

SELECT *
FROM SQL_EXAMPLES.salary_materialized_view;

OPTIMIZE  TABLE SQL_EXAMPLES.salary FINAL;

-- Sin embargo, las mutaciones de la tabla original...las ignora (UPDATE DELETE) el DELETE no estoy seguro
ALTER TABLE SQL_EXAMPLES.salary
UPDATE salary=222
WHERE name='a';

SELECT *
FROM SQL_EXAMPLES.salary_materialized_view;