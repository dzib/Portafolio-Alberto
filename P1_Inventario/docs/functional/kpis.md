# Indicadores Clave de Rendimiento (KPIs) - P1 Inventario

1. **Ingreso Total Consolidado:** Suma monetaria neta de todas las
   transacciones de mostrador y pedidos en línea (excluyendo
   estatus cancelados).
2. **Unidades Vendidas por Categoría:** Volumen de rotación de stock
   desglosado por dominios de negocio para identificar los
   departamentos con mayor tracción comercial.
3. **Semáforo Logístico de Inventario:**
   - *Reabastecimiento Urgente:* `StockActual <= StockMinimo`
   - *Stock Bajo:* `StockActual <= StockMinimo * 1.5`
   - *Saludable:* `StockActual > StockMinimo * 1.5`
