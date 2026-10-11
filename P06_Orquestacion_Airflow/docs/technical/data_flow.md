# Flujo de Datos (Data Flow) - Módulo P6

* **Fase 1: Extracción (Ingesta inicial)**
  * El DAG activa el operador de extracción para recolectar datos
    crudos desde fuentes transaccionales o archivos locales estructurados.
* **Fase 2: Transformación (Procesamiento)**
  * Se aplica limpieza, normalización y validación de esquemas utilizando
    Python y Pandas dentro del entorno aislado del `PythonOperator`.
* **Fase 3: Carga y Almacenamiento (Persistencia)**
  * Los datos limpios son volcados al destino final, registrando el
    estado de la operación mediante los XComs y metadatos de Airflow.
