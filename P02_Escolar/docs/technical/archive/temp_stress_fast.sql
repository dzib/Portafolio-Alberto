/* 
==============================================================================================================================================================================================
PROYECTO: P2_Escolar - Sistema de Gestión Académica
FASE: 3 -  Stress Test & Data Quality Shield (Parametrizable).
AUTOR: Alberto Dzib
VERSIÓN: 3.0 (Retrofitting) - Script end-to-end para staging
DESCRIPCIÓN: 
    - Script de stress test adaptado para cargas grandes. Procesa inscripciones, asistencias y actualización de NotaFinal en lotes para reducir uso de log y evitar timeouts. 
    - Parámetros configurables para Deptos, batches, runs y objetivo de inscripciones.
    - Generación adicional de "Nuevos Profesores" con MetaData_ETL estandarizado: SEED|<TipoMaestro>|PROF|D{Depto}|S{Seq} donde <TipoMaestro> ∈ {TIEMPO_COMPLETO, MEDIO_TIEMPO, INVITADO}.
    - Métricas por bloque y checkpoints en Control.LoadLog (DurationMs, CpuMs, RowsRead, RowsWritten).
    - Uso de tablas temporales y secuencias para determinismo y rendimiento.
================================================================================================================================================================================================
*/
USE P2_EscolarDB;
GO
--- -- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- -- VARIABLES DE BUCLE Y MÉTRICAS PARA CONTROL.
--- -- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON;                                                 -- Para reducir tiempo se suprime el mensaje de "(1 filas afectadas)".
SET XACT_ABORT ON;                                              -- Para asegura que errores aborten la transacción.

-- ===================================
-- Parámetros (CONFIGURACIÓN GLOBAL).
-- ===================================
DECLARE @CurrentRun INT = ISNULL((SELECT MAX(RunNumber) FROM Control.LoadLog),0) + 1;

DECLARE
    @RunStart DATETIME2 = SYSUTCDATETIME(),
    -- Control de runs (permite ejecutar stress en múltiples runs controlados).
    @MaxRuns INT = 1,                                           -- Número de ejecuciones completas máximo de runs encadenados (opcional)
    @RunIndex INT = 1,                                          -- índice del run actual (se puede iterar externamente).
    @DeptFilterLow INT = 4,                                     -- Rango de departamentos a procesar en este run.
    @DeptFilterHigh INT = 8,
    @BatchSize INT = 1,                                       -- Parámetros de stress inserción masiva Tamaño de lote para operaciones pesales.
    @MaxIters INT = 1,                                        -- Límite de iteraciones por run.
    @TargetNewProf INT = 1,                                   -- objetivo total de nuevos profesores a crear en este run
    @TargetNewAlu INT = 1,                                   -- objetivo total de alumnos a crear en este run
    @TargetInscripciones INT = 1,                           -- Objetivo total de inscripciones por run.
    @PauseBetweenBatches VARCHAR(8) = '00:00:00';               -- Pausa entre lotes para reducir presión en el log y evitar timeouts Formato hh:mm:ss.
                                                                -- Pausa de 1 segundo entre lotes para reducir presión en el log y evitar timeouts.

-- Variables de métricas.
DECLARE
    @blkStart DATETIME2,
    @blkEnd DATETIME2,
    @start_cpu BIGINT,
    @end_cpu BIGINT,
    @start_reads BIGINT,
    @end_reads BIGINT,
    @start_writes BIGINT,
    @end_writes BIGINT,
    @rowsAffected INT,
    @logId INT,
    @CurrentIterAlu INT = 0,
    @InsertedTotalAlu INT = 0,
    @InsertedMaterias INT = 0,
    @InsertedCursos INT = 0;


PRINT '--------------------------------------------------------------------------------------------------';
PRINT '🚀    Iniciando carga masiva Stress Test en P2_EscolarDB ... ' + CAST(SYSUTCDATETIME() AS VARCHAR);
PRINT 'RunNumber: ' + CAST(@CurrentRun AS VARCHAR(10));
PRINT 'Deptos: ' + CAST(@DeptFilterLow AS VARCHAR(3)) + ' - ' + CAST(@DeptFilterHigh AS VARCHAR(3));
PRINT 'BatchSize: ' + CAST(@BatchSize AS VARCHAR(10)) + ' MaxIters: ' + CAST(@MaxIters AS VARCHAR(10));
PRINT 'TargetInscripciones: ' + FORMAT(@TargetInscripciones, 'N0');
PRINT 'TargetNewProf: ' + FORMAT(@TargetNewProf, 'N0');
PRINT '--------------------------------------------------------------------------------------------------';
--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 1. VALIDACIONES PREVIAS (ABORTAR SI FALTAN DEPENDENCIAS).
--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Validaciones de existencia de tablas críticas.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Catalogos')
    OR NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Operaciones')
BEGIN
    RAISERROR('❌ Esquemas [Catalogos] u [Operaciones] faltantes. Ejecuta 01_Setup primero.',16,1);
    RETURN;
END;

IF (SELECT COUNT(*) FROM Catalogos.Cursos WHERE DeptoID BETWEEN @DeptFilterLow AND @DeptFilterHigh) = 0
BEGIN
    RAISERROR('❌Abortado: No hay cursos en el rango de Deptos %d-%d',16,1,@DeptFilterLow,@DeptFilterHigh);
    RETURN;
END;

IF (SELECT COUNT(*) FROM Catalogos.Profesores WHERE DeptoID BETWEEN @DeptFilterLow AND @DeptFilterHigh AND ISNULL(IsActive,1)=1) = 0
BEGIN
    RAISERROR('❌Abortado: No hay profesores activos en el rango de Deptos %d-%d',16,1,@DeptFilterLow,@DeptFilterHigh);
    RETURN;
END

IF (SELECT COUNT(*) FROM Support.TemasVariantes) = 0
BEGIN
    RAISERROR('❌Abortado: Support.TemasVariantes vacío. Ejecuta 02_DML primero.',16,1);
    RETURN;
END

IF (SELECT COUNT(*) FROM Catalogos.Alumnos) = 0
BEGIN
    RAISERROR('❌Abortado: No hay alumnos en Catalogos.Alumnos. Ejecuta 02_DML primero.',16,1);
    RETURN;
END

-- Verificar dbo.Numbers existe y tiene suficientes filas.
IF OBJECT_ID('dbo.Numbers','U') IS NULL
    BEGIN
    RAISERROR('dbo.Numbers no existe. Crea y pobla dbo.Numbers antes de ejecutar este script.',16,1);
    RETURN;
END;

--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 2. PREPARACIÓN: MATERIALIZAR CATÁLOGOS EN TABLAS TEMPORALES (para determinismo y velocidad).
--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Temp table: Cursos por Depto (determinista)
IF OBJECT_ID('tempdb..#CursosDept') IS NOT NULL DROP TABLE #CursosDept;
SELECT CursoID, DeptoID, Creditos, Nombre
INTO #CursosDept
FROM Catalogos.Cursos
WHERE DeptoID BETWEEN @DeptFilterLow AND @DeptFilterHigh;

-- Temp table: Materias existentes (para evitar duplicados rápidos)
IF OBJECT_ID('tempdb..#MatExist') IS NOT NULL DROP TABLE #MatExist;
SELECT MateriaID, CursoID, CicloEscolar, Grupo
INTO #MatExist
FROM Operaciones.Materias;

