
# 🚀  Guía de Despliegue - P4: Real-World Ingestion

1. **Requisitos de Infraestructura:**
   - Python 3.13 con entorno virtual configurado en `D:\Dev\`.
   - SQL Server 2025 Developer Edition y SSMS 22.
   - ODBC Driver 17 for SQL Server.
2. **Configuración del Pipeline:**
   - Asegurar las credenciales en el archivo `.env` de configuración global.
   - Validar la exclusión de datasets pesados de más de 100MB en el `.gitignore`.
3. **Ejecución Secuencial:**
   - Ejecutar la Fase 01 (`01_Setup_DDL`) para crear esquemas.
   - Ejecutar la Fase 02 (`02_Ingesta_Pro`) para la carga con Python.
   - Desplegar las fases 03 a 05 para orquestación y vistas analíticas.
