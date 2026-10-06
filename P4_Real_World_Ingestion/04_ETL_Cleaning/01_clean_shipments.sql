/*
==================================================================================================================================
PROYECTO: P4_Real_World_Ingestion - Global Supply Chain Analytics (Kaggle Dataset)
FASE: 4.4 (SQL) - ETL y Normalización de Datos Crudos
AUTOR: Alberto Dzib
VERSIÓN: 2.0
DESCRIPCIÓN:
    - Estandarización de cadenas (TRIM / UPPER)
    - Enriquecimiento de reglas de negocio
    - Auditoría financiera
    - Registro real de filas afectadas
    - Integración con Execution_Logs
==================================================================================================================================
*/

USE P4_Global_SupplyChain;
GO

IF COL_LENGTH(
'Analytics.SupplyChain_Shipments',
'Is_Anomaly'
) IS NULL
BEGIN
 
ALTER TABLE Analytics.SupplyChain_Shipments
 
ADD Is_Anomaly BIT
CONSTRAINT DF_Is_Anomaly DEFAULT(0);
 
END
GO

DECLARE @StartTime DATETIME2 = SYSUTCDATETIME();

DECLARE @RowsAffected INT = 0;

BEGIN TRY

    -------------------------------------------------------------------------------------
    -- 1. LIMPIEZA DE TEXTO
    -------------------------------------------------------------------------------------

    UPDATE Analytics.SupplyChain_Shipments
    SET
        Customer_City   = UPPER(TRIM(Customer_City)),
        Order_Region    = UPPER(TRIM(Order_Region)),
        Category_Name   = UPPER(TRIM(Category_Name)),
        Delivery_Status = UPPER(TRIM(Delivery_Status));

    SET @RowsAffected += @@ROWCOUNT;


    -------------------------------------------------------------------------------------
    -- 2. NORMALIZACIÓN DE RIESGO
    -------------------------------------------------------------------------------------

    UPDATE Analytics.SupplyChain_Shipments
    SET Delivery_Status = 'LATE DELIVERY (VERIFIED)'
    WHERE Late_delivery_risk = 1
      AND Delivery_Status = 'LATE DELIVERY';

    SET @RowsAffected += @@ROWCOUNT;


    -------------------------------------------------------------------------------------
    -- 3. AUDITORÍA FINANCIERA
    -------------------------------------------------------------------------------------

    IF NOT EXISTS (
        SELECT 1
        FROM sys.columns
        WHERE object_id = OBJECT_ID('Analytics.SupplyChain_Shipments')
        AND name = 'Is_Anomaly'
    )
    BEGIN

        ALTER TABLE Analytics.SupplyChain_Shipments
        ADD Is_Anomaly BIT
        CONSTRAINT DF_Is_Anomaly DEFAULT(0);

    END

    EXEC sp_executesql N'
        UPDATE Analytics.SupplyChain_Shipments
        SET Is_Anomaly = 1
        WHERE Total_Sales <= 0
           OR Profit < (Total_Sales * -1);
    ';

    SET @RowsAffected += @@ROWCOUNT;


    -------------------------------------------------------------------------------------
    -- 4. REGISTRO DE AUDITORÍA
    -------------------------------------------------------------------------------------

    INSERT INTO Staging.Execution_Logs
    (
    PhaseName,
    RowsAffected,
    ExecutionTime_MS,
    Status
    )
    VALUES
    (
    'FASE 4.4 ETL CLEANING',
    @RowsAffected,
    DATEDIFF(MILLISECOND,@StartTime,SYSUTCDATETIME()),
    'SUCCESS'
    );

    PRINT '================================================================';
    PRINT '✅ ETL completado exitosamente';
    PRINT 'Filas procesadas: ' + CAST(@RowsAffected AS VARCHAR(20));
    PRINT '================================================================';

END TRY

BEGIN CATCH

    INSERT INTO Staging.Execution_Logs
    (
        PhaseName,
        RowsAffected,
        ExecutionTime_MS,
        Status,
        ErrorMsg
    )
    VALUES
    (
        'FASE 4.4 ETL CLEANING',
        0,
        DATEDIFF(MILLISECOND,@StartTime,SYSUTCDATETIME()),
        'ERROR',
        ERROR_MESSAGE()
    );

    PRINT '==================================================';
    PRINT '❌ ERROR ETL';
    PRINT ERROR_MESSAGE();
    PRINT '==================================================';

    THROW;

END CATCH;
GO