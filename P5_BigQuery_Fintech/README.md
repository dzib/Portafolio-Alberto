# Portafolio: Análisis y Agregación de Datos en BigQuery

## 📌 Contexto del Proyecto

Este proyecto demuestra habilidades prácticas en **Google Cloud BigQuery**
para el procesamiento de datos financieros. A partir de una base de datos transaccional
de préstamos (dataset `fintech`), se requería optimizar las consultas analíticas
futuras.

## 🎯 El Desafío

El objetivo principal fue evitar el escaneo repetitivo de datos a nivel
granular mediante la creación de una tabla agregada. Utilizando la declaración
`CTAS` (Create Table As Select), se generó un resumen eficiente que contabiliza
la cantidad total de préstamos emitidos agrupados por año (`issue_year`).

## 💻 Solución SQL

El siguiente código crea y puebla la tabla en un solo paso:

```sql
CREATE TABLE fintech.loan_count_by_year AS
SELECT 
    issue_year, 
    COUNT(loan_id) AS total_loans
FROM 
    fintech.loan
GROUP BY 
    issue_year;
```

## 📊 Resultados y Esquema

La ejecución exitosa aprovisionó la tabla `loan_count_by_year` con el
siguiente esquema:

* `issue_year` (**NUMERIC**): Año de emisión.
* `total_loans` (**INTEGER**): Cantidad total de préstamos.

Puedes consultar las evidencias visuales (capturas de la consola de GCP y el
esquema resultante) en el documento PDF adjunto a este repositorio.
