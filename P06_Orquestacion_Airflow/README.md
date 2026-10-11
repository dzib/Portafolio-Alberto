
# 🚀 P6: Orquestación Enterprise & Contenerización (Apache Airflow & Docker)

> *"Automatización, tolerancia a fallos y despliegues idempotentes de punta a punta."*

## 🔄 P6_Orquestacion_Airflow: Orquestación con Apache Airflow

  (Resiliencia Operativa)

"Elimina la dependencia de ejecuciones manuales propensas a fallos mediante
pipelines de datos autogestionados y tolerantes a errores. Garantiza la entrega
puntual y sin interrupciones de los datasets corporativos hacia las plataformas
de Business Intelligence."

---

## 📋 Resumen Ejecutivo (Método STAR)

* **Situación:** Los pipelines de datos desarrollados en los módulos
  anteriores requerían ejecución manual y carecían de un sistema
  automatizado de control de dependencias, lo que representaba un
  riesgo operativo ante fallos en la ingesta o transformación masiva.
* **Tarea:** Diseñar e implementar una arquitectura de orquestación
  moderna y un entorno de ejecución completamente contenerizado que
  garantice despliegues universales y gobernanza de flujos
  (*End-to-End*).
* **Acción:**
  * Se configuró un entorno aislado basado en **Docker y Docker
    Compose** (`LocalExecutor` con PostgreSQL como backend de
    metadatos).
  * Se desarrolló un DAG transaccional en **Apache Airflow**
    (`portfolio_etl_dag.py`) que integra tareas de extracción,
    validación automatizada de calidad de datos (`Data Quality
    Testing`) y carga segura.
* **Resultado:** Un ecosistema portable de "Un Clic" (`docker compose
  up`) que elimina la fricción de dependencias locales y asegura la
  observabilidad y el monitoreo en tiempo real de los procesos de
  datos.

---

## 🛠️ Stack Tecnológico

* **Orquestador:** Apache Airflow (v2.7.2)
* **Contenerización:** Docker & Docker Compose
* **Base de Datos (Metadatos):** PostgreSQL (v13)
* **Lenguaje:** Python 3.10+

---

## 📂 Estructura del Proyecto

```text
P6_Orquestacion_Airflow/
├── dags/
│   └── portfolio_etl_dag.py       # Pipeline principal orquestado
├── logs/                          # Registro de ejecuciones y auditoría
├── plugins/                       # Módulos y extensiones personalizadas
├── docker-compose.yml             # Arquitectura de infraestructura aislada
└── Dockerfile                     # Configuración del entorno de ejecución
```



```bash
git add P6_Orquestacion_Airflow/README.md
git commit -m \
  "docs: añade README estructurado bajo método STAR para el Proyecto P6"
git push origin feature/p6-orchestration-docker
```