DECLARE @CursoCount INT = (SELECT COUNT(*) FROM #CursosDept);
DECLARE @MateriaCount INT = (SELECT COUNT(*) FROM #MatExist);

IF @CursoCount = 0 OR @MateriaCount = 0
BEGIN
    RAISERROR('Faltan catálogos (Cursos/Materias). Abortando.',16,1);
    RETURN;
END
PRINT 'Catalogos materializados: Cursos= ' + FORMAT(@CursoCount, 'N0') + ' | Materias= ' + FORMAT(@MateriaCount, 'N0');
--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- -- 3. OUTER LOOP: runs (1..@MaxRuns).
--- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WHILE @CurrentRun <= @MaxRuns
BEGIN
    PRINT '-------------------------------------------------------------------------------------------------------------------------------------------';
    PRINT '     Iniciando Run ' + CAST(@CurrentRun AS VARCHAR(3)) + ' de ' + CAST(@MaxRuns AS VARCHAR(3)) + ' - ' + CONVERT(VARCHAR(30), SYSUTCDATETIME());
    PRINT '-------------------------------------------------------------------------------------------------------------------------------------------';

--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- -- 4. GENERACIÓN DE PROFESORES.
    -- Idempotente y con límite: no se insertará más de @TargetNewProf en total.
--- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- calcular cuántos faltan por insertar
    DECLARE @AlreadyProf INT = (SELECT COUNT(*) FROM Catalogos.Profesores WHERE MetaData_ETL LIKE 'SEED|%|PROF|%');
    DECLARE @RemainingProf INT = CASE WHEN @TargetNewProf > @AlreadyProf THEN @TargetNewProf - @AlreadyProf ELSE 0 END;

    IF @RemainingProf > 0
    BEGIN
        BEGIN TRAN;
        BEGIN TRY
            SET @blkStart = SYSUTCDATETIME();
            SET @start_cpu = ISNULL((SELECT cpu_time FROM sys.dm_exec_requests WHERE session_id = @@SPID),0);
            SET @start_reads = ISNULL((SELECT logical_reads FROM sys.dm_exec_requests WHERE session_id = @@SPID),0);
            SET @start_writes = ISNULL((SELECT writes FROM sys.dm_exec_requests WHERE session_id = @@SPID),0);

            DECLARE @NewPerDept INT = 500; -- máximo por depto en la secuencia base (se truncará por @RemainingProf).
            -- Generar secuencia por depto y limitar globalmente con TOP (@RemainingProf).
            ;WITH Depts AS (
                SELECT DISTINCT DeptoID
                FROM Catalogos.Carreras
                WHERE DeptoID BETWEEN @DeptFilterLow AND @DeptFilterHigh
            ),
            SeqAll AS (
                SELECT d.DeptoID, n.n + 1 AS SeqNum
                FROM Depts d
                CROSS JOIN (SELECT TOP (@NewPerDept) n FROM dbo.Numbers n ORDER BY n) n
            ),
            SeqLimited AS (
                -- limitar al total restante de forma determinista (orden por DeptoID, SeqNum).
                SELECT TOP (@RemainingProf) *
                FROM SeqAll
                ORDER BY DeptoID, SeqNum
            ),
            -- Listas de nombres y apellidos (ampliables).
            Nombres AS (
                SELECT 1 AS id, N'Julián' AS Nombre UNION ALL
                SELECT 2, N'Elena' UNION ALL
                SELECT 3, N'Roberto' UNION ALL
                SELECT 4, N'Ana' UNION ALL
                SELECT 5, N'Carlos' UNION ALL
                SELECT 6, N'Sofía' UNION ALL
                SELECT 7, N'Andrea' UNION ALL
                SELECT 8, N'Miguel' UNION ALL
                SELECT 9, N'Laura' UNION ALL
                SELECT 10, N'Fernando'
            ),
            Apellidos AS (
                SELECT 1 AS id, N'Pérez' AS Apellido UNION ALL
                SELECT 2, N'Gómez' UNION ALL
                SELECT 3, N'Isaac' UNION ALL
                SELECT 4, N'Martínez' UNION ALL
                SELECT 5, N'Luna' UNION ALL
                SELECT 6, N'Reyes' UNION ALL
                SELECT 7, N'Díaz' UNION ALL
                SELECT 8, N'Sosa' UNION ALL
                SELECT 9, N'Ruiz' UNION ALL
                SELECT 10, N'Hernández'
            ),
            NamePick AS (
                SELECT
                    s.DeptoID,
                    s.SeqNum,
                    ((ABS(CHECKSUM(s.DeptoID, s.SeqNum)) % (SELECT COUNT(*) FROM Nombres)) + 1) AS NombreIdx,
                    ((ABS(CHECKSUM(s.SeqNum, s.DeptoID)) % (SELECT COUNT(*) FROM Apellidos)) + 1) AS ApellidoIdx
                FROM SeqLimited s
            ),
            NewProfs AS (
                SELECT
                    -- TipoMaestro determinista.
                    CASE ((np.DeptoID + np.SeqNum) % 3)
                        WHEN 0 THEN N'TIEMPO_COMPLETO'
                        WHEN 1 THEN N'MEDIO_TIEMPO'
                        ELSE N'INVITADO'
                    END AS TipoMaestro,
                    -- Prefijo legible para Nombre determinista: 0->Doctor,1->Profesor,2->Maestro.
                    CASE ((np.DeptoID + np.SeqNum) % 3)
                        WHEN 0 THEN N'Doctor'
                        WHEN 1 THEN N'Profesor'
                        ELSE N'Maestro'
                    END AS Prefijo,
                    -- Nombre completo: Prefijo + ' ' + Nombre + ' ' + Apellido.
                    CONCAT(
                        CASE ((np.DeptoID + np.SeqNum) % 3)
                            WHEN 0 THEN N'Doctor'
                            WHEN 1 THEN N'Profesor'
                            ELSE N'Maestro'
                        END, N' ',
                        (SELECT Nombre FROM Nombres WHERE id = np.NombreIdx),
                        N' ',
                        (SELECT Apellido FROM Apellidos WHERE id = np.ApellidoIdx)
                    ) AS NombreCompleto,
                    -- Email: seed.<prefijo>.<nombre>.<apellido>@escolar.edu (minúsculas, sin acentos básicos).
                    LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                        CONCAT(
                            'seed.',
                            CASE ((np.DeptoID + np.SeqNum) % 3)
                                WHEN 0 THEN 'doctor'
                                WHEN 1 THEN 'profesor'
                                ELSE 'maestro'
                            END, '.',
                            (SELECT Nombre FROM Nombres WHERE id = np.NombreIdx), '.',
                            (SELECT Apellido FROM Apellidos WHERE id = np.ApellidoIdx)
                        ),
                        N'Á', N'A'),
                        N'É', N'E'),
                        N'Í', N'I'),
                        N'Ó', N'O'),
                        N'Ú', N'U'),
                        N'á', N'a'),
                        N'é', N'e'),
                        N'í', N'i'),
                        N'ó', N'o'),
                        N'ú', N'u'
                    )) + '@escolar.edu' AS Email,
                    np.DeptoID AS DeptoID,
                    -- MetaData_ETL con TipoMaestro estandarizado
                    CONCAT('SEED|',
                            CASE ((np.DeptoID + np.SeqNum) % 3)
                                WHEN 0 THEN 'TIEMPO_COMPLETO'
                                WHEN 1 THEN 'MEDIO_TIEMPO'
                                ELSE 'INVITADO'
                            END,
                            '|PROF|D', np.DeptoID, '|S', np.SeqNum) AS MetaData_ETL,
                    1 AS IsActive,
                    CASE WHEN (np.SeqNum % 2) = 0 THEN 'M' ELSE 'F' END AS Sexo
                FROM NamePick np
            )
            INSERT INTO Catalogos.Profesores (Nombre, Email, DeptoID, MetaData_ETL, IsActive, Sexo)
            SELECT DISTINCT NombreCompleto, Email, DeptoID, MetaData_ETL, IsActive, Sexo
            FROM NewProfs np
            WHERE NOT EXISTS (
                SELECT 1 FROM Catalogos.Profesores p
                WHERE p.Email = np.Email OR p.Nombre = np.NombreCompleto
            );

            SET @rowsAffected = @@ROWCOUNT;

            INSERT INTO Control.LoadLog (RunNumber, Entidad, BatchOffset, RowsAffected, Estado, Fecha, Mensaje)
            VALUES (@CurrentRun, 'Catalogos.Profesores.Seed', 0, @rowsAffected, 'COMMIT', SYSUTCDATETIME(), CONCAT('Profesores seed insertados Rows=', @rowsAffected));
            SET @logId = SCOPE_IDENTITY();

            COMMIT;

            SET @blkEnd = SYSUTCDATETIME();
            SET @end_cpu = ISNULL((SELECT cpu_time FROM sys.dm_exec_requests WHERE session_id = @@SPID),0);
            SET @end_reads = ISNULL((SELECT logical_reads FROM sys.dm_exec_requests WHERE session_id = @@SPID),0);
            SET @end_writes = ISNULL((SELECT writes FROM sys.dm_exec_requests WHERE session_id = @@SPID),0);

            UPDATE Control.LoadLog
            SET DurationMs = DATEDIFF(MILLISECOND, @blkStart, @blkEnd),
                CpuMs = CASE WHEN @end_cpu >= @start_cpu THEN @end_cpu - @start_cpu ELSE 0 END,
                RowsRead = CASE WHEN @end_reads >= @start_reads THEN @end_reads - @start_reads ELSE 0 END,
                RowsWritten = CASE WHEN @end_writes >= @start_writes THEN @end_writes - @start_writes ELSE 0 END
            WHERE LoadLogID = @logId;

            PRINT '✅ Profesores seed insertados: ' + FORMAT(@rowsAffected,'N0');
            WAITFOR DELAY @PauseBetweenBatches;
        END TRY
        BEGIN CATCH
            IF XACT_STATE() <> 0 ROLLBACK;
            DECLARE @errProf NVARCHAR(4000) = ERROR_MESSAGE();
            INSERT INTO Control.LoadLog (RunNumber, Entidad, BatchOffset, RowsAffected, Estado, Fecha, Mensaje)
            VALUES (@CurrentRun, 'Catalogos.Profesores.Seed', 0, 0, 'ROLLBACK', SYSUTCDATETIME(), CONCAT('Error seed Profesores: ', @errProf));
            RAISERROR('Error seed Profesores: %s',16,1,@errProf);
        END CATCH;
    END
    ELSE
    BEGIN
        PRINT 'No se requieren nuevos profesores seed (RemainingProf = 0).';
    END

