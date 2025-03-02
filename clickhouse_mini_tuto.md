# Configuracion clickhouse con docker

Para habilitarle opciones de red tenemos que iniciar el usuario con contraseña. Tambien es conveniente definir explicitamente
los puertos. Tambien hubo algun problema con el firewall y hubo que habilitar manualmente el puerto.

```bash
docker run -d -p 8123:8123 -p 9000:9000 -e CLICKHOUSE_PASSWORD=clickhouse --ulimit nofile=262144:262144 --name clickhouse clickhouse/clickhouse-server:latest
docker container ls -- lsitamos containers
docker ps -a -- lsitamos containers
docker exec -it 0e0 /bin/bash -- con esto entramos dentro del servidor
clickhouse-client
```

Para apagar el docker y encender:

```bash
docker stop clickhouse
docker restart clickhouse
```


Si quisiera que el contenedor se iniciara con el equipo:

```bash
docker run -d --restart always -p 8123:8123 -p 9000:9000 \
  -e CLICKHOUSE_PASSWORD=clickhouse \
  --name clickhouse clickhouse/clickhouse-server:latest
```
o

```bash
docker update --restart always clickhouse
```

Para eliminarlo. En este caso si no se crearon volumenes persistentes los datos se borraran.

```bash
docker rm -f clickhouse
```

Hemos creado el siguiente Makefile para ir guardando las operaciones. Para descargar Makefile:

```shell
winget install GnuWin32.Make
```

```Makefile
CONTAINER_NAME=clickhouse
LOCAL_VOLUME_PATH=C:\Users\oigre\Documents\repos\clickhouse_basics\data
IMAGE_VOLUME_PATH=/var/lib/clickhouse/user_files/data
IMAGE_NAME=clickhouse/clickhouse-server:latest

run:
	docker run -d -p 8123:8123 -p 9000:9000 \
	  -e CLICKHOUSE_PASSWORD=clickhouse \
	  --name $(CONTAINER_NAME) \
	  -v $(LOCAL_VOLUME_PATH):$(IMAGE_VOLUME_PATH) \
	  $(IMAGE_NAME)

stop:
	docker stop $(CONTAINER_NAME)

restart:
	docker restart $(CONTAINER_NAME)

remove:
	docker rm -f $(CONTAINER_NAME)

list_files:
	docker exec -it $(CONTAINER_NAME) ls $(IMAGE_VOLUME_PATH)
```


# DDL
```sql
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
```


# 📌 ClickHouse: VIEWS, PARAMETERIZED VIEWS y MATERIALIZED VIEWS

## 🛠 VIEWS
Las **vistas normales (`VIEW`)** son alias de consultas SQL que **no almacenan datos** y se ejecutan en tiempo real cuando se consultan.

### ✅ Características:
- No almacenan datos, solo definen una consulta reutilizable.
- Se ejecutan en tiempo real.
- Sirven para simplificar consultas complejas.

### 📌 Ejemplo:
```sql
CREATE VIEW trade_summary AS
SELECT symbol, AVG(price) AS avg_price, SUM(volume) AS total_volume
FROM trades
GROUP BY symbol;
```

> 📢 **Limitación:** La consulta se ejecuta cada vez que se accede a la vista, sin optimización de rendimiento.

---

## 🔄 PARAMETERIZED VIEWS
Las **vistas parametrizadas (`PARAMETERIZED VIEW`)** permiten definir consultas reutilizables con parámetros dinámicos.

### ✅ Características:
- Permiten el uso de parámetros en consultas.
- Reducen la necesidad de crear varias vistas con filtros distintos.

### 📌 Ejemplo:
```sql
CREATE PARAMETERIZED VIEW trade_filter(symbol String) AS
SELECT * FROM trades WHERE trades.symbol = {symbol};
```

### 🔍 Uso:
```sql
SELECT * FROM trade_filter('BTC/USD');
```

> 💚 **Ventaja:** Permite consultas flexibles sin reescribir SQL múltiples veces.

---

## 🛠 MATERIALIZED VIEWS
Las **vistas materializadas (`MATERIALIZED VIEW`)** almacenan los resultados de la consulta en una nueva tabla, mejorando la eficiencia.

