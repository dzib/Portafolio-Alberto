# Agent Valley Night Market

---

## Overview

Conversational AI agent developed using Google Agent Development Kit (ADK),
Vertex AI and Gemini Live.

## Architecture

```mermaid
flowchart TD

A[User] --> B[Web Interface]

B --> C[FastAPI]

C --> D[Google ADK]

D --> E[Vertex AI]

E --> F[Gemini Live]

F --> G[Voice Response]
F --> H[Text Response]
```

```text
agent-valley-nightmarket
│
├── README.md
├── pyproject.toml
├── uv.lock
├── valley.sh
├── setup_codelab.sh
├── setup_project.sh
│
├── docs
│   │
│   ├── architecture
│   │   └── architecture.md
│   │
│   ├── screenshots
│   │   ├── cloudshell.png
│   │   ├── setup.png
│   │   ├── setup-complete.png
│   │   ├── project-created.png
│   │   ├── vertex-ai-enabled.png
│   │   ├── gemini-connected.png
│   │   └── demo.png
│   │
│   ├── implementation.md
│   └── lessons-learned.md
│
├── forge
├── scripts
├── site
└── stage
```

## Documentación

| Documento | Descripción |
|-----------|-------------|
| architecture.md | Arquitectura de la solución |
| implementation.md | Implementación técnica |
| lessons-learned.md | Project Learnings |

## Tecnologías

- Google Cloud Platform
- Vertex AI
- Gemini Live
- Google ADK
- FastAPI
- Python
- JavaScript
- Cloud Shell

## Características

- Interacción conversacional en tiempo real
- Integración de Gemini Live
- Implementación nativa en la nube
- Comunicación de audio y texto
- Orquestación de IA de Vertex

## Habilidades demostradas

### Cloud Engineering

- Google Cloud Project Configuration
- API Enablement
- Authentication Management

### Generative AI

- AI Agents
- Prompt Engineering
- Gemini Live

### Software Development

- FastAPI
- Python
- Frontend Integration

## Project Outcomes

- Built a functioning AI conversational agent.
- Configured Vertex AI services.
- Deployed and tested Google ADK components.
- Implemented a cloud-native AI workflow.

## Project Evidence

| Evidence | Description |
|-----------|-------------|
| cloudshell.png | Environment Setup |
| project-created.png | Google Cloud Project Creation |
| vertex-ai-enabled.png | Vertex AI Enabled |
| gemini-connected.png | Gemini Connected |
| setup-complete.png | Successful Deployment |
| demo.png | Running Application |


### Environment Setup

![Google Cloud Shell terminal showing the Agent Valley Night Market project setup in a command-line environment](../assets/P7/img/screenshots/cloudshell.png)

### Deployment

![Google Cloud Shell terminal showing that the Agent Valley Night Market deployment setup completed successfully](../assets/P7/img/screenshots/vertex-ai-enabled.png)

### Setup Completed

![Google Cloud Shell terminal confirming successful completion of the Agent Valley Night Market setup](../assets/P7/img/screenshots/setup-complete.png)

"El código fuente completo y los scripts de despliegue se ejecutaron en Google
Cloud Shell a través del repositorio oficial de Agent Valley Night Market."

### Application Running

![Running Agent Valley Night Market application with its conversational interface displayed in a web browser](../assets/P7/img/screenshots/project-created.png)

## Evidencias

## Configuración del entorno

![Google Cloud Shell terminal showing the project environment and setup commands](../assets/P7/img/screenshots/cloudshell.png)

## Setup completado

![Google Cloud setup screen showing configuration progress for the Agent Valley Night Market project](../assets/P7/img/screenshots/setup-complete.png)

## Demonstración

![Agent Valley Night Market demonstration running in a web browser with the conversational interface visible](../assets/P7/img/screenshots/demo.png)

### Resultados del proyecto

- He creado un agente conversacional de IA completamente funcional.
- Servicios de Vertex AI configurados.
- Se han implementado y probado los componentes de Google ADK.
- Implementé un flujo de trabajo de IA nativo de la nube.

- Proyecto creado y API habilitada.
- Configuración completada
"El código fuente completo y los scripts de despliegue se ejecutaron en
Google Cloud Shell a través del repositorio oficial de Agent Valley Night Market."

## Author

Alberto Dzib

LinkedIn: [Alberto Dzib](https://linkedin.com/in/alberto-dzib)

Portfolio: [Portafolio-Alberto](https://github.com/dzib/Portafolio-Alberto)
