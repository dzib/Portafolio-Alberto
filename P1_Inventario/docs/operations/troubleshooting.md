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
  - *Solución:*
    - *Validar que se esté utilizando el *ODBC Driver 17
    for SQL Server* o superior y que el servidor apunte a la
    instancia local correcta.*

- **Incidencia 3: Error FK Constraint**

  - *Causa:* Inserción de registros huérfanos.
  - *Solución:*
    1. Ejecutar `04_ETL_Limpieza.sql` para eliminar registros huérfanos.
    2. Validar integridad referencial con `DBCC CHECKCONSTRAINTS`.
    3. Validar orden de carga.

  - *Nota:* Asegurarse de que los datos se carguen en el orden correcto.

- **Incidencia 4: Error ODBC**

  - *Causa:* DSN incorrecto o cadena de conexión mal formada.
  - *Solución:*
    1. Verificar que el controlador ODBC esté correctamente instalado.
    2. Validar que el DSN esté configurado correctamente.
    3. Comprobar la cadena de conexión.

  - *Nota:* Verificar Driver 17 y cadena de conexión.

- **Incidencia 5: Error de Duplicados**

  - *Causa:* Carga repetida no controlada.
  - *Solución:* Ejecutar reinicialización completa.

