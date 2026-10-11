# Reglas de Negocio - Procesamiento Financiero

1. **Filtro de Transacciones Activas:** Solo se procesarán
   aquellas solicitudes de préstamo cuyo estado se encuentre
   registrado en el sistema core.
2. **Manejo de Montos:** Cualquier transacción con un monto
   menor o igual a cero (`amount <= 0`) será catalogada como
   anomalía y excluida de los agregados financieros.
3. **Persistencia y Reemplazo:** Las tablas agregadas
   financieras deben ser reemplazadas de manera atómica
   mediante instrucciones serverless para reflejar siempre la
   última foto oficial del cierre.
