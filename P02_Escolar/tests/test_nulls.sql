PRINT 'QA-001 NULL VALIDATION';

SELECT *
FROM Operaciones.Alumnos
WHERE Nombre IS NULL
   OR MetaData_ETL IS NULL;

SELECT *
FROM Operaciones.Inscripciones
WHERE AlumnoID IS NULL
   OR MateriaID IS NULL;