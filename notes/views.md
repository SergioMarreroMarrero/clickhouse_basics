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