--- -- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- -- 5. GENERACIÓN DE MATERIAS DIVERSIFICADAS CON CICLOS, GRUPOS Y BALANCEO ROUND-ROBIN.
--- -- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ==============================================================
-- MATERIAS (IDENTITY) - (con balanceo round‑robin por profesor).
-- ==============================================================
BEGIN TRAN;
BEGIN TRY
    PRINT '-----------------------------------------------------------------------------';
    PRINT '📘       Generando Materias Congruentes ... ' + CAST(SYSUTCDATETIME() AS VARCHAR);
    PRINT '-----------------------------------------------------------------------------';
    SET @blkStart = SYSUTCDATETIME();
    SET @start_cpu = ISNULL((SELECT cpu_time FROM sys.dm_exec_requests WHERE session_id = @@SPID),0);
    SET @start_reads = ISNULL((SELECT logical_reads FROM sys.dm_exec_requests WHERE session_id = @@SPID),0);
    SET @start_writes = ISNULL((SELECT writes FROM sys.dm_exec_requests WHERE session_id = @@SPID),0);

    -- Definir grupos A-C.
    DECLARE @Grupos TABLE (Grupo NVARCHAR(5));
    INSERT INTO @Grupos VALUES ('A'), ('B'), ('C');

    ;WITH ProfPick AS (
        SELECT p.ProfesorID, p.DeptoID,
                ROW_NUMBER() OVER (PARTITION BY p.DeptoID ORDER BY p.ProfesorID) AS ProfRow,
                COUNT(*) OVER (PARTITION BY p.DeptoID) AS ProfCount
        FROM Catalogos.Profesores p
        WHERE ISNULL(p.IsActive,1)=1
            AND p.DeptoID BETWEEN @DeptFilterLow AND @DeptFilterHigh
    ),
    CursosBase AS (
        SELECT c.CursoID, c.DeptoID, c.Creditos, c.Nombre AS CursoNombre, dm.PrefijoNombre
        FROM Catalogos.Cursos c
        JOIN Catalogos.DeptoMeta dm ON dm.DeptoID = c.DeptoID
        WHERE c.DeptoID BETWEEN @DeptFilterLow AND @DeptFilterHigh
    )
    INSERT INTO Operaciones.Materias (Nombre, Creditos, ProfesorID, CursoID, CicloEscolar, Grupo)
    SELECT
        CONCAT(cb.PrefijoNombre, cb.CursoNombre, ' - ', cyc.Ciclo, ' - Sem', ss.SemestreNumero, ' - Grupo ', g.Grupo) AS Nombre,
        cb.Creditos,
        pp.ProfesorID,
        cb.CursoID,
        cyc.Ciclo,
        g.Grupo
    FROM CursosBase cb
    JOIN Support.Semestres ss ON 1=1
    JOIN Support.Ciclos cyc ON cyc.CicloID = ss.CicloID
    JOIN Support.TemasVariantes tv ON tv.SemestreID = ss.SemestreID
    CROSS JOIN @Grupos g
    CROSS APPLY (
        SELECT ((ABS(CHECKSUM(cb.CursoID, HASHBYTES('SHA1', CONCAT(cyc.Ciclo, g.Grupo)))) % ISNULL((SELECT MAX(ProfCount) FROM ProfPick WHERE DeptoID = cb.DeptoID),1)) + 1) AS PickRow
    ) pr
    JOIN ProfPick pp ON pp.DeptoID = cb.DeptoID AND pp.ProfRow = pr.PickRow
    WHERE NOT EXISTS (
        SELECT 1 FROM Operaciones.Materias m
        WHERE m.CursoID = cb.CursoID
            AND m.CicloEscolar = cyc.Ciclo
            AND m.Grupo = g.Grupo
    );

    SET @rowsAffected = @@ROWCOUNT;

    INSERT INTO Control.LoadLog (RunNumber, Entidad, BatchOffset, RowsAffected, Estado, Fecha, Mensaje)
    VALUES (@CurrentRun, 'Operaciones.Materias', 0, @rowsAffected, 'COMMIT', SYSUTCDATETIME(), CONCAT('Materias generadas Deptos ', @DeptFilterLow, '-', @DeptFilterHigh));
    SET @logId = SCOPE_IDENTITY();

    COMMIT;

    SET @blkEnd = SYSUTCDATETIME();
    SET @end_cpu = ISNULL((SELECT cpu_time FROM sys.dm_exec_requests WHERE session_id = @@SPID),0);
    SET @end_reads = ISNULL((SELECT logical_reads FROM sys.dm_exec_requests WHERE session_id = @@SPID),0);
    SET @end_writes = ISNULL((SELECT writes FROM sys.dm_exec_requests WHERE session_id = @@SPID),0);

    UPDATE Control.LoadLog
    SET DurationMs = DATEDIFF(MILLISECOND, @blkStart, @blkEnd),
        CpuMs = CASE WHEN @end_cpu >= @start_cpu THEN @end_cpu - @start_cpu ELSE 0 END,
        RowsRead = CASE WHEN @end_reads >= @start_reads THEN @end_reads - @start_reads ELSE 0 END,
        RowsWritten = CASE WHEN @end_writes >= @start_writes THEN @end_writes - @start_writes ELSE 0 END
    WHERE LoadLogID = @logId;

    PRINT '✅ Operaciones.Materias generadas: ' + FORMAT(@rowsAffected, 'N0');
    WAITFOR DELAY @PauseBetweenBatches;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    DECLARE @errMat NVARCHAR(4000) = ERROR_MESSAGE();
    INSERT INTO Control.LoadLog (RunNumber, Entidad, BatchOffset, RowsAffected, Estado, Fecha, Mensaje)
    VALUES (@CurrentRun, 'Operaciones.Materias', 0, 0, 'ROLLBACK', SYSUTCDATETIME(), CONCAT('Error Materias: ', @errMat));
    RAISERROR('Error en Materias: %s',16,1,@errMat);
    RETURN;
