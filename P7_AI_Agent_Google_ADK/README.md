# Agent Valley Night Market

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

## Documentation

| Document | Description |
|-----------|-------------|
| architecture.md | Solution Architecture |
| implementation.md | Technical Implementation |
| lessons-learned.md | Project Learnings |

## Technologies

- Google Cloud Platform
- Vertex AI
- Gemini Live
- Google ADK
- FastAPI
- Python
- JavaScript
- Cloud Shell

## Features

- Real-time conversational interaction
- Gemini Live integration
- Cloud-native deployment
- Audio and text communication
- Vertex AI orchestration

## Skills Demonstrated

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

![Google Cloud Shell terminal showing the Agent Valley Night Market project setup in a command-line environment](./assets/img/screenshots/cloudshell.png)

### Deployment

![Google Cloud Shell terminal showing that the Agent Valley Night Market deployment setup completed successfully](./assets/img/screenshots/vertex-ai-enabled.png)

### Setup Completed

![Google Cloud Shell terminal confirming successful completion of the Agent Valley Night Market setup](./assets/img/screenshots/setup-complete.png)

"El código fuente completo y los scripts de despliegue se ejecutaron en Google
Cloud Shell a través del repositorio oficial de Agent Valley Night Market."

### Application Running

![Running Agent Valley Night Market application with its conversational interface displayed in a web browser](./assets/img/screenshots/project-created.png)

## Author

Jesús Alberto Dzib Ku

Mérida, Yucatán, México

LinkedIn: [Jesús Alberto Dzib Ku](https://linkedin.com/in/jesusalberto-dzib-ku)

Portfolio: [Portafolio-Alberto](https://github.com/dzib/Portafolio-Alberto)

## Evidencias

## Configuración del entorno

![Google Cloud Shell terminal showing the project environment and setup commands](./assets/img/screenshots/cloudshell.png)

## Setup completado

![Google Cloud setup screen showing configuration progress for the Agent Valley Night Market project](./assets/img/screenshots/setup-complete.png)

## Demonstración

![Agent Valley Night Market demonstration running in a web browser with the conversational interface visible](./assets/img/screenshots/demo.png)
