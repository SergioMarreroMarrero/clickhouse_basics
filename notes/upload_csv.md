## Objetivo
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
    '/var/lib/clickhouse/user_files/binance_btc_usd.csv',
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