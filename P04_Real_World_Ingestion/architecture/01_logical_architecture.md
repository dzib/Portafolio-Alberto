# Arquitectura Lógica - P4 Supply Chain

- **Capa de Staging (`Staging`):** Destino inicial de los 180,519 registros
 crudos ingestados mediante el script de Python con SQLAlchemy y `fast_executemany`.
- **Capa de Transformación (`Analytics`):** Procesamiento atómico mediante
 transacciones con bloques `BEGIN TRY...CATCH` y T-SQL Dinámico (`sp_executesql`).
