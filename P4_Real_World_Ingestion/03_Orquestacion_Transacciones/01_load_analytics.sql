/* 
==================================================================================================================
PROYECTO: P4_Real_World_Ingestion - Global Supply Chain Analytics (Kaggle Dataset)
FASE: 4.3 (SQL) - Orquestación Transaccional y Carga a Analytics
AUTOR: Alberto Dzib
VERSIÓN: 1.1 (Optimizado para separación de lotes)
===================================================================================================================
*/

USE P4_Global_SupplyChain;
GO

-- LOTE 1: Creación idempotente de la tabla final en Analytics
IF OBJECT_ID('Analytics.SupplyChain_Shipments', 'U') IS NOT NULL 
    DROP TABLE Analytics.SupplyChain_Shipments;
GO

CREATE TABLE Analytics.SupplyChain_Shipments (
    ShipmentID INT IDENTITY(1,1) PRIMARY KEY,
    Type NVARCHAR(50),
    Delivery_Status NVARCHAR(100),
    Late_delivery_risk INT,
    Category_Name NVARCHAR(200),
    Customer_City NVARCHAR(200),
    Order_Region NVARCHAR(200),
    Order_Date DATETIME2,
    Total_Sales DECIMAL(18,4),
    Profit DECIMAL(18,4),
    LoadDate DATETIME2 DEFAULT GETDATE()
);
GO

-- LOTE 2: Carga Transaccional Atómica y Registro en Logs
DECLARE @StartTime DATETIME2 = SYSUTCDATETIME();
DECLARE @RowsAffected INT = 0;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Analytics.SupplyChain_Shipments (
        Type, 
        Delivery_Status, 
        Late_delivery_risk, 
        Category_Name, 
        Customer_City, 
        Order_Region, 
        Order_Date, 
        Total_Sales, 
        Profit
    )
    SELECT 
        Type, 
        Delivery_Status, 
        Late_delivery_risk, 
        Category_Name,
        Customer_City, 
        Order_Region, 
        TRY_CAST(Order_Date_Raw AS DATETIME2),
        Order_Item_Total,
        Benefit_per_order
    FROM Staging.Kaggle_SupplyChain_Raw;

    SET @RowsAffected = @@ROWCOUNT;

    INSERT INTO Staging.Execution_Logs (PhaseName, RowsAffected, ExecutionTime_MS, Status)
    VALUES ('Fase 4.3: Load Analytics', @RowsAffected, DATEDIFF(MS, @StartTime, SYSUTCDATETIME()), 'SUCCESS');

    COMMIT TRANSACTION;
    PRINT '✅ Transacción completada: ' + CAST(@RowsAffected AS VARCHAR) + ' registros movidos a Analytics.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

    INSERT INTO Staging.Execution_Logs (PhaseName, RowsAffected, ExecutionTime_MS, Status, ErrorMsg)
    VALUES ('Fase 4.3: Load Analytics', 0, DATEDIFF(MS, @StartTime, SYSUTCDATETIME()), 'ERROR', ERROR_MESSAGE());

    PRINT '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!';
    PRINT '❌ Error en la transacción. Se realizó ROLLBACK.';
    PRINT '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!';
    THROW;
END CATCH
GO