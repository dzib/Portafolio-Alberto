# Guía de Despliegue - Módulo P6

* **Propósito:** Proveer instrucciones paso a paso para desplegar
  la infraestructura de Airflow y PostgreSQL mediante Docker Compose.
* **Prerrequisitos:**
  * Docker Desktop instalado y en ejecución en el sistema host.
  * Git para la clonación del repositorio y gestión de ramas.
* **Pasos de Despliegue:**
  1. Clonar el repositorio y ubicarse en la carpeta del módulo:
     `cd P6_Orquestacion_Airflow`
  2. Inicializar los contenedores en segundo plano:
     `docker compose up -d`
  3. Verificar el estado de los servicios ejecutando:
     `docker compose ps`
  4. Acceder a la interfaz web en `http://localhost:8080`
     utilizando las credenciales por defecto (`admin / admin`).
