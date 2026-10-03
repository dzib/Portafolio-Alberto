# 💡 Lecciones Aprendidas (Lessons Learned)

A lo largo del diseño, desarrollo y auditoría del portafolio de ingeniería de
datos, se han recopilado aprendizajes críticos orientados a la resiliencia y
eficiencia operativa:

## ✅ Qué Funcionó

- **Arquitectura Híbrida (Python + SQL):** Combinar la velocidad de
 procesamiento de Pandas con la robustez transaccional de SQL Server 2025
 permitió optimizar drásticamente el rendimiento de I/O, alcanzando picos récord
  de 23.8k registros por segundo.
- **Automatización de Auditorías:** Implementar scripts en Python
 (`audit_portfolio.py`) para el rastreo y validación global de hipervínculos
 garantizó un estándar de **0 enlaces rotos** de forma permanente.
- **Control de Versiones Estructurado:** El uso disciplinado de *Git Flow*
 (`feature` -> `develop` -> `main`) evitó colisiones de código y mantuvo
 limpio el historial de cambios.

## 📈 Qué Mejoraría

- **Contenerización Temprana:** Integrar contenedores Docker desde los primeros
 sprints para aislar los entornos de ejecución y simplificar la portabilidad
 de las dependencias locales.
- **Validación de Esquemas en la Nube:** Ampliar las pruebas unitarias
 automáticas con `pytest` para abarcar de forma nativa la validación de tipos
 de datos en los pipelines ejecutados sobre Google Cloud BigQuery.

## ⚠️ Riesgos Identificados

- **Dependencia de Infraestructura Local:** La ejecución de bases de datos
 pesadas en estaciones de trabajo locales requiere planes de recuperación
 ante desastres (Recovery & Reset) para mitigar fallos críticos de hardware o
 sistema operativo.
- **Evolución de Metadatos:** Los cambios imprevistos en la estructura de
 archivos fuente (CSV/Excel crudos) pueden romper contratos de datos si no se
 implementan validaciones estrictas de nulos y tipos (*Single-Pass
 Processing*).

## 🚀 Próximas Iteraciones

- Despliegue completo de contenedores Docker para la orquestación integral de
 los servicios de bases de datos y scripts de Python.
- Conexión avanzada de los flujos analíticos hacia Power BI utilizando el modo
 *DirectQuery* para visualización en tiempo real.

