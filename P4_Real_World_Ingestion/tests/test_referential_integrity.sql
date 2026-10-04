-- QA Test: Integridad Referencial - P4 Supply Chain
-- Objetivo: Asegurar consistencia entre la capa Staging y la capa Analytics.
SELECT COUNT(*) AS RegistrosDesalineados
FROM Staging.Kaggle_SupplyChain_Raw s
LEFT JOIN Analytics.SupplyChain_Shipments a ON s.Order_Id = a.Order_Id
WHERE a.Order_Id IS NULL;