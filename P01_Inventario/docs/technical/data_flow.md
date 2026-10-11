# Flujo de Datos (Data Flow Architecture) - P1

```mermaid
graph TD
    A[Generación de Datos Legacy / Seed] -->|Datos con Pipe| B[(SQL Server
    2025: Tablas Crudas)]
    B -->|Script 04: Single-Pass Processing| C[Normalización de Cadenas y
    Data Grooming]
    C -->|Persistencia Física Atómica| D[(Tablas Limpias y
    Tipadas)]
    D -->|Script 05: Vistas SQL| E[Esquema Analytics:
    vw_ReporteGlobalVentas]
    E -->|Puente ODBC / Power Query| F[Dashboard Ejecutivo
    en Excel]
