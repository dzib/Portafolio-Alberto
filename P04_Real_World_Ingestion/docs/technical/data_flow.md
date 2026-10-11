
# 🔄 Flujo de Datos - P4: Real-World Ingestion

El pipeline de datos sigue un flujo estructurado de 5 fases principales:

1. **Extracción en Origen:** Lectura del dataset masivo de Kaggle (DataCo Global
 Supply Chain) mediante script de Python.
2. **Ingesta a Staging:** Carga masiva optimizada con `fast_executemany` hacia
 la tabla `Staging.Kaggle_SupplyChain_Raw`.
3. **Orquestación y Transacciones:** Procesamiento atómico mediante bloques
 `BEGIN TRY...CATCH` controlados por T-SQL.
4. **Limpieza y Normalización:** Transformación y manejo de anomalías usando
 T-SQL dinámico (`sp_executesql`).
5. **Consumo Analítico:** Exposición de vistas de eficiencia logística hacia
 el entorno de PyGWalker.
