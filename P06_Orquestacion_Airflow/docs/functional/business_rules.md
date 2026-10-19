# Reglas de Negocio e Integridad - Módulo P6

* **BRU-01: Idempotencia Operativa**
  * Todas las tareas ejecutadas por los DAGs deben ser estrictamente
    idempotentes. Ejecutar un pipeline múltiples veces para la misma ventana
    de tiempo de datos no debe duplicar registros ni corromper el estado final
    del almacén de datos.
* **BRU-02: Control de Dependencias Direccionales**
  * Ninguna tarea de transformación o carga puede iniciarse si sus nodos
    predecesores (capas de control o extracción) no han reportado un estado de
    éxito (`success`). Se prohíbe la ejecución paralela no gobernada.
* **BRU-03: Política de Catchup Deshabilitada**
  * Para evitar la sobresaturación de recursos de cómputo tras mantenimientos
    o reinicios del servidor, el parámetro `catchup` debe configurarse
    explícitamente en `False` en todos los DAGs de producción.
* **BRU-04: Ventana de Reintentos Limitada**
  * Cada tarea crítica contará con un límite estricto de reintentos
    (ej. `retries=3`) antes de marcar la ejecución global del DAG como fallida
    y emitir una alerta operativa.
