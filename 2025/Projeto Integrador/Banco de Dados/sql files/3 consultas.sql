-- ============================================================
-- Consultas otimizadas / relatórios / verificação
-- ============================================================
USE restaurante_terraviva;

-- 1) Lista clientes e seus pedidos
SELECT 
    c.id_cliente,
    c.nome, 
    c.email, 
    p.id_pedido, 
    p.data_hora, 
    p.status
FROM Clientes c
LEFT JOIN Pedidos p ON p.id_cliente = c.id_cliente
ORDER BY c.nome, p.data_hora DESC;

-- 2) Itens dos pedidos
SELECT 
    ped.id_pedido,
    c.nome AS cliente,
    pr.nome AS prato,
    it.quantidade,
    it.preco_unitario,
    ROUND(it.quantidade * it.preco_unitario, 2) AS subtotal
FROM ItensPedido it
JOIN Pedidos ped ON ped.id_pedido = it.id_pedido
LEFT JOIN Clientes c ON c.id_cliente = ped.id_cliente
JOIN Pratos pr ON pr.id_prato = it.id_prato
ORDER BY ped.id_pedido;

-- 3) Composição dos pratos
SELECT 
    p.nome AS prato, 
    ing.nome AS ingrediente, 
    pi.quantidade,
    ing.unidade_medida
FROM PratoIngrediente pi
JOIN Pratos p ON p.id_prato = pi.id_prato
JOIN Ingredientes ing ON ing.id_ingrediente = pi.id_ingrediente
ORDER BY p.nome, ing.nome;

-- 4) Saldo atual de estoque
SELECT
    ing.id_ingrediente,
    ing.nome,
    ROUND(COALESCE(SUM(
        CASE me.tipo
            WHEN 'entrada' THEN me.quantidade
            WHEN 'saida' THEN -me.quantidade
            WHEN 'ajuste' THEN me.quantidade
        END
    ), 0), 3) AS saldo_atual
FROM Ingredientes ing
LEFT JOIN MovimentosEstoque me ON me.id_ingrediente = ing.id_ingrediente
GROUP BY ing.id_ingrediente, ing.nome
ORDER BY ing.nome;

-- 5) Custo atual do ingrediente
SELECT 
    ing.id_ingrediente,
    ing.nome,
    (
        SELECT c.valor
        FROM CustoIngredienteHistorico c
        WHERE c.id_ingrediente = ing.id_ingrediente
        ORDER BY c.data DESC 
        LIMIT 1
    ) AS custo_atual
FROM Ingredientes ing
ORDER BY ing.nome;

-- 6) Custo total dos pratos (via view vw_custo_prato)
SELECT id_prato, nome, custo_total
FROM vw_custo_prato
ORDER BY nome;

-- 7) Receita total por dia
SELECT 
    DATE(pag.data_hora) AS dia, 
    ROUND(SUM(pag.valor), 2) AS receita
FROM Pagamentos pag
GROUP BY DATE(pag.data_hora)
ORDER BY dia DESC;

-- 8) Pedidos e receita por plataforma
SELECT 
    COALESCE(pl.nome, 'Interno') AS plataforma,
    COUNT(DISTINCT ped.id_pedido) AS total_pedidos,
    ROUND(SUM(pag.valor), 2) AS receita_total
FROM Pagamentos pag
JOIN Pedidos ped ON ped.id_pedido = pag.id_pedido
LEFT JOIN Plataformas pl ON pl.id_plataforma = ped.id_plataforma
GROUP BY plataforma
ORDER BY receita_total DESC;

-- 9) Margem de lucro por prato
SELECT 
    m.prato AS prato,
    ROUND(m.receita_total, 2) AS receita_total,
    ROUND(m.custo_total, 2) AS custo_total,
    ROUND(m.lucro_bruto, 2) AS lucro_bruto,
    ROUND(m.margem_percentual, 2) AS margem_percentual
FROM vw_margem_lucro m
ORDER BY lucro_bruto DESC;

-- 10) Ranking de pratos mais vendidos
SELECT prato, total_quantidade
FROM vw_vendas_por_prato
ORDER BY total_quantidade DESC
LIMIT 10;


-- Verificações/diagnósticos do schema
SHOW TABLES;
SHOW FULL TABLES WHERE TABLE_TYPE='VIEW';
SHOW FUNCTION STATUS WHERE Db='restaurante_terraviva';
SHOW TRIGGERS;
SHOW PROCEDURE STATUS WHERE Db='restaurante_terraviva';
SELECT TABLE_NAME, INDEX_NAME FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA='restaurante_terraviva';
