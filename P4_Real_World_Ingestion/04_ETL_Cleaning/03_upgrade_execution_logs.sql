/* 
================================================================================================
PROYECTO: P4_Real_World_Ingestion 
FASE: 4.3 (SQL) - Upgrade de Auditoría Logística
================================================================================================
*/
USE P4_Global_SupplyChain;
GO

PRINT 'Iniciando Upgrade de Execution_Logs...';

IF COL_LENGTH('Staging.Execution_Logs', 'ExecutionGUID') IS NULL
    ALTER TABLE Staging.Execution_Logs ADD ExecutionGUID UNIQUEIDENTIFIER DEFAULT NEWID();

IF COL_LENGTH('Staging.Execution_Logs', 'ServerName') IS NULL
    ALTER TABLE Staging.Execution_Logs ADD ServerName NVARCHAR(255);

IF COL_LENGTH('Staging.Execution_Logs', 'DatabaseName') IS NULL
    ALTER TABLE Staging.Execution_Logs ADD DatabaseName NVARCHAR(255);

PRINT '✅ Upgrade de tabla de logs completado.';
GO