# Runbook Operativo - Pipeline P1 Inventario

---

## Procedimiento de Reinicio Total (Hard Reset / Idempotency Check)

Si por alguna razón el entorno de pruebas presenta inconsistencias por
ejecuciones parciales:

1. Conéctese a SQL Server y ejecute el script `01_Setup_DDL.sql`.
   Esto destruirá y reconstruirá la base de datos de manera limpia,
   matando conexiones activas.
2. Ejecute secuencialmente `02_DML_Seed.sql` y `03_Procesamiento_Batch.sql`
   para restablecer el volumen masivo y los datos con ruido legacy.
3. Valide la limpieza ejecutando `04_ETL_Limpieza.sql`.
4. Compruebe la disponibilidad de las vistas con `05_BI_Analytics.sql`.

---

## Reinicio Completo

1. Ejecutar limpieza de tablas.
2. Reiniciar identidades.
3. Ejecutar scripts 01 al 05.
4. Ejecutar validaciones QA.
5. Actualizar Dashboard.

---

## Resultado Esperado

- Sin errores.
- Sin duplicados.
- Integridad referencial correcta.

