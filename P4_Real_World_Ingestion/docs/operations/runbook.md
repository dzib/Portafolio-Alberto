# 🚀 Guía de Despliegue - P4: Real-World Ingestion (Runbook Operativo)

- **Procedimiento de Carga Masiva:** Ejecutar el script `02_bulk_load_kaggle.py`
 mediante la terminal activa del entorno virtual.
- **Monitoreo de Transacciones:** Consultar la tabla de auditoría `Staging.Execution_Logs`
 para verificar el estado de los bloques atómicos.
- **Mantenimiento de Entorno:** Refrescar la caché de IntelliSense en VS Code
 en caso de modificaciones en los metadatos de las tablas SQL.

1. **Requisitos Previos:** Python 3.13, SQL Server 2025, ODBC Driver 17 y
 entorno virtual configurado en la partición de desarrollo (`D:\`).
2. **Configuración de Variables:** Crear archivo `.env` con las credenciales de
 conexión a la base de datos local.
3. **Ejecución de Fases:** Ejecutar secuencialmente los scripts desde la Fase 01
 (`01_Setup_DDL`) hasta la Fase 05 (`05_BI_Observabilidad`).
4. **Validación QA:** Ejecutar la suite de pruebas unitarias contenida en la
 carpeta `tests/`.
