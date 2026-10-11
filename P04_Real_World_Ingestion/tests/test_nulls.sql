-- QA Test: Nulos Críticos - P4 Supply Chain
-- Objetivo: Comprobar la ausencia de nulos en llaves primarias de operaciones.
SELECT SUM(CASE WHEN Order_Id IS NULL THEN 1 ELSE 0 END) AS NulosOrder_Id
FROM Analytics.SupplyChain_Shipments;