### ✅ Características:
- Guardan los resultados en disco para mejorar el rendimiento.
- Se actualizan automáticamente con nuevas inserciones.
- Ideales para precomputar agregaciones y cálculos frecuentes.
- **No capturan datos históricos automáticamente**, solo los nuevos datos insertados.

### 📌 Ejemplo:
```sql
CREATE MATERIALIZED VIEW trade_agg
ENGINE = MergeTree()
ORDER BY symbol
AS
SELECT symbol, AVG(price) AS avg_price, SUM(volume) AS total_volume
FROM trades
GROUP BY symbol;
```

> 📢 **Limitación:** Se debe gestionar la actualización de los datos. Los datos anteriores a la creación de la vista no se incluyen automáticamente.

---

## 🛠 Por qué las `MATERIALIZED VIEW` no capturan datos históricos

Las vistas materializadas en ClickHouse **están diseñadas para procesamiento en tiempo real** y solo registran nuevas inserciones, en lugar de almacenar datos pasados. Esto se debe a la arquitectura OLAP de ClickHouse, optimizada para alta velocidad en consultas masivas.

### 🔎 Razones:
1. **Funcionan como flujos de datos (`event-driven`)** y no como snapshots.
2. **ClickHouse no mantiene un registro de cambios pasados**, por lo que las vistas materializadas no pueden rellenarse automáticamente con datos históricos.
3. **No existe un `REFRESH MATERIALIZED VIEW`**, como en bases OLTP.
4. **Se pueden poblar manualmente** después de la creación con:
   ```sql
   INSERT INTO trade_agg SELECT symbol, AVG(price), SUM(volume) FROM trades GROUP BY symbol;
   ```
5. **Para persistencia total**, es mejor usar `TO` para vincular la vista a una tabla:
   ```sql
   CREATE TABLE trade_agg_data ENGINE = MergeTree() ORDER BY symbol AS SELECT * FROM trades;
   CREATE MATERIALIZED VIEW trade_agg TO trade_agg_data AS SELECT * FROM trades;
   ```

> 💡 **Si necesitas datos históricos y en tiempo real, lo ideal es combinar una `TABLE` con una `MATERIALIZED VIEW`.**

---

## 🎯 Comparación Rápida

| Tipo de Vista | Almacena Datos | Se Actualiza Automáticamente | Captura Datos Históricos | Ideal Para |
|--------------|--------------|-------------------------|-------------------|------------|
| `VIEW` | ❌ No | ✅ Siempre ejecuta la consulta | ❌ No | Consultas reutilizables |
| `PARAMETERIZED VIEW` | ❌ No | ✅ Ejecuta con parámetros | ❌ No | Consultas dinámicas con filtros variables |
| `MATERIALIZED VIEW` | ✅ Sí | ✅ Se actualiza con nuevas inserciones | ❌ No (solo nuevos datos) | Agregaciones y cálculos frecuentes |

---

## 💪 **Conclusión**
- **Usa `VIEW`** para simplificar consultas sin almacenar datos.
- **Usa `PARAMETERIZED VIEW`** para consultas reutilizables con filtros dinámicos.
- **Usa `MATERIALIZED VIEW`** para mejorar el rendimiento precomputando resultados, pero recuerda que solo almacena datos nuevos.

🚀 **¿Cuál de estas vistas se adapta mejor a tu proyecto?**

Ejercicio vistas
```sql
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

```


## JOIN

```sql

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
```


# 📌 ClickHouse: LIGHTWEIGHT DELETE y Mutaciones

## 🛠 LIGHTWEIGHT DELETE

ClickHouse no fue diseñado para operaciones transaccionales (`DELETE`, `UPDATE`), pero recientemente introdujo `LIGHTWEIGHT DELETE` para eliminar registros de forma más eficiente.

### ✅ Características:

- No reescribe los datos inmediatamente, sino que los **marca como eliminados**.
- Permite **consultas sin bloquear la tabla**.
- Los registros eliminados **siguen ocupando espacio hasta la siguiente compactación** (`OPTIMIZE FINAL`).
- No es recomendable para **eliminaciones masivas frecuentes**.

### 📌 Ejemplo:

```sql
DELETE FROM trades WHERE symbol = 'BTC/USD';
```

> 📢 **Alternativas:** Usar particionamiento (`DROP PARTITION`), TTL (`MODIFY TTL`), o marcar registros como eliminados (`is_deleted = 1`).

---

