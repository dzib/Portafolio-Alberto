# Reglas de Negocio - P2 Escolar

1. **BR-01 (Rangos de Inscripción):** Un alumno con estatus
   `REGULAR` puede inscribir de 6 a 7 materias, mientras que un
   alumno en `IRREGULAR` se limita de 3 a 5 materias por adeudos o
   materias reprobadas.
2. **BR-02 (Control de Identidad en Pruebas):** El comando
   `DBCC CHECKIDENT` debe ejecutarse en los scripts de estrés para
   reestablecer los contadores a 0 y garantizar entornos de prueba
   repetibles.
3. **BR-03 (Normalización Numérica):** Los promedios académicos
   deben ser convertidos y acotados mediante funciones de control
   (`ABS`, `FLOOR`) para evitar desbordamientos aritméticos o
   escalas erróneas en el reporte BI.
