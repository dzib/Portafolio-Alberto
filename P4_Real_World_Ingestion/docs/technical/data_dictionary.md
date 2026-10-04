# 📖 Diccionario de Datos - P4_Real_World_Ingestion

<!-- markdownlint-disable MD013 -->

|        Columna         |     Tipo      | Restricciones |           Descripción           |
| :--------------------: | :-----------: | :-----------: | :-----------------------------: |
|        Order_Id        |      INT      | PK, NOT NULL  | Identificador único de la orden |
|       Order_Date       |   DATETIME2   |   NOT NULL    |     Fecha y hora de emisión     |
|         Sales          | DECIMAL(10,2) |   NOT NULL    |     Monto total de la venta     |
| Order_Profit_Per_Order | DECIMAL(10,2) |   NOT NULL    |     Ganancia neta por orden     |
|    Delivery_Status     |  VARCHAR(50)  |   NOT NULL    |     Estado actual del envío     |
|       Is_Anomaly       |      BIT      |   DEFAULT 0   |  Anomalía detectada en el ETL   |

<!-- markdownlint-enable MD013 -->
