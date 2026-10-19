# Reglas de Negocio e Integridad - Módulo P7

* **BRU-01: Validación de Credenciales ADC**
  * Ninguna solicitud hacia los modelos de Vertex AI puede procesarse si el
    entorno no cuenta con las credenciales de autenticación por defecto
    (`Application Default Credentials`) debidamente configuradas.
* **BRU-02: Aislamiento del Proyecto Cloud**
  * Todos los despliegues de agentes y llamadas a APIs deben ejecutarse
    bajo el entorno dedicado del proyecto configurado (`agent-valley-8393`),
    evitando cruces de recursos entre entornos.
* **BRU-03: Restricción de Entornos Virtuales**
  * El aprovisionamiento de dependencias del agente debe gestionarse de
    manera estricta mediante herramientas de alto rendimiento como `uv`
    para asegurar la paridad de versiones en Python.
