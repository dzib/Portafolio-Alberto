# 🤖 P8_AI_Copilot_BI — Copilot Analítico Local con IA

## Python + Ollama

> *"Automatiza la ingesta, el cálculo de KPIs y la generación de
> insights ejecutivos mediante un agente local basado en LLM (Llama 3.2),
> asegurando costo cero y privacidad total de los datos."*

---

## 📋 Resumen Ejecutivo (Método STAR)

- **Situación:** Los equipos directivos y analíticos pierden horas valiosas
    transformando datos crudos de ventas en reportes ejecutivos e interpretando
    tendencias de forma manual.
- **Tarea:** Diseñar y desplegar un Agente de Inteligencia Artificial local y
    autónomo capaz de ingerir datasets, calcular indicadores clave de
    rendimiento (KPIs) y redactar análisis de negocio estructurados sin depender
    de APIs de pago.
- **Acción:** Se desarrolló una arquitectura modular en Python integrando un
    motor ETL, procesamiento analítico con Pandas y un conector inteligente con
    **Ollama** (`llama3.2`) operando en un entorno local seguro.
- **Resultado:** Un sistema automatizado de extremo a extremo que reduce el
    tiempo de análisis exploratorio a segundos y genera reportes listos para la
    toma de decisiones gerenciales.

---

## 🎯 Objetivo del Proyecto

Construir una solución de **AI Data Analyst** desacoplada que combine la
potencia de la automatización analítica con grandes modelos de lenguaje
locales, cumpliendo con los más altos estándares de gobernanza, atomicidad y
reutilización de código.

```mermaid
graph TD
    subgraph "Fase 01: Ingesta y ETL"
        A[Dataset Crudo: ventas.csv] -->|Pandas / Validación| B[Dataframe Limpio]
    end
    
    subgraph "Fase 02: Analítica y KPIs"
        B -->|Agregaciones y Estadísticos| C[Diccionario de KPIs]
    end
    
    subgraph "Fase 03: Agente de IA Local"
        C -->|Prompt Estructurado + System Prompt| D[Ollama: Llama 3.2]
        D -->|Razonamiento Ejecutivo| E[Reporte Gerencial Consolidado]
    end
    
    style A fill:#f9f,stroke:#333,stroke-width:2px
    style C fill:#bbf,stroke:#333,stroke-width:2px
    style E fill:#dfd,stroke:#333,stroke-width:4px

🏗️ Estructura Completa del Repositorio (Modular)
Plaintext
P8_AI_Copilot_BI/
│
├── architecture/          # Diagramas conceptuales y físicos
├── data/                  # Datasets de trabajo y muestras
├── docs/                  # Documentación técnica y de negocio
│   ├── decisions/         # ADRs (Architecture Decision Records)
│   ├── functional/        # Requerimientos de negocio
│   ├── operations/        # Guías de despliegue y uso
│   └── technical/         # Especificaciones de componentes
├── reports/               # Reportes ejecutivos generados por el agente
├── src/                   # Código fuente modular
│   ├── agent.py           # Conector y lógica con Ollama
│   ├── analytics.py       # Motor de cálculo de KPIs
│   ├── config.py          # Configuración de entorno y rutas
│   ├── etl.py             # Pipeline de carga y limpieza
│   ├── main.py            # Orquestador maestro
│   └── report_generator.py# Exportador de documentos
├── tests/                 # Pruebas unitarias e integración
├── README.md              # Documentación principal del módulo
└── requirements.txt       # Dependencias del proyecto
🛠️ Stack Tecnológico
Lenguaje: Python 3.10+

Procesamiento de Datos: Pandas

Inteligencia Artificial Local: Ollama (Llama 3.2)

Control de Versiones: Git / Git Flow

🚀 Cómo Ejecutar el Pipeline
Asegúrate de tener instalado y corriendo Ollama en tu equipo con el modelo base:

PowerShell
ollama pull llama3.2
Instala las dependencias del proyecto:

PowerShell
pip install -r requirements.txt
Ejecuta el orquestador principal:

PowerShell
python src/main.py
Autor: Jesús Alberto Dzib Ku

Versión: 1.0.0
