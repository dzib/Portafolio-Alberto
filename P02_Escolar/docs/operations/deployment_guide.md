# Guía de Despliegue - P2 Escolar

## Requisitos Previos

- SQL Server 2025 Developer/Enterprise.
- SQL Server Management Studio (SSMS).

## Secuencia de Ejecución

Ejecute los scripts de la carpeta `scripts/` en orden estricto:

1. `01_Setup_DDL.sql` ➔ Crea esquemas `Catalogos` y
   `Operaciones`, limpiando ejecuciones previas con
   reseteo `SINGLE_USER`.
2. `02_DML_Seed_Data.sql` ➔ Carga maestros de
   departamentos y carreras.
3. `03_Stess_Test.sql` ➔ Simula la inserción masiva
   de 5,000+ alumnos con distribución de estatus y
   blindaje de nulos.
4. `04_ETL_Limpieza.sql` ➔ Ejecuta el motor ETL con
   CTEs para normalizar la metadata sucia.
5. `05_Reportes_BI.sql` ➔ Genera el reporte ejecutivo
   y las métricas de eficiencia presupuestaria.
