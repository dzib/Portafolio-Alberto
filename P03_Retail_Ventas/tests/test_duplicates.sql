-- QA Test: Validación de Reglas de Negocio - P3 Retail
-- Objetivo: Garantizar que no existan montos de venta negativos o ceros en transacciones comerciales.

SELECT COUNT(*) AS ViolacionesReglaNegocio
FROM Ventas.Transacciones
WHERE TotalVenta <= 0;