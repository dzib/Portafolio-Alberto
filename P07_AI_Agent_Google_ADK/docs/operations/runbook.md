# Manual Operativo (Runbook) - Módulo P7

* **Verificación de Conectividad (Preflight):**
  * Antes de iniciar las sesiones conversacionales, comprobar la
    disponibilidad del modelo ejecutando la validación del canal:
    `gemini-live-2.5-flash-native-audio`
* **Supervisión de Endpoints:**
  * Monitorear los servicios locales activos:
    * Interfaz web: `http://localhost:3450`
    * Panel de desarrollo: `http://localhost:3450/workbench/dev-ui/?app=stage`
* **Gestión de Sesiones:**
  * Asegurar la correcta limpieza de estados de sesión del agente y
    respaldo de artefactos generados en la carpeta `reports/`.

