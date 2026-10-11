# Diccionario de Datos

## Inventario.Productos

| Campo          | Tipo          | Descripción         |
| -------------- | ------------- | ------------------- |
| ProductoID     | INT           | Identificador único |
| NombreProducto | VARCHAR(100)  | Nombre comercial    |
| Categoria      | VARCHAR(50)   | Categoría           |
| Precio         | DECIMAL(10,2) | Precio unitario     |

---

## Operaciones.Clientes

| Campo     | Tipo         | Descripción        |
| --------- | ------------ | ------------------ |
| ClienteID | INT          | Cliente            |
| Nombre    | VARCHAR(100) | Nombre completo    |
| Ciudad    | VARCHAR(100) | Ciudad normalizada |

---

## Operaciones.Pedidos

| Campo       | Tipo          | Descripción      |
| ----------- | ------------- | ---------------- |
| PedidoID    | INT           | Pedido           |
| ClienteID   | INT           | Cliente asociado |
| FechaPedido | DATE          | Fecha            |
| Total       | DECIMAL(12,2) | Importe          |
