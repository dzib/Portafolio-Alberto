# Flujo de Datos (Data Flow Architecture)

1. **Orgien (Raw):** Ingesta masiva en `fintech.loan`.
2. **Transformación & Agregación:** Ejecución de lógica CTAS con agrupamiento temporal.
3. **Destino (Serving):** Tabla optimizada
`fintech.loan_count_by_year` lista para consumo analítico.
