
# 🛠️ Troubleshooting - P4: Real-World Ingestion

- **Problema de Scope por GO:** Las variables declaradas pierden contexto si se
 intercala `GO` de forma incorrecta en bloques transaccionales.
 *Solución: Agrupar la lógica en lotes continuos.*
- **Valores NULL inesperados:** Las columnas `BIT` con `DEFAULT` no aplican a
 registros históricos. *Solución: Ejecutar script de normalización UPDATE para
 homologar nulos a 0.*
