
# Manual Operativo (Runbook) - Módulo P6

* **Operación Diaria:**
  * Supervisar el panel de control de Airflow para verificar que
    el DAG `p6_enterprise_etl_pipeline` finalice sin errores.
* **Mantenimiento y Limpieza de Logs:**
  * Para prevenir la saturación del disco por acumulación de bitácoras,
    ejecutar periódicamente la limpieza de logs en el volumen montado:
    `docker compose down` y purga de la carpeta `logs/`.
* **Reinicio de Servicios:**
  * En caso de actualizaciones en la configuración o variables de entorno:
    `docker compose restart`
