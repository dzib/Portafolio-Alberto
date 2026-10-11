PRINT 'QA-004 REFERENTIAL INTEGRITY';

SELECT
    p.PedidoID
FROM Operaciones.Pedidos p
LEFT JOIN Operaciones.Clientes c
ON c.ClienteID = p.ClienteID
WHERE c.ClienteID IS NULL;