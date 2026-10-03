# Guía de Resolución de Problemas (Troubleshooting) - P2

- **Incidencia 1: Desbordamiento Aritmético en
  Calificaciones.**
  - *Causa:* Valores generados superiores a `99.99` al calcular
    notas aleatorias que exceden la precisión `DECIMAL(4,2)`.
  - *Solución:* Verificar que la lógica del script de estrés utilice
    operadores de módulo y bloques `TRY...CATCH` con rollback
    automático.
- **Incidencia 2: Inconsistencia en Llaves Foráneas durante
  Pruebas de Estrés.**
  - *Causa:* Ejecuciones repetidas de inserción sin limpiar los
    contadores `IDENTITY`.
  - *Solución:* Asegurar la implementación mandatoria de
    `DBCC CHECKIDENT ('Tabla', RESEED, 0)` antes de cada carga
    masiva.
