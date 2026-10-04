-- QA Test: Reglas de Negocio - P4 Supply Chain
-- Objetivo: Verificar que no existan ganancias con valores nulos tras la limpieza ETL.
SELECT COUNT(*) AS OrdenesConErrorFinanciero
FROM Analytics.SupplyChain_Shipments
WHERE Order_Profit_Per_Order IS NULL;