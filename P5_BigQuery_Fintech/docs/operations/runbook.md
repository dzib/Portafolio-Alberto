# Runbook de Operación y Mantenimiento

## 🚨 Monitoreo y Alertas

- **Fallo en CTAS:** Si la consulta falla por
concurrencia o permisos, reintentar tras 60 segundos gracias a la
idempotencia del script.

- **Revisión de Costos:** Monitorear el panel de presupuestos de Google
Cloud Console para evitar sobreconsumos de análisis bajo demanda.
