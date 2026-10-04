# 📖 Diccionario de Datos - P3_Retail_Ventas

<!-- markdownlint-disable MD013 -->

|     Columna      | Tipo de Dato  |      Restricciones      |               Descripción               |
| :--------------: | :-----------: | :---------------------: | :-------------------------------------: |
|  TransaccionID   |      INT      | PK, NOT IDENTITY (Bulk) |  Identificador único de la transacción  |
| FechaTransaccion |   DATETIME2   |        NOT NULL         |        Fecha y hora de la venta         |
|     Vendedor     | VARCHAR(100)  |        NOT NULL         |  Nombre completo del agente de ventas   |
|    MetodoPago    |  VARCHAR(50)  |        NOT NULL         | Pago: Efectivo, Tarjeta o Transferencia |
|    TotalVenta    | DECIMAL(10,2) |        NOT NULL         | Monto total de la transacción comercial |

<!-- markdownlint-enable MD013 -->
