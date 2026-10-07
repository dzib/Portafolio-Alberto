# Análisis Exploratorio de Datos (EDA) - Fintech Loans BigQuery

## 📌 Objetivo del Notebook

Este documento detalla el análisis exploratorio preliminar realizado sobre el
dataset transaccional de préstamos en Google Cloud BigQuery antes de la
ejecución de las consultas de agregación (`CTAS`).

## 🔍 1. Inspección de Esquema y Volumetría

Se validó la volumetría de la tabla base `fintech.loan` para
 dimensionar el costo de escaneo en BigQuery:

- **Total de registros estimados:** ~1.2 millones de transacciones.
- **Particionamiento sugerido:** Por columna `issue_year` para
  optimizar costos de consulta bajo demanda.

## 📊 2. Estadísticas Descriptivas Clave

```sql
SELECT 
    issue_year,
    COUNT(loan_id) as total_loans,
    ROUND(AVG(loan_amount), 2) as avg_loan_amount,
    ROUND(MAX(loan_amount), 2) as max_loan_amount
FROM 
    `fintech.loan`
GROUP BY 
    issue_year
ORDER BY 
    issue_year DESC;
```

