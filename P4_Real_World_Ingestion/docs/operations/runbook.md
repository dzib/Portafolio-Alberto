# 🚀 📖 Runbook Operativo - P4: Supply Chain

- **Procedimiento de Ingesta:** Ejecutar el script `02_bulk_load_kaggle.py`
   dentro del entorno virtual activo para transferir los 180k+ registros.
- **Control de Logs:** Verificar la tabla de auditoría `Staging.Execution_Logs`
   tras cada ejecución para validar los tiempos de procesamiento por lote.
- **Mantenimiento del Servidor:** Monitorear el uso de recursos de la instancia
   local de SQL Server 2025 mediante scripts de inicio y apagado de servicios.



1. **Requisitos Previos:** Python 3.13, SQL Server 2025, ODBC Driver 17 y
   entorno virtual configurado en la partición de desarrollo (`D:\`).
2. **Configuración de Variables:** Crear archivo `.env` con las credenciales de
   conexión a la base de datos local.
3. **Ejecución de Fases:** Ejecutar secuencialmente los scripts desde la Fase 01
   (`01_Setup_DDL`) hasta la Fase 05 (`05_BI_Observabilidad`).
4. **Validación QA:** Ejecutar la suite de pruebas unitarias contenida en la
   carpeta `tests/`.
