# Reglas de Negocio - P1 Inventario

1. **BR-01 (Validación de Stock):** Ningún producto puede tener un
   precio de venta ni un stock actual menor a cero
   (`CHECK CONSTRAINT`).
   - Todo producto debe poseer identificador único.
   - El stock no puede ser negativo.
   - El precio unitario debe ser mayor que cero.

2. **BR-02 (Eliminación Lógica vs Física):** Los proveedores
   inactivos se manejan mediante borrado lógico (`IsActive = 0`)
   para preservar el historial de auditoría de los pedidos
   asociados.
   - Los productos eliminados lógicamente no deben aparecer en
     los dashboards de inventario.
   - Todo pedido debe estar asociado a un cliente válido.
   - No se permiten registros huérfanos entre entidades relacionadas
   - Los campos compuestos deberán ser normalizados previo a la explotación analítica.

3. **BR-03 (Estandarización Regional):** Las sucursales y
   ubicaciones geográficas deben corregir automáticamente
   abreviaturas locales (ej. `YUC` ➔ `Yucatán`, `QRO` ➔
   `Querétaro`) para evitar la fragmentación de métricas en los
   dashboards.

4. **BR-04 (Consolidación de Canales):** Las ventas en mostrador
   y los pedidos en línea se unifican bajo una misma regla de
   negocio de ingresos, descartando explícitamente aquellos
   pedidos con estatus de cancelación.
