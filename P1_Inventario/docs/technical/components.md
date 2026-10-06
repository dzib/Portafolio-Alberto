# Guía de Resolución de Problemas (Troubleshooting) - P1

- **Incidencia 1: Error de Tipo de Datos al extraer pipes (`|`).**
  - *Causa:* Registros legacy donde el delimitador está ausente o
    mal formado, provocando que `CHARINDEX` devuelva `0`.
  - *Solución:* Asegurarse de validar las cláusulas
    `WHERE Nombre LIKE '%|%'` antes de aplicar funciones de
    subcadena.
- **Incidencia 2: Falla de Conexión ODBC en Excel.**
  - *Causa:* Versión del controlador ODBC desactualizada o DSN de
    sistema mal apuntado.
  - *Solución:* Validar que se esté utilizando el *ODBC Driver 17
    for SQL Server* o superior y que el servidor apunte a la
    instancia local correcta.
