# Guía de Solución de Problemas (Troubleshooting)

## ❌ Error Común: Tabla ya existe sin reemplazo

- **Síntoma:** El pipeline falla indicando que la tabla destino ya
  se encuentra ocupada.
- **Causa:** Uso de `CREATE TABLE` simple en lugar del patrón obligatorio
  `CREATE OR REPLACE TABLE`.
- **Solución:** Actualizar la consulta aplicando el estándar idempotente
  validado en el repositorio.
