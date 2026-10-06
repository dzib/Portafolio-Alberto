PRINT 'QA-001 NULL VALIDATION';

SELECT
    'Productos' AS Tabla,
    COUNT(*) AS RegistrosConNulos
FROM Inventario.Productos
WHERE NombreProducto IS NULL
   OR Categoria IS NULL;