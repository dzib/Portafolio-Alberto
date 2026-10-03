PRINT 'QA-003 BUSINESS RULES';

SELECT *
FROM Inventario.Productos
WHERE Precio <= 0;

SELECT *
FROM Inventario.Productos
WHERE StockActual < 0;
