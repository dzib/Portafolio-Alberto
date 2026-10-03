# Guía de Despliegue - P1 Inventario

## Requisitos Previos

- SQL Server 2025 o superior (compatible con Azure SQL).
- SQL Server Management Studio (SSMS) o VS Code con extensión mssql.
- Microsoft Excel con controlador ODBC (Driver 17 para SQL Server)
  configurado.

## Secuencia de Despliegue de Scripts

Ejecute los scripts en la carpeta `Scripts/` en riguroso orden
secuencial:

1. `01_Setup_DDL.sql` ➔ Crea esquemas, limpia bases de datos previas y
   levanta las tablas maestras y transaccionales.
2. `02_DML_Seed.sql` ➔ Inserta los datos semilla iniciales de prueba.
3. `03_Procesamiento_Batch.sql` ➔ Ejecuta pruebas de estrés (*Stress Test*)
   generando volumen masivo e inyectando ruido legacy.
4. `04_ETL_Limpieza.sql` ➔ Ejecuta el motor de limpieza atómica
   (*Single-Pass Processing*).
5. `05_BI_Analytics.sql` ➔ Despliega las vistas ejecutivas y KPIs
   logísticos para consumo de BI.
