# 🛠️ Troubleshooting - P4: Real-World Ingestion 'Operativo-P4_supplyChain'

- **Problema de Scope por GO:** Las variables declaradas pierden contexto si se
  intercala `GO` de forma incorrecta en bloques transaccionales.
  *Solución: Agrupar la lógica en lotes continuos.*
- **Valores NULL inesperados:** Las columnas `BIT` con `DEFAULT` no aplican a
  registros históricos. *Solución: Ejecutar script de normalización UPDATE para
  homologar nulos a 0.*

## 🛠 Guía de Troubleshooting

- **Error de Conexión Named Pipes / TCP-IP:** Asegurarse de que el servicio
   `SQL Server (MSSQLSERVER)` esté activo en Windows y que la variable
    `DB_SERVER=localhost` esté configurada correctamente en el archivo `.env`.
- **Pérdida de Scope por Lotes (`GO`):** Evitar intercalar `GO` en bloques
  transaccionales atómicos para prevenir que las variables del sistema pierdan
   contexto.
- **Inconsistencia por Valores NULL:** Normalizar mediante comandos `UPDATE`
   las columnas con restricciones `DEFAULT` para evitar fallos en filtros analíticos.
