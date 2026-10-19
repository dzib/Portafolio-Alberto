# Guía de Despliegue - Módulo P7

* **Propósito:** Proveer instrucciones para configurar y desplegar
  el entorno de agentes de IA utilizando Google ADK y Vertex AI.
* **Prerrequisitos:**
  * Acceso a Google Cloud Shell o un entorno local con Google Cloud SDK.
  * Python 3.12 y el gestor de paquetes `uv`.
* **Pasos de Despliegue:**
  1. Configurar las credenciales de autenticación en la nube:
     `gcloud auth login` y `gcloud auth application-default login`
  2. Ejecutar el script automatizado de aprovisionamiento del proyecto:
     `./setup_project.sh`
  3. Inicializar el entorno virtual e instalar las dependencias:
     `uv pip install -r requirements.txt`
  4. Iniciar la ejecución de la aplicación del agente:
     `bash valley.sh`
