-- ==============================================================================
-- Proyecto: Análisis de Préstamos Financieros en Google Cloud BigQuery
-- Tarea: Crear una tabla agregada con el total de préstamos por año
-- Metodología: CTAS (Create Table As Select)
-- ==============================================================================

-- Motor: Google Cloud BigQuery (Standard SQL)
DROP TABLE IF EXISTS fintech.loan_count_by_year;

CREATE TABLE fintech.loan_count_by_year (
    issue_year INT64,
    total_loans INT64
);

INSERT INTO fintech.loan_count_by_year (issue_year, total_loans)
SELECT 
    issue_year,
    COUNT(loan_id) AS total_loans
FROM 
    fintech.loan
GROUP BY 
    issue_year;