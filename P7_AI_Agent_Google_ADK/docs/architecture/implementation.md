# Implementation Journey

## Overview

This project demonstrates the implementation of a real-time conversational AI agent using Google Agent Development Kit (ADK), Vertex AI, and Gemini Live.

---

## Environment Setup

### Development Environment

- Google Cloud Shell
- Python 3.12
- Google Agent Development Kit (ADK)
- Vertex AI
- Gemini Live
- FastAPI

---

## Project Creation

A dedicated Google Cloud project was created.

Project ID:

```text
agent-valley-8393
```

The project was automatically configured using:

```bash
./setup_project.sh
```

---

## Services Enabled

The setup process enabled the required Google Cloud services:

- Vertex AI API
- AI Platform API
- Google Authentication Services

Verification:

```text
aiplatform.googleapis.com enabled
```

---

## Authentication

The project required configuring Google Cloud authentication and Application Default Credentials (ADC).

Main commands used:

```bash
gcloud auth login
```

```bash
gcloud auth application-default login
```

---

## Python Environment

A virtual environment was created automatically.

Key packages installed:

- google-adk
- google-genai
- fastapi
- uvicorn

---

## Agent Configuration

The project uses:

```text
Gemini Live 2.5 Flash Native Audio
```

to provide real-time conversational interaction.

Validation output:

```text
the line opens
gemini-live-2.5-flash-native-audio
```

---

## Application Execution

The project is launched through:

```bash
bash valley.sh
```

Application endpoints:

```text
http://localhost:3450
```

```text
http://localhost:3450/workbench/dev-ui/?app=stage
```

---

## Challenges Encountered

### Authentication Issue

Error:

```text
RefreshError:
service account info is missing 'email' field
```

Resolution:

- Configured Application Default Credentials.
- Verified project configuration.
- Re-ran setup successfully.

---

## Outcome

Successfully implemented and validated:

- Google ADK
- Vertex AI
- Gemini Live
- FastAPI Integration
- Cloud Shell Workflow

Result:

✅ Conversational AI Agent running successfully.