# 🧠 Arquitectura Lógica del Portafolio

Este documento describe el flujo conceptual y la separación de
responsabilidades en los pipelines de datos del portafolio.

## 🔄 Flujo de Datos General

El ecosistema sigue un pipeline estructurado desde la fuente hasta la capa
consumo analítico y automatización avanzada:

1. **Fuentes (Sources):** Ingesta de datos heterogéneos (archivos CSV,
   Kaggle, datasets simulados con Faker y APIs externas).
2. **Capa de Ingesta (Python/SQL):** Procesamiento inicial, manejo de tipos
   de datos y optimización de I/O mediante scripts en Python (`pandas`,
   `sqlalchemy`) y transacciones en SQL Server.
3. **Capa de Transformación (ETL/ELT):** Normalización de datos, aplicación
   de CTEs, eliminación de duplicados y limpieza de metadatos (Single-Pass
   Processing).
4. **Almacenamiento (Storage):** Modelado relacional en bases de datos (SQL
   Server 2025) y Data Warehouses en la nube (BigQuery).
5. **Capa Analítica y BI:** Vistas optimizadas para herramientas de
   visualización (Power BI, PyGWalker) y toma de decisiones ejecutivas.
6. **Agentes Inteligentes y Orquestación:** Automatización de flujos mediante
   Apache Airflow e integración de casos de IA.

## 🔄 Technical Data Flow

Detalle de la ejecución de los pipelines a nivel de código y motor transaccional.

## ⚙️ Etapas del Pipeline

1. **Extracción:** Lectura masiva por lotes mediante subprocesos en Python (`fast_executemany`).
2. **Transformación:** Aplicación de CTEs, funciones de ventana (`RANK`), y bloques
 `TRY/CATCH` para resiliencia en T-SQL.
3. **Carga:** Persistencia idempotente y ejecución de CTAS en BigQuery.
