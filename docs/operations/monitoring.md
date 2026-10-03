# 📊 Monitoreo y Salud del Sistema (Monitoring)

Para asegurar la alta disponibilidad y rendimiento de los pipelines:

- **Monitoreo de I/O y CPU:** Seguimiento de tiempos de ejecución en
 milisegundos y uso de recursos durante la ingesta masiva
 (benchmarks documentados en el README principal).
- **Validación Automática:** Ejecución periódica de scripts de pruebas
 unitarias (`pytest`) y auditoría de enlaces (`audit_portfolio.py`).
- **Control de Logs:** Revisión de registros de errores en los flujos
 de Apache Airflow y transacciones de SQL Server.
