# P6: Arquitectura del Sistema - Orquestación de Pipelines con Apache Airflow

Este documento detalla las especificaciones de arquitectura (Lógica, Física
y de Despliegue) correspondientes al Módulo **P6_Orquestacion_Airflow**,
diseñado bajo los principios de resiliencia, atomicidad y escalabilidad del
Estándar Dzib.

---

## 1. Arquitectura Lógica (`01_logical_architecture.drawio`)

La arquitectura lógica describe las capas funcionales que componen el flujo
de trabajo del motor de orquestación, asegurando un desacoplamiento estricto
entre el gobierno de tareas y la ejecución de código.

+-----------------------------------------------------------------+
|                    Capa de Gobierno y UI                        |
|              (Apache Airflow Webserver - Port 8080)             |
+-----------------------------------------------------------------+
|
v
+-----------------------------------------------------------------+
|                    Capa de Orquestación & Scheduling            |
|              (Apache Airflow Scheduler & LocalExecutor)         |
+-----------------------------------------------------------------+
|                                       |
v                                       v
+-----------------------+               +-------------------------+
|    Tareas de Control  |               |    Capa de Cómputo      |
|    (EmptyOperator)    |               |  (PythonOperator / ETL) |
+-----------------------+               +-------------------------+
|
v
+-------------------------+
|   Validación de Calidad |
|   (The Dzib Standard)   |
+-------------------------+


* **Capa de Gobierno y UI:** Proporciona la interfaz gráfica centralizada
  para la supervisión de estados, reintentos y visualización de bitácoras en
  tiempo real.
* **Capa de Orquestación:** Administra los triggers temporales
  (`schedule_interval='@daily'`) y gestiona las dependencias direccionales de
  los nodos mediante el `LocalExecutor`.
* **Capa de Cómputo y Calidad:** Ejecuta la lógica de negocio modularizada,
  aplicando validaciones estrictas de integridad transaccional antes de
  liberar los datos hacia los destinos finales.

---

## 2. Arquitectura Física (`02_physical_architecture.drawio`)

La arquitectura física representa la distribución de los recursos de
cómputo y almacenamiento encapsulados en contenedores Docker independientes.

* **Servicio de Base de Datos (`postgres:13`):** Almacena de forma
  persistente los metadatos de Airflow (historial de ejecuciones,
  conexiones, variables y XComs). Cuenta con un sistema de `healthcheck`
  basado en `pg_isready` para garantizar disponibilidad antes de permitir
  conexiones de escritura.
* **Servicio de Inicialización (`airflow-init`):** Ejecuta automáticamente
  las migraciones de esquemas de base de datos
  (`_AIRFLOW_DB_UPGRADE='true'`) y aprovisiona el usuario administrador por
  defecto (`admin/admin`), previniendo fallos de arranque en frío.
* **Motores de Ejecución (`airflow-webserver` & `airflow-scheduler`):**
  Contenedores efímeros basados en la imagen oficial
  `apache/airflow:2.7.2`, sincronizados en tiempo real mediante volúmenes
  locales montados para DAGs, logs y plugins.

---

## 3. Arquitectura de Despliegue (`03_deployment_architecture.drawio`)

El modelo de despliegue implementa el paradigma de **Infraestructura como
Código (IaC)** ligero mediante Docker Compose, permitiendo despliegues
idénticos y reproducibles (*one-click deployment*) tanto en estaciones de
desarrollo local como en servidores de producción en la nube.

* **Aislamiento de Entornos:** Utiliza redes virtuales internas de Docker
  (`bridge`) para aislar el tráfico de la base de datos, exponiendo al host
  únicamente el puerto de la interfaz de usuario (`8080`).
* **Persistencia de Volúmenes:**
  * `./dags:/opt/airflow/dags` (Sincronización bidireccional del código de los pipelines).
  * `./logs:/opt/airflow/logs` (Persistencia y auditoría de errores de ejecución).
  * `./plugins:/opt/airflow/plugins` (Extensiones personalizadas del motor).
