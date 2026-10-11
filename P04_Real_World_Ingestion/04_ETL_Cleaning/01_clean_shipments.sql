/*
================================================================================================
PROYECTO: P4_Real_World_Ingestion - Global Supply Chain Analytics
FASE: 4.4 (SQL) - ETL Atómico y Single-Pass Processing
AUTOR: Alberto Dzib
ESTÁNDAR: Dzib V13.0 (Resiliencia y Atomicidad)
DESCRIPCIÓN:
    - Creación Idempotente y Destructiva de la tabla destino Analytics.
    - Single-Pass Processing usando CTE para transformaciones en vuelo.
    - TRY...CATCH con ROLLBACK para evitar corrupción de datos.
================================================================================================
*/
USE P4_Global_SupplyChain;
GO

-- 1. PREPARACIÓN IDEMPOTENTE (DESTRUCTIVA) DEL DESTINO
IF OBJECT_ID('Analytics.SupplyChain_Shipments', 'U') IS NOT NULL 
BEGIN
    DROP TABLE Analytics.SupplyChain_Shipments;
    PRINT '🧹 Tabla anterior eliminada para forzar nuevo esquema.';
END
GO

CREATE TABLE Analytics.SupplyChain_Shipments (
    ShipmentID INT IDENTITY(1,1) PRIMARY KEY,
    [Type] NVARCHAR(50),
    Days_for_shipping_real INT,
    Days_for_shipment_scheduled INT,
    Benefit_per_order DECIMAL(18,4),
    Sales_per_customer DECIMAL(18,4),
    Delivery_Status NVARCHAR(100),
    Late_delivery_risk INT,
    Category_ID INT,
    Category_Name NVARCHAR(200),
    Customer_City NVARCHAR(200),
    Customer_Country NVARCHAR(200),
    Order_Region NVARCHAR(200),
    Order_Item_Total DECIMAL(18,4),
    Is_Anomaly BIT NOT NULL DEFAULT(0), -- Blindaje contra nulos desde la raíz
    Processed_Date DATETIME2 DEFAULT GETDATE()
);
GO

-- 2. INICIO DE TRANSACCIÓN ATÓMICA
DECLARE @StartTime DATETIME2 = SYSUTCDATETIME();
DECLARE @RowsAffected INT = 0;
DECLARE @ExecGUID UNIQUEIDENTIFIER = NEWID();

BEGIN TRY
    BEGIN TRAN;

    -- 3. SINGLE-PASS PROCESSING (CTE)
    WITH CleansedData AS (
        SELECT 
            [Type],
            Days_for_shipping_real,
            Days_for_shipment_scheduled,
            Benefit_per_order,
            Sales_per_customer,
            
            -- Normalización de Status y Riesgo
            CASE 
                WHEN Late_delivery_risk = 1 AND UPPER(TRIM(Delivery_Status)) = 'LATE DELIVERY' 
                THEN 'LATE DELIVERY (VERIFIED)'
                ELSE UPPER(TRIM(Delivery_Status))
            END AS Delivery_Status,
            
            Late_delivery_risk,
            Category_ID,
            UPPER(TRIM(Category_Name)) AS Category_Name,
            UPPER(TRIM(Customer_City)) AS Customer_City,
            Customer_Country,
            UPPER(TRIM(Order_Region)) AS Order_Region,
            Order_Item_Total,
            
            -- Lógica Financiera de Anomalías (Todo en una sola pasada)
            CAST(
                CASE 
                    WHEN Sales_per_customer <= 0 OR Benefit_per_order < (Sales_per_customer * -1.0) THEN 1
                    ELSE 0 
                END AS BIT
            ) AS Is_Anomaly
        FROM Staging.Kaggle_SupplyChain_Raw
    )
    -- 4. INSERCIÓN FÍSICA A LA CAPA DE ANALYTICS
    INSERT INTO Analytics.SupplyChain_Shipments (
        [Type], Days_for_shipping_real, Days_for_shipment_scheduled, Benefit_per_order, 
        Sales_per_customer, Delivery_Status, Late_delivery_risk, Category_ID, 
        Category_Name, Customer_City, Customer_Country, Order_Region, Order_Item_Total, Is_Anomaly
    )
    SELECT 
        [Type], Days_for_shipping_real, Days_for_shipment_scheduled, Benefit_per_order, 
        Sales_per_customer, Delivery_Status, Late_delivery_risk, Category_ID, 
        Category_Name, Customer_City, Customer_Country, Order_Region, Order_Item_Total, Is_Anomaly
    FROM CleansedData;

    SET @RowsAffected = @@ROWCOUNT;

    COMMIT TRAN;

    -- 5. LOG DE ÉXITO
    INSERT INTO Staging.Execution_Logs (PhaseName, RowsAffected, ExecutionTime_MS, Status, ExecutionGUID, ServerName, DatabaseName)
    VALUES ('FASE 4.4 ETL ATÓMICO', @RowsAffected, DATEDIFF(MILLISECOND, @StartTime, SYSUTCDATETIME()), 'SUCCESS', @ExecGUID, @@SERVERNAME, DB_NAME());

    PRINT '================================================================';
    PRINT '✅ FASE 4.4 COMPLETADA CON ÉXITO (SINGLE-PASS)';
    PRINT 'Filas transferidas a Analytics: ' + CAST(@RowsAffected AS VARCHAR(20));
    PRINT 'Tiempo (MS): ' + CAST(DATEDIFF(MILLISECOND, @StartTime, SYSUTCDATETIME()) AS VARCHAR(20));
    PRINT '================================================================';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;

    -- LOG DE ERROR
    INSERT INTO Staging.Execution_Logs (PhaseName, RowsAffected, ExecutionTime_MS, Status, ErrorMsg, ExecutionGUID, ServerName, DatabaseName)
    VALUES ('FASE 4.4 ETL ATÓMICO', 0, DATEDIFF(MILLISECOND, @StartTime, SYSUTCDATETIME()), 'ERROR', ERROR_MESSAGE(), @ExecGUID, @@SERVERNAME, DB_NAME());

    PRINT '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!';
    PRINT '❌ ERROR ETL - SE EJECUTÓ ROLLBACK';
    PRINT ERROR_MESSAGE();
    PRINT '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!';
    THROW;
END CATCH;
GO