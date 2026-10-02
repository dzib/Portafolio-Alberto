# Arquitectura de Solución

```mermaid
flowchart TD

A[Usuario] --> B[Frontend Web]

B --> C[FastAPI]

C --> D[Google ADK]

D --> E[Vertex AI]

E --> F[Gemini Live]

F --> G[Respuesta de Voz]

F --> H[Respuesta de Texto]
```

## Flujo

1. El usuario interactúa con la interfaz.
2. FastAPI recibe las solicitudes.
3. Google ADK coordina los agentes.
4. Vertex AI procesa las peticiones.
5. Gemini Live genera la respuesta.
6. La respuesta se devuelve en voz y texto.
