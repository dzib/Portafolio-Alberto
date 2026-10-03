# 🛠️ Componentes Técnicos y Diagrama de Arquitectura

Este documento describe los componentes de bajo nivel, librerías y
 dependencias del sistema.

## 📦 Stack Tecnológico y Librerías

- **Núcleo de Datos:** SQL Server 2025 y Google Cloud BigQuery.
- **Procesamiento:** Python 3.13 (`pandas`, `sqlalchemy`, `pyodbc`).
- **Pruebas y Calidad:** `pytest` para validación de esquemas.
- **Visualización:** Power BI y PyGWalker.

## 📊 Diagrama de Componentes (Mermaid)

```mermaid
graph TD
    A[Python Scripts / Pandas] -->|ODBC / SQLAlchemy| B[(SQL Server 2025)]
    C[Kaggle / Faker Datasets] --> A
    B --> D[PyTest Data Quality]
    B --> E[Power BI / PyGWalker]
    F[Apache Airflow] --> A
    
    style A fill:#34A853,color:#fff
    style B fill:#0078D4,color:#fff
    style D fill:#FF6D00,color:#fff
    style E fill:#F2C811,color:#000
    style F fill:#00acee,color:#fff
