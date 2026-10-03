PRINT 'QA-002 DUPLICATE VALIDATION';

SELECT
    ProductoID,
    COUNT(*) AS Total
FROM Inventario.Productos
GROUP BY ProductoID
HAVING COUNT(*) > 1;