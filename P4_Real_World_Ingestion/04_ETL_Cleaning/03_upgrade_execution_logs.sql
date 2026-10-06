USE P4_Global_SupplyChain;
GO

IF COL_LENGTH(
    'Staging.Execution_Logs',
    'ExecutionGUID'
) IS NULL
BEGIN

    ALTER TABLE Staging.Execution_Logs
    ADD ExecutionGUID UNIQUEIDENTIFIER
        DEFAULT NEWID();

END
GO

IF COL_LENGTH(
    'Staging.Execution_Logs',
    'ServerName'
) IS NULL
BEGIN

    ALTER TABLE Staging.Execution_Logs
    ADD ServerName NVARCHAR(255);
END
GO

IF COL_LENGTH(
    'Staging.Execution_Logs',
    'DatabaseName'
) IS NULL
BEGIN

    ALTER TABLE Staging.Execution_Logs
    ADD DatabaseName NVARCHAR(255);
END
GO