## 🔄 Mutaciones en ClickHouse (`ALTER TABLE ... DELETE | UPDATE`)

ClickHouse usa **mutaciones** porque su motor `MergeTree` está diseñado para **OLAP (analítica de grandes volúmenes de datos)** y no para transacciones tradicionales.

### 🔎 ¿Por qué existe el concepto de mutación?

1. **OLAP ≠ OLTP**: ClickHouse está optimizado para **lecturas y escrituras masivas**, no para modificar registros individuales.
2. **Estructura inmutable (**``**)**: No permite cambios directos en los datos, sino que reescribe archivos enteros en segundo plano.
3. **Evita bloqueos**: A diferencia de las bases de datos transaccionales, las mutaciones se aplican de forma **asíncrona** para no afectar las consultas.

### 📌 Ejemplo de `DELETE` con mutación:

```sql
ALTER TABLE trades DELETE WHERE symbol = 'BTC/USD';
```

💚 **No bloquea la tabla** pero **los datos no se eliminan inmediatamente**.\
🔍 Para verificar el estado de una mutación:

```sql
SELECT * FROM system.mutations WHERE table = 'trades';
```

### 🚀 Alternativas a las mutaciones:

- **TTL automático** para eliminar registros viejos:
  ```sql
  ALTER TABLE trades MODIFY TTL event_time + INTERVAL 30 DAY;
  ```
- **Eliminar particiones completas** (más eficiente que `DELETE`):
  ```sql
  ALTER TABLE trades DROP PARTITION '202402';
  ```
- **Marcar registros como eliminados en lugar de borrarlos** (`is_deleted = 1`).

---

## 🎯 **Conclusión**

- `LIGHTWEIGHT DELETE` es más eficiente que un `ALTER ... DELETE`, pero sigue sin eliminar datos físicamente de inmediato.
- Las **mutaciones** existen porque ClickHouse **no está diseñado para modificaciones frecuentes**; su arquitectura OLAP prioriza la velocidad en análisis de grandes volúmenes de datos.
- **Alternativas como TTL, particionamiento o flags de eliminación pueden ser más eficientes** según el caso de uso.

👉 **¿Cuándo usar mutaciones?** Para cambios ocasionales en datos históricos.\
👉 **¿Cuándo evitarlas?** Si necesitas eliminar/modificar datos constantemente.

🚀 **Si ClickHouse no está diseñado para OLTP, mejor usar herramientas adecuadas según el caso**.


# Functions, datatypes, operators

## Logic Operators
```sql
select 1+2, plus(1,2);
select 1!=1, 1==1, notEquals(1, 2);
select NOT 1, not(1);
select 1 and 0, 1 or 0, and(1, 0);
```

## Strings vs FixedStrings
```sql
CREATE DATABASE examples;
CREATE TABLE examples.table3(
       column1 String,
       column2 FixedString(4)
)engine = Log;

insert into examples.table3 values ('a', 'ab'), ('b', 'bc');
insert into examples.table3 values ('a', 'ab'), ('b', 'bc'), ('bccccc', 'bcc');
insert into examples.table3 values ('a', 'ab'), ('b', 'bc'), ('bccccc', 'bccccccccccc');

select *
from examples.table3;
```

## datetime
```sql
create table examples.dt(
    date_time   Datetime('Europe/Brussels'),
    date_time2  Datetime64(2, 'Europe/Brussels'),
    date_time6  Datetime64(6, 'Europe/Brussels')
)engine=Log;

insert into examples.dt values (('1999-12-31 23:30:00'), ('1999-12-31 23:30_00.0123456'), ('1999-12-31 23:30_00.0123456'));

select *
from examples.dt;
```

## Arrays
```sql
select array(1, 2, 3.0) as my_array,
       [1, 2, 56] my_array_2,
        array('a', 'b') as arr,
       [1, 2, 56, Null] my_array_3


;select [toDate(1000), toDate32(100), toDateTime64(1000, 5)]

-- Tuples
;select [toDate(1000), toDate32(100), toDateTime64(1000, 5), 'a']
;select tuple(toDate(1000), toDate32(100), toDateTime64(1000, 5), 'a')
```

