# Indicadores Clave de Rendimiento (KPIs) - Módulo P6

* **KPI-01: Tasa de Éxito de los Pipelines (Pipeline Success Rate)**
  * **Definición:** Porcentaje de ejecuciones exitosas de DAGs frente al total
    de ejecuciones programadas en un periodo mensual.
  * **Meta:** $\ge 99.5\%$ de disponibilidad y éxito operativo.
* **KPI-02: Tiempo Medio de Recuperación (MTTR - Mean Time to Recovery)**
  * **Definición:** Tiempo promedio transcurrido desde que el orquestador
    emite una alerta por fallo en una tarea hasta su resolución o reintento
    exitoso.
  * **Meta:** $< 30$ minutos para incidencias automatizadas.
* **KPI-03: Eficiencia en la Ventana de Ejecución (Execution Duration SLA)**
  * **Definición:** Duración total del ciclo ETL en comparación con la ventana
    temporal asignada antes de la disponibilidad de los datos para los
    analistas de negocio.
  * **Meta:** Cierre completo del proceso dentro de la ventana nocturna
    establecida (variación menor al $5\%$ sobre la media histórica).
