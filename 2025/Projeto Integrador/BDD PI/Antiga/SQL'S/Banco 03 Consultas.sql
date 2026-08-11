USE restaurante_vegetariano01;

-- ====================================
-- CONSULTAS OTIMIZADAS / SEM REPETIÇÕES
-- Versão adaptada para restaurante_vegetariano01
-- ====================================

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


-- 11) Hora com maior volume de pedidos
SELECT 
    HOUR(data_hora) AS hora,
    COUNT(*) AS quantidade_pedidos
FROM Pedidos
GROUP BY HOUR(data_hora)
ORDER BY quantidade_pedidos DESC
LIMIT 1;


-- 12) Ticket médio por cliente
SELECT 
    c.id_cliente,
    c.nome,
    ROUND(AVG(pag.valor), 2) AS ticket_medio
FROM Pagamentos pag
JOIN Pedidos ped ON ped.id_pedido = pag.id_pedido
LEFT JOIN Clientes c ON c.id_cliente = ped.id_cliente
GROUP BY c.id_cliente, c.nome
ORDER BY ticket_medio DESC;


-- 13) Clientes com preço médio de itens > 30
SELECT 
    c.id_cliente,
    c.nome,
    ROUND(AVG(it.preco_unitario), 2) AS preco_medio
FROM Clientes c
JOIN Pedidos ped ON ped.id_cliente = c.id_cliente
JOIN ItensPedido it ON it.id_pedido = ped.id_pedido
GROUP BY c.id_cliente, c.nome
HAVING preco_medio > 30
ORDER BY preco_medio DESC;


-- 14) Relação de preferência alimentar e pratos (ex.: id_preferencia = 1)
SELECT 
    pr.id_prato,
    pr.nome,
    COUNT(*) AS vezes_comprado
FROM ClientePreferencia cp
JOIN Pedidos ped ON ped.id_cliente = cp.id_cliente
JOIN ItensPedido it ON it.id_pedido = ped.id_pedido
JOIN Pratos pr ON pr.id_prato = it.id_prato
WHERE cp.id_preferencia = 1
GROUP BY pr.id_prato, pr.nome
ORDER BY vezes_comprado DESC;


-- 15) Ranking de fornecedores por entregas
SELECT 
    f.id_fornecedor,
    f.nome,
    COUNT(*) AS entregas
FROM MovimentosEstoque me
JOIN Fornecedores f ON f.id_fornecedor = me.id_fornecedor
WHERE me.tipo = 'entrada'
GROUP BY f.id_fornecedor, f.nome
ORDER BY entregas DESC;


-- 16) Ingredientes com estoque abaixo de 5
SELECT nome, saldo_atual
FROM (
    SELECT
        ing.id_ingrediente,
        ing.nome,
        COALESCE(SUM(
            CASE me.tipo
                WHEN 'entrada' THEN me.quantidade
                WHEN 'saida' THEN -me.quantidade
                WHEN 'ajuste' THEN me.quantidade
            END
        ),0) AS saldo_atual
    FROM Ingredientes ing
    LEFT JOIN MovimentosEstoque me ON me.id_ingrediente = ing.id_ingrediente
    GROUP BY ing.id_ingrediente, ing.nome
) AS s
WHERE saldo_atual < 5
ORDER BY saldo_atual ASC;


-- 17) Receita, custo e lucro por categoria
SELECT 
    cat.id_categoria,
    cat.nome AS categoria,
    ROUND(SUM(it.quantidade * it.preco_unitario), 2) AS receita,
    ROUND(SUM(it.quantidade * COALESCE(it.custo_estimado, cp.custo_total)), 2) AS custo,
    ROUND(SUM((it.quantidade * it.preco_unitario) - (it.quantidade * COALESCE(it.custo_estimado, cp.custo_total))), 2) AS lucro
FROM ItensPedido it
JOIN Pratos pr ON pr.id_prato = it.id_prato
JOIN Categorias cat ON cat.id_categoria = pr.id_categoria
LEFT JOIN vw_custo_prato cp ON cp.id_prato = pr.id_prato
GROUP BY cat.id_categoria, cat.nome
ORDER BY lucro DESC;


-- 18) Custo dos ingredientes usados por mês
SELECT 
    MONTH(ped.data_hora) AS mes,
    ROUND(SUM(cp.custo_total * it.quantidade), 2) AS custo_total
FROM ItensPedido it
JOIN Pedidos ped ON ped.id_pedido = it.id_pedido
LEFT JOIN vw_custo_prato cp ON cp.id_prato = it.id_prato
GROUP BY MONTH(ped.data_hora)
ORDER BY mes;


-- 19) Resumo geral por pedido
SELECT 
    ped.id_pedido,
    DATE(ped.data_hora) AS data,
    c.nome AS cliente,
    COALESCE(pl.nome, 'Interno') AS plataforma,
    SUM(it.quantidade) AS total_itens,
    ROUND(SUM(it.quantidade * it.preco_unitario), 2) AS receita
FROM Pedidos ped
LEFT JOIN Clientes c ON c.id_cliente = ped.id_cliente
LEFT JOIN Plataformas pl ON pl.id_plataforma = ped.id_plataforma
JOIN ItensPedido it ON it.id_pedido = ped.id_pedido
GROUP BY ped.id_pedido, DATE(ped.data_hora), c.nome, pl.nome
ORDER BY data DESC;


-- 20) 5 pratos com menor margem
SELECT 
    m.prato AS prato, 
    ROUND(m.receita_total, 2) AS receita_total, 
    ROUND(m.custo_total, 2) AS custo_total, 
    ROUND(m.lucro_bruto, 2) AS lucro_bruto, 
    ROUND(m.margem_percentual, 2) AS margem_percentual
FROM vw_margem_lucro m
ORDER BY margem_percentual ASC
LIMIT 5;


-- 21) Clientes com mais pedidos
SELECT 
    c.id_cliente,
    c.nome,
    COUNT(p.id_pedido) AS total_pedidos
FROM Clientes c
JOIN Pedidos p ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome
ORDER BY total_pedidos DESC;

USE restaurante_terraviva;
SHOW TABLES;
SHOW FULL TABLES WHERE TABLE_TYPE='VIEW';
SHOW FUNCTION STATUS WHERE Db='restaurante_terraviva';
SHOW TRIGGERS;
SHOW PROCEDURE STATUS WHERE Db='restaurante_terraviva';
SELECT TABLE_NAME, INDEX_NAME FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA='restaurante_terraviva';
