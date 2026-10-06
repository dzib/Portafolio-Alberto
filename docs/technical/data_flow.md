# 🔄 Flujo de Datos Técnico (Technical Data Flow)

Detalle de la ejecución de los pipelines a nivel de código y motor:

1. **Extracción:** Lectura optimizada por lotes mediante subprocesos en Python (`fast_executemany`).
2. **Transformación:** Aplicación de CTEs, funciones de ventana (`RANK`), y bloques
 `TRY/CATCH` para control de errores transaccionales en T-SQL.
3. **Carga:** Persistencia idempotente en bases de datos relacionales y
 ejecución de CTAS en entornos cloud.

## 🔄 Secuencia de Procesamiento

```mermaid
sequenceDiagram
    participant Source as Fuentes (CSV / APIs)
    participant Python as Python Ingestion
    participant SQL as SQL Server 2025
    participant BI as Herramienta BI / PyGWalker

    Source->>Python: Extracción optimizada (Batch)
    Python->>SQL: Carga transaccional (fast_executemany)
    Note over SQL: Aplicación de CTEs, Limpieza y Try/Catch
    SQL->>BI: Exposición de Vistas Analíticas
```

Fuente
↓
Ingesta
↓
Transformación
↓
Validación
↓
Almacenamiento
↓
Visualización
