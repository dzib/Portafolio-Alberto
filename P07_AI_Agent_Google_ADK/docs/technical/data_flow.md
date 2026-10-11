# Flujo de Datos (Data Flow) - Módulo P7

* **Fase 1: Entrada y Recepción**
  * El usuario interactúa a través de la interfaz web o cliente CLI,
    enviando peticiones de voz o texto que son capturadas por el backend de FastAPI.
* **Fase 2: Orquestación del Agente**
  * Google ADK procesa la solicitud entrante, gestiona el contexto de la
    sesión actual y determina si requiere invocar herramientas adicionales.
* **Fase 3: Inferencia Multimodal en la Nube**
  * Vertex AI y Gemini Live procesan la petición en tiempo real, generando
    una respuesta sincronizada que se devuelve al usuario en formatos de voz y texto.

