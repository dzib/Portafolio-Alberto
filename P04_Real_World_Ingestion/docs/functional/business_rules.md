# Requerimientos de Negocio - P4: Real-World Ingestion (Supply Chain)

## 1. Visión General

El proyecto P4 procesa operaciones reales de la cadena de suministro global
 (*DataCo Global Supply Chain*), integrando Python 3.13 para la ingesta masiva
 de alto rendimiento y SQL Server 2025 para la transformación transaccional y analítica.

## 2. Requerimientos Funcionales

- **RF-01 (Ingesta Masiva Optimizada):** Procesamiento e inserción de más de
 180,000 registros del dataset de origen hacia bases de datos relacionales sin
 degradación de rendimiento.
- **RF-02 (Tasa de Transferencia Senior):** Superar un rendimiento de 20,000
 registros por segundo utilizando SQLAlchemy y `fast_executemany`.
- **RF-03 (Observabilidad y Auditoría):** Registro transaccional de cada lote
 ejecutado mediante bloques atómicos (`BEGIN TRY...CATCH`) y tablas de logs.
- **RF-04 (Exposición Analítica Interactiva):** Conexión de vistas analíticas
 limpias hacia herramientas de visualización moderna (PyGWalker).

## 3. Criterios de Éxito

- Dataset de 180,519 registros procesado exitosamente en menos de 8 segundos.
- Cero registros con nulos críticos en columnas financieras o de estado de entrega.
- Vistas de analítica logística operando con normalización de datos históricos.
