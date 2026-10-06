# Componentes del Sistema - P2 Escolar

- **Motor transaccional:** SQL Server 2025. Esquemas `Catalogos` para
  entidades maestras como Departamentos y Carreras, y `Operaciones` para
  Alumnos e Inscripciones.
- **Capa de transformación (ETL):** Procedimientos T-SQL optimizados con
  CTEs para extracción atómica en una sola pasada.
- **Capa analítica y reportes:** Vistas de negocio y lógica ejecutiva para
  correlacionar rendimiento académico y eficiencia presupuestaria por
  facultad.
- **Entorno de pruebas:** Stress testing con inyección masiva de registros
  y blindaje proactivo contra nulos y desbordamientos numéricos.

