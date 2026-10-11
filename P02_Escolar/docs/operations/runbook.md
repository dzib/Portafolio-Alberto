# Runbook Operativo - Pipeline P2 Escolar

## Procedimiento de Despliegue y Pruebas de Estrés (Hard Reset)

Si es necesario reiniciar o re-ejecutar el ciclo completo de
pruebas de estrés y limpieza:

1. Conéctese a la instancia de SQL Server y ejecute
   `01_Setup_DDL.sql` para reconstruir los esquemas
   `Catalogos` y `Operaciones`.
2. Ejecute `02_DML_Seed_Data.sql` para poblar los maestros
   institucionales.
3. Ejecute `03_Stess_Test.sql` asegurándose de que active el
   reseteo de contadores (`DBCC CHECKIDENT`) y la inyección
   masiva de 5,000+ registros.
4. Ejecute `04_ETL_Limpieza.sql` para activar el
   procesamiento con CTEs anidadas.
5. Valide los resultados ejecutando
   `05_Reportes_Bl.sql`.
