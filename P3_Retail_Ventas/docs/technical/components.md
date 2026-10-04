# 🧩 Componentes del Módulo - P3_Retail_Ventas

## Dataset

Ventas_Retail_Masivo.csv

Descripción:
Dataset de 50,000 transacciones simuladas.


- **01_GeneradorDatos.py**: Script en Python para la creación masiva y sintética
 de 50,000 transacciones utilizando semillas de reproducibilidad (`Faker`).

---

- **02_CargaSQL.py**: Módulo de ingesta optimizado mediante SQLAlchemy y
 `fast_executemany` para alcanzar ~27k registros/segundo hacia SQL Server.

## Scripts

generate_dataset.py

Descripción:
Genera los datos de ejemplo.

- **Scripts SQL (01 al 03)**: Capa de persistencia, normalización y
 transformación ETL mediante CTEs y optimización de esquemas.

- **03_Analitica_Ventas.py**: Motor analítico en Python para la lectura y
 visualización de KPIs de negocio en consola con respuesta sub-segundo.


---

## Dashboard

Dashboard Power BI

Descripción:
Visualización de KPIs comerciales.
