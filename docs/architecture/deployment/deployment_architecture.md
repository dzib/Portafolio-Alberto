# 🚀 Arquitectura de Despliegue y Ciclo de Vida (CI/CD)

Este documento define los niveles de madurez y los entornos por los que
 pasa el código antes de consolidarse en producción.

## 🔄 Niveles de Entorno

1. **DEV (Desarrollo):**
   - Entorno local en la rama `feature/*` y `develop`.
   - Ejecución de scripts de prueba y validación de sintaxis T-SQL.
   - Pruebas unitarias locales con `pytest`.
2. **QA (Calidad):**
   - Validación automatizada mediante workflows de **GitHub Actions**
     (`ci.yml`).
   - Verificación de la integridad de los enlaces del portafolio mediante
     el script de auditoría (`audit_portfolio.py`).
3. **PROD (Simulado / Producción):**
   - Consolidación del código en la rama principal `main`.
   - Repositorio listo para presentación ejecutiva y consumo público,
     con métricas de performance validadas.
