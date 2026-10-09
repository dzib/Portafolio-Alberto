# Requerimientos de Negocio - Módulo P6 (Orquestación de Pipelines)

* **BR-01: Automatización y Calendarización de Procesos ETL**
  * El sistema debe automatizar la ejecución de los flujos de
    extracción, transformación y carga (ETL) sin intervención manual,
    asegurando una cadencia regular y predecible de procesamiento de datos.
* **BR-02: Tolerancia a Fallos y Reintentos Resilientes**
  * Ante interrupciones transitorias de red o caídas de servicios
    externos, el orquestador debe reintentar automáticamente las tareas
    fallidas aplicando políticas de intervalo exponencial (`retry_delay`),
    evitando la corrupción de datos o la parada total del pipeline.
* **BR-03: Trazabilidad y Monitoreo Centralizado**
  * Se requiere una interfaz visual centralizada que permita a los equipos
    de ingeniería y analítica auditar el estado de ejecución de cada tarea,
    verificar bitácoras de errores en tiempo real y medir el cumplimiento de
    los tiempos de entrega (SLA).
* **BR-04: Despliegue Portátil (One-Click Deployment)**
  * La infraestructura de orquestación debe ser completamente reproducible
    y portable mediante contenedores, permitiendo su despliegue inmediato en
    entornos locales o de nube sin fricciones de configuración.
