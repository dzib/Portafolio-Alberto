# Bitácora de Implementación

## Resumen

Este proyecto demuestra la implementación de un agente conversacional
en tiempo real utilizando el Google Agent Development Kit (ADK), Vertex AI y
Gemini Live.

Se automatizó el aprovisionamiento de infraestructura en Google Cloud
Platform (GCP) mediante scripts de Bash en Cloud Shell, habilitando las APIs
de Vertex AI, configurando entornos virtuales optimizados con `uv` y
ejecutando pruebas de conectividad (_preflight_) para garantizar la
disponibilidad de Gemini Live en tiempo real.

---

## Configuración del Entorno (_Environment Setup_)

### Entorno de Desarrollo

- Google Cloud Shell
- Python 3.12
- Google Agent Development Kit (ADK)
- Vertex AI
- Gemini Live
- FastAPI

---

## Creación del Proyecto (_Project Creation_)

Se creó y configuró un proyecto dedicado en Google Cloud para aislar los
recursos del agente.

- **ID del Proyecto:** `agent-valley-8393`
- **Script de automatización:**

  ```bash
  ./setup_project.sh
  ```

## Servicios Habilitados (Services Enabled)

El proceso de configuración habilitó automáticamente los servicios necesarios en GCP:

- Vertex AI API ( `aiplatform.googleapis.com`)
- AI Platform API
- Google Authentication Services

## Autenticación (Authentication)

Se configuraron las credenciales de autenticación y los permisos por defecto de la aplicación (ADC) en Cloud Shell:

```bash
gcloud auth login
gcloud auth application-default login
```

## Entorno Python (Python Environment)

Se gestionó un entorno virtual aislado de alta velocidad utilizando uv, instalando las dependencias clave del ecosistema:

- google-adk
- google-genai
- fastapi
- uvicorn

## Configuración del Agente (Agent Configuration)

Se integró el modelo de voz y audio nativo para la interacción conversacional:

- Modelo: Gemini Live 2.5 Flash Native Audio

Validación de conexión:

```plaintext
the line opens
gemini-live-2.5-flash-native-audio
```

## Ejecución de la Aplicación (Application Execution)

El entorno local del mercado nocturno se despliega ejecutando:

```bash
bash valley.sh
```

Endpoints de la aplicación:

- Interfaz web: `http://localhost:3450`
- Panel de desarrollo: `http://localhost:3450/workbench/dev-ui/?app=stage`

## Retos Superados (Challenges Encountered)

### Incidencia de Autenticación

- Error detectado: `RefreshError: service account info is missing 'email' field`
- Solución aplicada: Reconfiguración de las credenciales por defecto (_Application Default Credentials_) y reejecución limpia del script de aprovisionamiento en Cloud Shell.

## Resultados y Convalidación (Outcomes)

Se validó exitosamente la integración completa de:

- Google ADK y Vertex AI
- Gemini Live (Audio nativo)
- FastAPI y flujos Cloud Shell

Resultado final:
✅ Agente conversacional de Inteligencia Artificial desplegado y operando correctamente.
