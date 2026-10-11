# ADR-001: Uso de Common Table Expressions (CTEs) Anidadas para Extracción Atómica

## Estado

Aceptado

## Contexto

El sistema escolar ingiere metadatos compuestos en formato de cadena
(ej. `FechaIngreso | Estatus | Promedio`). Se requería una estrategia
de alto rendimiento para descomponer estos valores sin saturar la
memoria ni realizar múltiples escaneos de la tabla base.

## Decisión

Se implementó procesamiento basado en CTEs anidadas,
permitiendo aislar el cálculo de delimitadores
(`CHARINDEX`, `SUBSTRING`) en una sola pasada lógica por
registro antes de aplicar la persistencia física tipada.

## Consecuencias

- **Positivas:** Mejora notablemente la legibilidad del código ETL y
  optimiza el uso de CPU frente a subconsultas escalares repetidas.
- **Negativas:** Requiere un diseño riguroso de índices en las columnas
  operativas para evitar costos elevados en consultas de gran volumen.
