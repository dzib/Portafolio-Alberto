PRINT 'QA-004 REFERENTIAL INTEGRITY';
 
SELECT *
FROM Operaciones.Inscripciones i
LEFT JOIN Catalogos.Alumnos a
ON a.AlumnoID = i.AlumnoID
WHERE a.AlumnoID IS NULL;