## Nested
```sql
;CREATE TABLE examples.nested (
    ID  UInt32,
    Code Nested(
        code_id String,
        total_count UInt32
        )
)Engine=Log;

insert into examples.nested values (1, ['a', 'b', 'c'], [1,2,3])

;select Code.code_id, Code.code_id[2]
 from examples.nested

;insert into examples.nested values (1, ['a', 'b', 'c'], [1,2])
```

 ## Enum
Cuando defines un Enum, asignas nombres a valores enteros
column1 puede almacenar solo los valores 'a' o 'b'.
Internamente, 'a' se almacena como 1 y 'b' como 2.
🔍 ¿Por qué usar Enum en lugar de String?
✅ Menos almacenamiento: En lugar de almacenar cadenas, guarda enteros.
✅ Más rápido en comparaciones: Comparar 1 = 1 es más eficiente que ‘a’ = ‘a’.
✅ Evita valores inválidos: Solo puedes insertar 'a' o 'b', evitando errores.

```sql
 ;create table examples.enum(
    column1 Enum('a'=1, 'b'=2)
 )Engine=Log;

INSERT INTO examples.enum
VALUES (1), (2), ('a'), ('b');

select *
from examples.enum


;create table examples.order_state(
    order_state Enum('pending'=1, 'completed'=2, 'failed'=3)
 )Engine=Log;

INSERT INTO examples.order_state
VALUES (1), (2), (3), (2);

select *
from examples.order_state
```


## Low Cardinality
- En lugar de almacenar continuamente 'pendiente', 'completado', etc, con la cardinalidad es baja (3)
permite gestionar las etiquetas por fuera y optimizar la velocidad, etc.
- LowCardinality reduce espacio y mejora consultas con valores repetidos.
- Ideal para filtros y joins en columnas categóricas.
- Se combina bien con Enum para optimizar aún más.

```sql
;CREATE TABLE examples.optimo (
    estado LowCardinality(Enum('pendiente' = 1, 'completado' = 2, 'fallido' = 3))
) ENGINE = MergeTree()
ORDER BY estado;
```



# CSV Upload
Subir un CSV a clickhouse

La tabla que vamos a crear es:

```sql
CREATE TABLE BTCUSD (
    open Float64,
    high Float64,
    low Float64,
    close Float64,
    volume Float64,
    timestamp DateTime64(3, 'UTC')  -- Precisión en milisegundos y zona horaria UTC
) ENGINE = MergeTree()
ORDER BY timestamp;
```

Los datos están en: `C:\Users\oigre\Documents\repos\clickhouse_basics\data\binance_btc_usd.csv`

1. Movemos los datos al contenedor y desde ahí los leemos
```docker
docker cp "C:\Users\oigre\Documents\repos\clickhouse_basics\data\binance_btc_usd.csv" clickhouse:/var/lib/clickhouse/user_files/binance_btc_usd.csv
```
Leemos directamente del archivo
```sql
select *
FROM file(
    '/var/lib/clickhouse/user_files/data/binance_btc_usd.csv',
    'CSV',
    'open Float64, high Float64, low Float64, close Float64, volume Float64, timestamp DateTime64(3, \'UTC\')' );
```

2. Creamos un contenedor con volumen
```docker
docker run -d -p 8123:8123 -p 9000:9000 \
  -e CLICKHOUSE_PASSWORD=clickhouse \
  --name clickhouse \
  -v C:\Users\oigre\Documents\repos\clickhouse_basics\data:/var/lib/clickhouse/user_files/data \
  clickhouse/clickhouse-server:latest
```

```sql
select *
FROM file(
    '/var/lib/clickhouse/user_files/data/binance_btc_usd.csv',
    'CSV',
    'open Float64, high Float64, low Float64, close Float64, volume Float64, timestamp DateTime64(3, \'UTC\')' );
```

Podemos crear la tabla e insertar:
```sql
CREATE DATABASE BINANCE;
CREATE TABLE BINANCE.candles_btcusd (
    open Float64,
    high Float64,
    low Float64,
    close Float64,
    volume Float64,
    timestamp DateTime64(3, 'UTC')  -- Precisión en milisegundos y zona horaria UTC
) ENGINE = MergeTree()
ORDER BY timestamp;
-- Insertar datos desde un archivo CSV
INSERT INTO BINANCE.candles_btcusd 
SELECT * FROM file(
    '/var/lib/clickhouse/user_files/data/binance_btc_usd.csv',
    'CSV');
select *
from BINANCE.candles_btcusd
```` 