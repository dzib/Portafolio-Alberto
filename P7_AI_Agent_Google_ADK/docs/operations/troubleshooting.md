# Guía de Solución de Problemas (Troubleshooting) - Módulo P7

* **Problema 1: Error de Autenticación con Service Account**
  * *Síntoma:* Mensaje `RefreshError: service account info is missing 'email' field`.
  * *Solución:* Reconfigurar las credenciales por defecto ejecutando
    nuevamente `gcloud auth application-default login` y validando los
    permisos del proyecto `agent-valley-8393`.
* **Problema 2: Fallo en la Inicialización del Entorno de Python**
  * *Síntoma:* Incompatibilidades de librerías o dependencias faltantes de ADK.
  * *Solución:* Recrear el entorno virtual limpio y reinstalar las
    dependencias mediante el gestor optimizado `uv`.