END CATCH;

--- -- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- -- 9. CARGA MASIVA DE ALUMNOS ( Usando sp_sequence_get_range (con conversión sql_variant -> bigint).
--- -- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    PRINT '----------------------------------------------------------------------------';
    PRINT '🚀         Generando alumnos ... ' + CAST(SYSUTCDATETIME() AS VARCHAR);
    PRINT '----------------------------------------------------------------------------';
    -- Asume que: dbo.Numbers, dbo.SeqNumbers, #CarrList y Control.LoadLog existen y parámetros globales están definidos.
    -- Cuenta cuántos alumnos ya existen con el prefijo de stress (Para ajusta el filtro).
    DECLARE @NombreBase NVARCHAR(50) = 'UNI_'; -- Prefijo base para Nombre/Email.
    DECLARE @EmailDomain NVARCHAR(100) = '@escolar.edu';
    DECLARE @SeqNameAlu NVARCHAR(128) = N'dbo.SeqNumbers';

    IF OBJECT_ID('tempdb..#CarrList') IS NOT NULL DROP TABLE #CarrList;
    SELECT CarreraID, DeptoID, ROW_NUMBER() OVER (ORDER BY CarreraID) AS CarrRow
    INTO #CarrList
    FROM Catalogos.Carreras
    WHERE DeptoID BETWEEN @DeptFilterLow AND @DeptFilterHigh;

    IF OBJECT_ID('dbo.Numbers','U') IS NULL
    BEGIN
        RAISERROR('dbo.Numbers no existe. Crea y pobla dbo.Numbers antes de ejecutar este script.',16,1);
        RETURN;
    END;

    -- Calcular cuántos ya existen con prefijo de stress.
    DECLARE @AlreadyAlu INT = (SELECT COUNT(*) FROM Catalogos.Alumnos);
    DECLARE @RemainingAlu INT = CASE WHEN @TargetNewAlu > @AlreadyAlu THEN @TargetNewAlu - @AlreadyAlu ELSE 0 END;

    PRINT 'Inicio carga Alumnos. Objetivo: ' + FORMAT(@TargetNewAlu, 'N0') + ' | Ya existen: ' + CAST(@AlreadyAlu AS VARCHAR(20));

    -- Loop controlado por objetivo y tope de iteraciones.
    WHILE @RemainingAlu > 0 AND @CurrentIterAlu < @MaxIters
    BEGIN
        SET @CurrentIterAlu += 1;
        DECLARE @ThisBatchAlu INT = CASE WHEN @RemainingAlu < @BatchSize THEN @RemainingAlu ELSE @BatchSize END;
        DECLARE @StartBatchAlu DATETIME2 = SYSUTCDATETIME();

        -- Reservamnos un rango de la sequencia en una sola llamada (outputs sql_variant).
        DECLARE @RangeStartAlu sql_variant, @RangeLastAlu sql_variant;
        DECLARE @RangeStartBigintAlu BIGINT, @RangeLastBigintAlu BIGINT;

        EXEC sp_sequence_get_range 
            @sequence_name = @SeqNameAlu,
            @range_size = @ThisBatchAlu ,
            @range_first_value = @RangeStartAlu OUTPUT,
            @range_last_value = @RangeLastAlu OUTPUT;

        -- Conversión explícita a BIGINT y uso exclusivo de las variables BIGINT.
        SET @RangeStartBigintAlu = CONVERT(BIGINT, @RangeStartAlu);
        SET @RangeLastBigintAlu  = CONVERT(BIGINT, @RangeLastAlu);

        BEGIN TRAN;
        BEGIN TRY
            ;WITH ToGen AS (
                SELECT TOP (@ThisBatchAlu ) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
                FROM dbo.Numbers
            )
            INSERT INTO Catalogos.Alumnos (Nombre, CarreraID, DeptoID, Email, FechaNacimiento, Sexo, MetaData_ETL)
            SELECT
                @NombreBase + CAST(@RangeStartBigintAlu + t.rn - 1 AS VARCHAR(20)) AS Nombre,
                C.CarreraID,
                C.DeptoID,
                LOWER(@NombreBase) + CAST(@RangeStartBigintAlu + t.rn - 1 AS VARCHAR(20)) + @EmailDomain AS Email,
                CAST(DATEADD(DAY, -((ABS(CHECKSUM(@RangeStartBigintAlu + t.rn - 1)) % 36500)), GETDATE()) AS DATE) AS FechaNacimiento,
                CASE (ABS(CHECKSUM(@RangeStartBigintAlu + t.rn - 1 + 999)) % 2) WHEN 0 THEN 'M' ELSE 'F' END AS Sexo,
                -- MetaData_ETL consolida FechaIngreso | Estatus | Promedio para normalizar en Fase 4
                CONCAT(
                    CONVERT(VARCHAR(10), CAST(DATEADD(DAY, -((ABS(CHECKSUM(@RangeStartBigintAlu + t.rn - 1 + 12345)) % 3650)), GETDATE()) AS DATE), 23),
                    ' | ',
                    CASE (ABS(CHECKSUM(@RangeStartBigintAlu + t.rn - 1)) % 6)
                        WHEN 0 THEN 'ACTIVO' WHEN 1 THEN 'IRREGULAR' WHEN 2 THEN 'CONDICIONAL'
                        WHEN 3 THEN 'BAJA_TEMP' WHEN 4 THEN 'BAJA_DEFI' WHEN 5 THEN 'EGRESADO' END,
                    ' | ',
                    CAST( ( (ABS(CHECKSUM(@RangeStartBigintAlu + t.rn - 1 + 54321)) % 401) / 100.0 ) + 6.00 AS VARCHAR(15))
                ) AS MetaData_ETL
            FROM ToGen t
            CROSS APPLY (SELECT ((t.rn - 1) % (SELECT COUNT(*) FROM #CarrList)) + 1 AS CarrRowCalc) rc
            JOIN #CarrList C ON C.CarrRow = rc.CarrRowCalc
            WHERE NOT EXISTS (
                SELECT 1 FROM Catalogos.Alumnos A
                WHERE A.Email = LOWER(@NombreBase) + CAST(@RangeStartBigintAlu + t.rn - 1 AS VARCHAR(20)) + @EmailDomain
            );

            DECLARE @RowsThisAlu INT = @@ROWCOUNT;
            SET @InsertedTotalAlu += @RowsThisAlu;
            SET @RemainingAlu -= @RowsThisAlu;
            -- Log con duración del batch (inserta y luego actualiza DurationMs).
            INSERT INTO Control.LoadLog (RunNumber, Entidad, BatchOffset, RowsAffected, Estado, Fecha, Mensaje)
            VALUES (@CurrentRun, 'Alumnos', @InsertedTotalAlu, @RowsThisAlu, 'COMMIT', SYSUTCDATETIME(),
                    CONCAT('Iter=', @CurrentIterAlu, ' Target=', @TargetNewAlu, ' Remaining=', @RemainingAlu));
            DECLARE @LogIDAlu INT = SCOPE_IDENTITY();

            COMMIT;

            DECLARE @EndBatchAlu DATETIME2 = SYSUTCDATETIME();
            DECLARE @DurationMsAlu INT = DATEDIFF(MILLISECOND, @StartBatchAlu, @EndBatchAlu);

            -- Actualizar el registro de log con duración.
            UPDATE Control.LoadLog SET DurationMs = @DurationMsAlu WHERE LoadLogID = @LogIDAlu;

            PRINT 'Alumnos insertados en batch: ' + FORMAT(@RowsThisAlu, 'N0') +
                ' | Total insertados: ' + FORMAT(@InsertedTotalAlu, 'N0') +
                ' | Iter ' + CAST(@CurrentIterAlu AS VARCHAR(10));
            WAITFOR DELAY @PauseBetweenBatches;
        END TRY
        BEGIN CATCH
            IF XACT_STATE() <> 0 ROLLBACK;
            INSERT INTO Control.LoadLog (RunNumber, Entidad, BatchOffset, RowsAffected, Estado, Fecha, Mensaje)
            VALUES (@CurrentRun, 'Alumnos', @InsertedTotalAlu, 0, 'ROLLBACK', SYSUTCDATETIME(), ERROR_MESSAGE());
            THROW;
        END CATCH;
    END
    -- Se deben Reconstruir índices si fueron deshabilitados.
    -- ALTER INDEX ALL ON Catalogos.Alumnos REBUILD;
    -- Aplicamos una seguridad adicional: si alcanzamos tope de iteraciones sin completar objetivo, loguear y alertar.
    IF @RemainingAlu > 0 AND @CurrentIterAlu >= @MaxIters
    BEGIN
        INSERT INTO Control.LoadLog (RunNumber, Entidad, BatchOffset, RowsAffected, Estado, Fecha, Mensaje)
        VALUES (@CurrentRun, 'Alumnos', @InsertedTotalAlu, @InsertedTotalAlu, 'PARTIAL', SYSUTCDATETIME(),
                CONCAT('Max iterations reached=', @MaxIters, ' Remaining=', @RemainingAlu));
        RAISERROR('Máximo de iteraciones alcanzado en carga de alumnos. Remaining=%d', 16, 1, @RemainingAlu);
    END
    PRINT 'Carga Alumnos finalizada. Total insertados en este run: ' + FORMAT(@InsertedTotalAlu,'N0') + ' | Remaining=' + FORMAT(@RemainingAlu,'N0');

    IF OBJECT_ID('tempdb..#CarrList') IS NOT NULL DROP TABLE #CarrList;

--- -- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- -- 11. GENERAR INSCRIPCIONES MASIVAS POR LOTES (OUTPUT -> #NewIns) SEGÚN ESTATUS DEL ALUMNO..
--- -- Usasando el Estatus desde CursosCount según MetaData_ETL para decidir cantidad de inscripciones por alumno. ACTIVO=6, IRREGULAR=4 a 5, CONDICIONAL=3 a 4 , EGRESADO/BAJA_TEMP/BAJA_DEFI -> 0
--- -- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Se distribuye inscripciones entre varios CiclosEscolares (lista parametrizable).
    -- Buscando evitar duplicados (AlumnoID, MateriaID, CursoID, CicloEscolar).
    PRINT '--------------------------------------------------------------------------------------------------';
    PRINT '🚀         Iniciando Inscripciones ... ' + CAST(SYSUTCDATETIME() AS VARCHAR);
    PRINT '--------------------------------------------------------------------------------------------------';

    -- Temporales de apoyo
    IF OBJECT_ID('tempdb..#AluList') IS NOT NULL DROP TABLE #AluList;
    SELECT AlumnoID, MetaData_ETL,
        UPPER(REPLACE(PARSENAME(REPLACE(MetaData_ETL,'|','.'),2),' ','')) AS EstatusNorm,
        ROW_NUMBER() OVER (ORDER BY AlumnoID) AS AluRow
    INTO #AluList
    FROM Catalogos.Alumnos;

    IF OBJECT_ID('tempdb..#MatList') IS NOT NULL DROP TABLE #MatList;
    SELECT MateriaID, CursoID, CicloEscolar,
        ROW_NUMBER() OVER (ORDER BY MateriaID) AS MatRow
    INTO #MatList
    FROM Operaciones.Materias;

    DECLARE @AluCount INT = (SELECT COUNT(*) FROM #AluList);
    DECLARE @MatCount INT = (SELECT COUNT(*) FROM #MatList);

    -- Control.
    DECLARE @AlreadyIns INT = (SELECT COUNT(*) FROM Operaciones.Inscripciones);
    DECLARE @RemainingIns INT = CASE WHEN @TargetInscripciones > @AlreadyIns THEN @TargetInscripciones - @AlreadyIns ELSE 0 END;
    DECLARE @InsertedIns INT = 0, @IterIns INT = 0;

    PRINT 'Inicio Inscripciónes. Objetivo: ' + FORMAT(@TargetInscripciones, 'N0') + ' | Ya existen: ' + CAST(@AlreadyIns AS VARCHAR(20));

-- Ayuda: análisis en de acuerdo a función del Estatus desde MetaData_ETL (simple, busca token).
-- Nota : MetaData_ETL tiene formato "FechaIngreso | ESTATUS | Promedio"
    WHILE @RemainingIns > 0 AND @IterIns < @MaxIters
    BEGIN
        SET @IterIns += 1;
        DECLARE @StartBatchIns DATETIME2 = SYSUTCDATETIME();

        BEGIN TRAN;
        BEGIN TRY
            ;WITH AluPlan AS (
                SELECT AlumnoID,
                    CASE EstatusNorm
                            WHEN 'ACTIVO' THEN 6
                            WHEN 'IRREGULAR' THEN ((ABS(CHECKSUM(AlumnoID)) % 2) + 4)
                            WHEN 'CONDICIONAL' THEN ((ABS(CHECKSUM(AlumnoID+7)) % 2) + 3)
                            ELSE 0
                    END AS NumMaterias
                FROM #AluList
            ),
            Expand AS (
                SELECT ap.AlumnoID, v.Seq
                FROM AluPlan ap
                CROSS APPLY (SELECT TOP (ap.NumMaterias) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Seq) v
            ),
            MapToMat AS (
                SELECT e.AlumnoID,
                    ((ABS(CHECKSUM(e.AlumnoID + e.Seq))) % (SELECT COUNT(*) FROM #MatList)) + 1 AS MatRowCalc
                FROM Expand e
            )
            INSERT INTO Operaciones.Inscripciones (AlumnoID, MateriaID, NotaFinal)
            OUTPUT inserted.InscripcionID, inserted.AlumnoID, inserted.MateriaID INTO #NewIns
            SELECT DISTINCT A.AlumnoID, M.MateriaID, NULL
            FROM MapToMat mt
            JOIN #AluList A ON A.AlumnoID = mt.AlumnoID
            JOIN #MatList M ON M.MatRow = mt.MatRowCalc
            WHERE NOT EXISTS (
                SELECT 1 FROM Operaciones.Inscripciones i
                WHERE i.AlumnoID = A.AlumnoID AND i.MateriaID = M.MateriaID
            );

            DECLARE @RowsThisIns INT = @@ROWCOUNT;
            SET @InsertedIns += @RowsThisIns;
            SET @RemainingIns -= @RowsThisIns;
            -- Log y checkpoint.
            INSERT INTO Control.LoadLog (RunNumber, Entidad, BatchOffset, RowsAffected, Estado, Fecha, Mensaje)
            VALUES (@CurrentRun, 'Inscripciones',  @InsertedIns, @RowsThisIns, 'COMMIT', SYSUTCDATETIME(),
                    CONCAT('Iter=', @IterIns, ' TargetApprox=',  @TargetInscripciones, ' Remaining=', @RemainingIns));
            DECLARE @LogIDIns INT = SCOPE_IDENTITY();

            COMMIT;

            DECLARE @EndBatchIns DATETIME2 = SYSUTCDATETIME();
            DECLARE @DurationMsIns INT = DATEDIFF(MILLISECOND, @StartBatchIns, @EndBatchIns);
            UPDATE Control.LoadLog SET DurationMs = @DurationMsIns WHERE LoadLogID = @LogIDIns;

            PRINT '✅ Inscripciones insertadas en batch: ' + FORMAT(@RowsThisIns ,'N0') +
                ' | Total insertadas: ' + FORMAT(@InsertedIns,'N0') +
                ' | Iter ' + CAST(@IterIns AS VARCHAR(10));
            IF @RowsThisIns = 0 BREAK; -- 🔒 Para evitar bucles infinitos.
            WAITFOR DELAY @PauseBetweenBatches;
        END TRY
        BEGIN CATCH
            IF XACT_STATE() <> 0 ROLLBACK;
            DECLARE @errIns NVARCHAR(4000) = ERROR_MESSAGE();
            INSERT INTO Control.LoadLog (RunNumber, Entidad, BatchOffset, RowsAffected, Estado, Fecha, Mensaje)
            VALUES (@CurrentRun, 'Inscripciones', @InsertedIns, 0, 'ROLLBACK', SYSUTCDATETIME(),  CONCAT('Error generando Inscripciones: ', @errIns));
            RAISERROR('❌ Error generando Inscripciones: %s',16,1,@errIns);
        END CATCH;

    END
    PRINT 'Inscripciones generadas totales (aprox): ' + FORMAT(@InsertedIns, 'N0');

--- -- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- -- 12. INSERCION DE CALIFICACIÓNES PARCIALES POR INSCRIPCIONID (1-3 parciales por inscripción, evitando duplicados).
--- -- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Se calcula NotaFinal como promedio simple y se actualiza en Operaciones.Inscripciones.
    PRINT '-----------------------------------------------------------------------------------------------';
    PRINT '📝           Generando Calificaciones Parciales ... ' + CAST(SYSUTCDATETIME() AS VARCHAR);
    PRINT '-----------------------------------------------------------------------------------------------';

    DECLARE @BatchSizeCal INT = 50000;
    DECLARE @MaxItersCal INT = 200000;
    
    -- Asegurar #NewInsCal existe (si no, tomar inscripciones recientes).
    IF OBJECT_ID('tempdb..#NewInsCal') IS NULL
    BEGIN
        SELECT TOP (100000) InscripcionID, AlumnoID, MateriaID INTO #NewInsCal
        FROM Operaciones.Inscripciones
        ORDER BY InscripcionID DESC;
    END;

    -- Lista de inscripciones a procesar (evita duplicados).
    IF OBJECT_ID('tempdb..#ToProcessIns') IS NOT NULL DROP TABLE #ToProcessIns;
    SELECT InscripcionID INTO #ToProcessIns
    FROM #NewInsCal
    WHERE InscripcionID NOT IN (SELECT DISTINCT InscripcionID FROM Operaciones.Calificaciones);

    
    DECLARE @TotalToProc INT = (SELECT COUNT(*) FROM #ToProcessIns);
    DECLARE @Processed INT = 0, @IterCal INT = 0;

    PRINT 'Inicio Calificaciones. Objetivo: ' + FORMAT(@TotalToProc,'N0');

    WHILE @Processed < @TotalToProc AND @IterCal < @MaxItersCal
    BEGIN
        SET @IterCal += 1;
        DECLARE @ThisBatchCal INT = CASE WHEN (@TotalToProc - @Processed) < @BatchSizeCal THEN (@TotalToProc - @Processed) ELSE @BatchSizeCal END;
        DECLARE @StartBatchCal DATETIME2 = SYSUTCDATETIME();
        
        BEGIN TRAN;
        BEGIN TRY
            ;WITH Pick AS (
                SELECT TOP (@ThisBatchCal) InscripcionID FROM #ToProcessIns ORDER BY InscripcionID
            ),
            GenPar AS (
                SELECT p.InscripcionID,
                    ((ABS(CHECKSUM(p.InscripcionID)) % 3) + 2) AS ParcalesToCreate -- Cada inscripción recibe entre 2 y 3 parciales generados determinísticamente.
                FROM Pick p
            ),
            Expand AS (
                SELECT g.InscripcionID, v.ParcialNum
                FROM GenPar g
                CROSS APPLY (VALUES (1),(2),(3)) v(ParcialNum)
                WHERE v.ParcialNum <= g.ParcalesToCreate
            )
            -- Insertar parciales evitando duplicados.
            INSERT INTO Operaciones.Calificaciones (InscripcionID, ParcialNumero, Nota, MetaData_ETL)
            SELECT e.InscripcionID, e.ParcialNumero,
                CAST(((ABS(CHECKSUM(e.InscripcionID + e.ParcialNumero)) % 401) / 100.0) + 6.00 AS DECIMAL(5,2)) AS Nota,
                CONCAT('GEN_CAL|P', e.ParcialNumero, '|I', CAST(e.InscripcionID AS VARCHAR(20))) AS MetaData_ETL
            FROM Expand e
            WHERE NOT EXISTS (
                SELECT 1 FROM Operaciones.Calificaciones c
                WHERE c.InscripcionID = e.InscripcionID AND c.ParcialNumero = e.ParcialNumero
            );

            -- Calcular NotaFinal como promedio simple de parciales insertados.
            ;WITH NewAvg AS (
                SELECT c.InscripcionID, AVG(CAST(c.Nota AS FLOAT)) AS AvgCal
                FROM Operaciones.Calificaciones c
                WHERE c.InscripcionID IN (SELECT InscripcionID FROM Pick)
                GROUP BY c.InscripcionID
            )
            UPDATE i
            SET i.NotaFinal = CAST(na.AvgCal AS DECIMAL(5,2))
            FROM Operaciones.Inscripciones i
            JOIN NewAvg na ON na.InscripcionID = i.InscripcionID;

            DECLARE @RowsCal INT = @@ROWCOUNT;
            SET @Processed += @ThisBatchCal;

            INSERT INTO Control.LoadLog (RunNumber, Entidad, BatchOffset, RowsAffected, Estado, Fecha, Mensaje)
            VALUES (@CurrentRun, 'Calificaciones', @Processed, @RowsCal, 'COMMIT', SYSUTCDATETIME(),
                    CONCAT('Iter=', @IterCal, ' BatchIns=', @ThisBatchCal, ' RowsCal=', @RowsCal));
            DECLARE @LogIDCal INT = SCOPE_IDENTITY();

            COMMIT;

            DECLARE @EndBatchCal DATETIME2 = SYSUTCDATETIME();
            DECLARE @DurationMsCal INT = DATEDIFF(MILLISECOND, @StartBatchCal, @EndBatchCal);
            UPDATE Control.LoadLog SET DurationMs = @DurationMsCal WHERE LoadLogID = @LogIDCal;

            PRINT 'Calificaciones insertadas en batch: ' + FORMAT(@RowsCal,'N0') +
                    ' | Total procesadas: ' + FORMAT(@Processed,'N0') +
                    ' | Iter ' + CAST(@IterCal AS VARCHAR(10));
            IF @RowsCal = 0 BREAK;
            WAITFOR DELAY @PauseBetweenBatches;

        END TRY
        BEGIN CATCH
            IF XACT_STATE() <> 0 ROLLBACK;
                INSERT INTO Control.LoadLog (RunNumber, Entidad, BatchOffset, RowsAffected, Estado, Fecha, Mensaje)
                VALUES (@CurrentRun, 'Calificaciones', @Processed, 0, 'ROLLBACK', SYSUTCDATETIME(), ERROR_MESSAGE());
            THROW;
        END CATCH;

    END

    PRINT 'Calificaciones procesadas totales (aprox): ' + CAST(@Processed AS VARCHAR(20));

--- -- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- -- 13. GENERAR ASISTENCIAS DETERMINISTAS POR LOTES (USANDO #NewIns PARA CONTROL DE FK).
--- -- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    PRINT '-----------------------------------------------------------------------------';
    PRINT '📅           Generando Asistencias ... ' + CAST(SYSUTCDATETIME() AS VARCHAR);
    PRINT '-----------------------------------------------------------------------------';

    DECLARE @SessionsPerIns INT = 12;  -- Sesiones por inscripción.
    DECLARE @BatchSizeAsis INT = @BatchSize;
    DECLARE @PauseBetweenBatchesAsis TIME = '00:00:01';
    DECLARE @CurrentRunAsis INT = 1;

    DECLARE @TotalIns INT = (SELECT COUNT(*) FROM #NewIns);
    DECLARE @ProcessedIns INT = 0, @IterAsis INT = 0;

    WHILE @ProcessedIns < @TotalIns AND @IterAsis < @MaxIters
    BEGIN
        SET @IterAsis += 1;
        DECLARE @ThisBatchAsis INT = CASE WHEN (@TotalIns - @ProcessedIns) < @BatchSizeAsis THEN (@TotalIns - @ProcessedIns) ELSE @BatchSizeAsis END;
        DECLARE @RowsAsis INT = 0;
        DECLARE @StartBatchAsis DATETIME2 = SYSUTCDATETIME();

        BEGIN TRAN;
        BEGIN TRY
            ;WITH Pick AS (
                SELECT TOP (@ThisBatchAsis) NI.InscripcionID, NI.AlumnoID, NI.MateriaID
                FROM #NewIns NI
                WHERE NI.InscripcionID NOT IN (SELECT DISTINCT InscripcionID FROM Operaciones.Asistencias)
                ORDER BY NI.InscripcionID
            ),
            MatInfo AS (
            SELECT p.InscripcionID, p.AlumnoID, p.MateriaID,
                    m.CursoID, m.CicloEscolar,
                    CASE WHEN RIGHT(m.CicloEscolar,1)='1'
                            THEN DATEFROMPARTS(CAST(LEFT(m.CicloEscolar,4) AS INT),1,1)
                            ELSE DATEFROMPARTS(CAST(LEFT(m.CicloEscolar,4) AS INT),7,1) END AS SemInicio,
                    CASE WHEN RIGHT(m.CicloEscolar,1)='1'
                            THEN DATEFROMPARTS(CAST(LEFT(m.CicloEscolar,4) AS INT),6,30)
                            ELSE DATEFROMPARTS(CAST(LEFT(m.CicloEscolar,4) AS INT),12,31) END AS SemFin
                FROM Pick p
                JOIN Operaciones.Materias m ON p.MateriaID = m.MateriaID
            ),
            Sessions AS (
                SELECT mi.InscripcionID, mi.AlumnoID, mi.MateriaID, mi.CursoID,
                    DATEADD(DAY, v.SessionOffset, mi.SemInicio) AS Fecha,
                    CASE WHEN (ABS(CHECKSUM(mi.InscripcionID + v.SessionOffset)) % 100) < 85 THEN 1 ELSE 0 END AS Presente -- Probabilidad de asistencia determinista (85% presente).
                FROM MatInfo mi
                CROSS APPLY (
                    SELECT TOP (@SessionsPerIns) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS SessionOffset
                    FROM dbo.Numbers
                ) v
                WHERE DATEADD(DAY, v.SessionOffset, mi.SemInicio) <= mi.SemFin
            )
            INSERT INTO Operaciones.Asistencias (InscripcionID, AlumnoID, CursoID, FechaAsistencia, Presente)
            SELECT s.InscripcionID, s.AlumnoID, s.CursoID, s.Fecha, s.Presente
            FROM Sessions s
            WHERE NOT EXISTS (
                SELECT 1 FROM Operaciones.Asistencias a
                WHERE a.InscripcionID = s.InscripcionID AND a.FechaAsistencia = s.Fecha
            );

            SET @RowsAsis = @@ROWCOUNT;
            SET @ProcessedIns += @ThisBatchAsis;

            INSERT INTO Control.LoadLog (RunNumber, Entidad, BatchOffset, RowsAffected, Estado, Fecha, Mensaje)
            VALUES (@CurrentRunAsis, 'Asistencias', @ProcessedIns, @RowsAsis, 'COMMIT', SYSUTCDATETIME(),
                    CONCAT('Iter=', @IterAsis, ' BatchIns=', @ThisBatchAsis, ' RowsAsis=', @RowsAsis));
            DECLARE @LogIDAsis INT = SCOPE_IDENTITY();

            COMMIT;

            DECLARE @EndBatchAsis DATETIME2 = SYSUTCDATETIME();
            DECLARE @DurationMsAsis INT = DATEDIFF(MILLISECOND, @StartBatchAsis, @EndBatchAsis);
            UPDATE Control.LoadLog SET DurationMs = @DurationMsAsis WHERE LoadLogID = @LogIDAsis;

            PRINT 'Asistencias insertadas en batch: ' + FORMAT(@RowsAsis,'N0') +
                ' | Total procesadas: ' + FORMAT(@ProcessedIns,'N0') +
                ' | Iter ' + CAST(@IterAsis AS VARCHAR(10));
            WAITFOR DELAY @PauseBetweenBatches;
        END TRY
        BEGIN CATCH
            IF XACT_STATE() <> 0 ROLLBACK;
            INSERT INTO Control.LoadLog (RunNumber, Entidad, BatchOffset, RowsAffected, Estado, Fecha, Mensaje)
            VALUES (@CurrentRunAsis, 'Asistencias', @ProcessedIns, @RowsAsis, 'ROLLBACK', SYSUTCDATETIME(), ERROR_MESSAGE());
            PRINT 'ERROR en batch Asistencias: ' + ERROR_MESSAGE();
            THROW;
        END CATCH;
    END
    PRINT 'Asistencias generadas totales (aprox): ' + CAST(@ProcessedIns * @SessionsPerIns AS VARCHAR(20));

--- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- -- > 13.  ACTUALIZACION (para control de FK en procesos posteriores).
--- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    -- Métricas resumidas
    INSERT INTO Control.Metrics (MetricDate, MetricName, MetricValue, Notes)
    VALUES (SYSUTCDATETIME(), 'TotalAlumnos', (SELECT COUNT(*) FROM Catalogos.Alumnos), 'Total alumnos en catálogo');

    INSERT INTO Control.Metrics (MetricDate, MetricName, MetricValue, Notes)
    VALUES (SYSUTCDATETIME(), 'TotalInscripciones', (SELECT COUNT(*) FROM Operaciones.Inscripciones), 'Total inscripciones');

    INSERT INTO Control.Metrics (MetricDate, MetricName, MetricValue, Notes)
    VALUES (SYSUTCDATETIME(), 'PromedioParcialesPorInscripcion', (SELECT AVG(Num) FROM (SELECT COUNT(*) AS Num FROM Operaciones.Calificaciones GROUP BY InscripcionID) t), 'Promedio de parciales por inscripción');

    INSERT INTO Control.Metrics (MetricDate, MetricName, MetricValue, Notes)
    VALUES (SYSUTCDATETIME(), 'PorcAsistenciaPromedio', (SELECT AVG(CAST(Presente AS FLOAT))*100.0 FROM Operaciones.Asistencias), 'Porcentaje promedio de asistencia');

    PRINT 'Checkpoints y métricas registradas en Control.Checkpoints y Control.Metrics';

---- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- -- 15. MÉTRICAS FINALES.
---- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- POR RUN.
    DECLARE @EndTime DATETIME2 = SYSUTCDATETIME();
    DECLARE @CntProf INT = (SELECT COUNT(*) FROM Catalogos.Profesores);
    DECLARE @CntDept INT = (SELECT COUNT(*) FROM Catalogos.Departamentos);
    DECLARE @CntAlu INT = (SELECT COUNT(*) FROM Catalogos.Alumnos);
    DECLARE @CntIns INT = (SELECT COUNT(*) FROM Operaciones.Inscripciones);
    DECLARE @CntCal INT = (SELECT COUNT(*) FROM Operaciones.Calificaciones);
    DECLARE @CntAsi INT = (SELECT COUNT(*) FROM Operaciones.Asistencias);

    PRINT 'Métricas Run: ' + CAST(@CurrentRun AS VARCHAR(3)) + ' Alumnos='+CAST(@CntAlu AS VARCHAR(12)) + ' Inscripciones=' + CAST(@CntIns AS VARCHAR(12)) + ' Calificaciones=' + CAST(@CntCal AS VARCHAR(12)) + ' Asistencias=' + CAST(@CntAsi AS VARCHAR(12));

-- Preparar siguiente run
    SET @CurrentRun += 1;
    -- Limpiar #NewIns para la siguiente iteración si se desea regenerar nuevas inscripciones en cada run.
    -- NOTA: durante pruebas deja las temp tables para inspección
    IF OBJECT_ID('tempdb..#Ciclos') IS NOT NULL DROP TABLE #Ciclos;
    IF OBJECT_ID('tempdb..#AluList') IS NOT NULL DROP TABLE #AluList;
    IF OBJECT_ID('tempdb..#NewIns') IS NOT NULL DROP TABLE #NewIns;
    IF OBJECT_ID('tempdb..#NewInsCal') IS NOT NULL DROP TABLE #NewInsCal;
    IF OBJECT_ID('tempdb..#ToProcessIns') IS NOT NULL DROP TABLE #ToProcessIns;
    IF OBJECT_ID('tempdb..#Cursos') IS NOT NULL DROP TABLE #Cursos;
    IF OBJECT_ID('tempdb..#Materias') IS NOT NULL DROP TABLE #Materias;
    IF OBJECT_ID('tempdb..#CarrList') IS NOT NULL DROP TABLE #CarrList;
    IF OBJECT_ID('tempdb..#ParcToInsert') IS NOT NULL DROP TABLE #ParcToInsert;
    

    INSERT INTO Control.LoadLog (RunNumber, Entidad, BatchOffset, RowsAffected, Estado, Mensaje, DurationMs)
    VALUES (@CurrentRun, 'Metrics', 0, @CntIns, 'COMMIT', CONCAT('Ins=',@CntIns,' Cal=',@CntCal,' Asi=',@CntAsi), NULL);
    PRINT '';
    PRINT '============================================================================';
    PRINT '         [OK] RESUMEN DE EJECUCION EXITOSA RUN ' + CAST(@CurrentRun AS VARCHAR(3)) + ' completada.';
    PRINT '============================================================================';
    PRINT '[OK] Alumnos Procesados:   ' + FORMAT(@CntAlu, 'N0');
    PRINT 'Departamentos Inyectados: ' + FORMAT(@CntDept, 'N0');
    PRINT 'Profesores Inyectados: ' + FORMAT(@CntProf, 'N0');
    PRINT 'Inscripciones Inyectadas: ' + FORMAT(@CntIns, 'N0');
    PRINT 'Calificaciones Inyectadas: ' + FORMAT(@CntCal, 'N0');
    PRINT 'Asistencias Inyectadas: ' + FORMAT(@CntAsi, 'N0');
    PRINT 'Materias Inyectadas:     ' + FORMAT(@InsertedMaterias, 'N0');
    PRINT 'Cursos Inyectados:    ' + FORMAT(@InsertedCursos, 'N0');
    PRINT 'Tiempo de Respuesta:  ' + FORMAT(DATEDIFF(MILLISECOND, @RunStart, SYSUTCDATETIME()), 'N0') + ' ms';
    PRINT 'Tiempo de Ejecucion: ' + FORMAT(DATEDIFF(MILLISECOND, @RunStart, @EndTime), 'N0') + ' ms';
    PRINT 'Finalizado el:        ' + CAST(SYSDATETIME() AS VARCHAR);
    PRINT '============================================================================';
    PRINT '';
    WAITFOR DELAY @PauseBetweenBatches;
    PRINT '--------------------Stress Test integrado finalizado-----------------------------------';
END
GO