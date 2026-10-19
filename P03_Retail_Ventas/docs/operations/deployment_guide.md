# Guía de Despliegue - Pipeline Híbrido P3 Retail

## Requisitos Previos

- Python 3.10+ con entorno virtual activo.
- Microsoft SQL Server 2025.
- Controlador ODBC Driver 17 for SQL Server.
- Librerías requeridas:
  - `pandas`
  - `sqlalchemy`
  - `pyodbc`
  - `faker`

## Secuencia de Ejecución del Pipeline Híbrido

Ejecute los componentes en el siguiente orden estricto:

1. **Generación de Datos (Python):** Ejecute
   `01_GeneradorDatos.py` para crear el dataset sintético de 50,000
   registros en la carpeta de datos.
2. **Estructura Base (SQL):** Ejecute el script
   `01_Estructura_P3.sql` en SQL Server para crear esquemas y tablas
   de staging.
3. **Carga Masiva (Python):** Ejecute `02_CargaSQL.py` para
   realizar la ingesta de alta velocidad mediante SQLAlchemy y
   `fast_executemany`.
4. **ETL y Limpieza (SQL):** Ejecute secuencialmente
   `02_CargaLimpieza_P3.sql` y `03_LimpiezaMetadata_P3.sql` para
   resolver colisiones DDL/DML y materializar las tablas de
   producción.
5. **Analítica Híbrida (Python):** Ejecute
   `03_Analitica_Ventas.py` para consumir las vistas SQL y generar
   el dashboard de BI en consola con tiempos sub-segundo.
