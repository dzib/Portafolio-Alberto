PRINT 'QA-002 DUPLICATE VALIDATION';

SELECT
    AlumnoID,
    COUNT(*) Total
FROM Catalogos.Alumnos
GROUP BY AlumnoID
HAVING COUNT(*) > 1;

SELECT
    Email,
    COUNT(*) Total
FROM Catalogos.Alumnos
GROUP BY Email
HAVING COUNT(*) > 1;