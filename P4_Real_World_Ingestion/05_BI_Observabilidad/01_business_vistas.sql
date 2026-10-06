/* 
======================================================================================================================================
PROYECTO: P4_Real_World_Ingestion
FASE: 4.5 (SQL) - Vistas Analíticas para Toma de Decisiones
AUTOR: Alberto Dzib
ESTÁNDAR: Dzib V13.0 (Resiliencia y Atomicidad)
DESCRIPCIÓN: 
    - Segmentación al esquema BI (Single Source of Truth para Power BI).
    - KPI_Shipping_Efficiency: Tasa de éxito de entregas por región.
    - KPI_Profit_Risk: Análisis de rentabilidad vs riesgo de entrega.
======================================================================================================================================
*/

USE P4_Global_SupplyChain;
GO

-- 0. SEGMENTACIÓN DE ESQUEMA (Obligatorio en V13.0)
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'BI')
BEGIN
    EXEC('CREATE SCHEMA BI');
    PRINT '✅ Esquema BI creado exitosamente.';
END
GO

-- -----------------------------------------------------------------------------------------------------------------------------
-- 1. Vista de Eficiencia Logística por Región
-- -----------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER VIEW BI.vw_Shipping_Efficiency AS
SELECT 
    Order_Region,
    Delivery_Status,
    COUNT(*) AS Total_Orders,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY Order_Region) AS DECIMAL(10,2)) AS Percentage
FROM Analytics.SupplyChain_Shipments
WHERE Is_Anomaly = 0
GROUP BY Order_Region, Delivery_Status;
GO

-- -----------------------------------------------------------------------------------------------------------------------------
-- 2. Vista de Rentabilidad por Categoría
-- -----------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER VIEW BI.vw_Category_Performance AS
SELECT 
    Category_Name,
    SUM(Sales_per_customer) AS Total_Revenue,
    SUM(Benefit_per_order) AS Total_Profit,
    -- Blindaje contra división por cero usando NULLIF
    CAST((SUM(Benefit_per_order) / NULLIF(SUM(Sales_per_customer), 0)) * 100 AS DECIMAL(10,2)) AS Profit_Margin_Pct
FROM Analytics.SupplyChain_Shipments
WHERE Is_Anomaly = 0
GROUP BY Category_Name;
GO

PRINT '==================================================================';
PRINT '✅ Vistas analíticas desplegadas exitosamente en el esquema BI.';
PRINT '==================================================================';