SELECT 
    c.nome AS Cliente,
    p.idPedido AS Pedido,
    pr.nome AS Produto,
    i.quantidade,
    pr.preco,
    (i.quantidade * pr.preco) AS TotalItem,
    p.dataPedido
FROM Cliente AS c
INNER JOIN Pedido AS p ON c.idCliente = p.idCliente
INNER JOIN ItemPedido AS i ON p.idPedido = i.idPedido
INNER JOIN Produto AS pr ON i.idProduto = pr.idProduto
ORDER BY c.nome, p.idPedido;
