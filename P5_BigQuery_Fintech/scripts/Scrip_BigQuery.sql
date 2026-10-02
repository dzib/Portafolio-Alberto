-- ==============================================================================
-- Proyecto: Análisis de Préstamos Financieros en Google Cloud BigQuery
-- Tarea: Crear una tabla agregada con el total de préstamos por año
-- Metodología: CTAS (Create Table As Select)
-- ==============================================================================

-- Motor: Google Cloud BigQuery (Standard SQL)
CREATE OR REPLACE TABLE `fintech.loan_count_by_year` AS
SELECT 
    issue_year,
    COUNT(loan_id) AS total_loans
FROM 
    fintech.loan
GROUP BY 
    issue_year;