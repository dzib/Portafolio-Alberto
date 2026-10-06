# 📂 Estándar de Estructura de Directorios (Dzib Standard V2.3.0)

Este repositorio sigue una arquitectura estrictamente modular para garantizar
la reproducibilidad, separación de responsabilidades y mantenibilidad de los
pipelines de datos.

## Estructura General

- **`docs/`**: Documentación técnica, arquitectura, decisiones (ADRs) y
  estándares transversales.

- **`tools/`**: Scripts de automatización, auditoría de enlaces
  (`audit_portfolio.py`) y control de calidad.

- **`tests/`**: Pruebas unitarias automatizadas globales (`pytest`) para
  validar la integridad de los datos.

- **`P1_Inventario` a `P7_AI_Agent_Google_ADK`**: Módulos independientes que
  contienen sus propios scripts, datos de ejemplo e imágenes de evidencia.
