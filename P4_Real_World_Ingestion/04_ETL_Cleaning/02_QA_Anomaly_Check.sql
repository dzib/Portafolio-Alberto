/*
================================================================================================
FASE: QA y Medición de Éxito (Verificación Matemática)
================================================================================================
*/
USE P4_Global_SupplyChain;
GO

SELECT 
    Is_Anomaly,
    COUNT(*) AS Total_Orders,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS Porcentaje_Distribucion,
    SUM(Sales_per_customer) AS Total_Sales_Volume,
    SUM(Benefit_per_order) AS Total_Benefit_Impact
FROM Analytics.SupplyChain_Shipments
GROUP BY Is_Anomaly
ORDER BY Is_Anomaly DESC;