PRINT 'QA-003 BUSINESS RULES';

SELECT *
FROM Operaciones.Calificaciones
WHERE NotaFinal < 0
   OR NotaFinal > 10;

SELECT *
FROM Catalogos.Alumnos
WHERE Estatus IS NULL;

-- Un alumno egresado no debe tener materias activas
 
SELECT *
FROM Operaciones.Inscripciones i
JOIN Catalogos.Alumnos a
ON a.AlumnoID = i.AlumnoID
WHERE a.MetaData_ETL LIKE '%EGRESADO%';