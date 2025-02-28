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

