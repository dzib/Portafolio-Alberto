-- QA Test: Duplicados - P4 Supply Chain
-- Objetivo: Validar la unicidad de las órdenes procesadas desde el dataset de origen.
SELECT Order_Id, COUNT(*) AS TotalDuplicados
FROM Analytics.SupplyChain_Shipments
GROUP BY Order_Id
HAVING COUNT(*) > 1;