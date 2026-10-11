# Componentes del Sistema - P2 Escolar

- **Motor Transaccional:** SQL Server 2025. Esquemas
  `Catalogos` para entidades maestras como Departamentos y
  Carreras, y `Operaciones` para Alumnos e Inscripciones.
- **Capa de Transformación (ETL):** Procedimientos T-SQL
  optimizados con Common Table Expressions (CTEs) para
  extracción atómica en una sola pasada.
- **Capa Analítica & Reportes:** Vistas de negocio y lógica
  ejecutiva para correlacionar rendimiento académico y
  eficiencia presupuestaria por facultad.
- **Entorno de Pruebas:** Stress testing con inyección masiva
  de registros y blindaje proactivo contra nulos y
  desbordamientos numéricos.
