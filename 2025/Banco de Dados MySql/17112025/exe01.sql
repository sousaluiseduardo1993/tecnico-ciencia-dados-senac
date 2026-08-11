-- ============================================================
-- BANCO DE DADOS PARA ATIVIDADE: SUBQUERIES - PARTE 1
-- ============================================================

CREATE DATABASE plataforma_pedidos;
USE plataforma_pedidos;

-- ============================================================
-- TABELAS
-- ============================================================

-- Clientes
CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY,
    nome VARCHAR(100)
);

-- Pedidos
CREATE TABLE pedidos (
    id_pedido INT PRIMARY KEY,
    fk_id_cliente INT,
    valor_total DECIMAL(10,2),
    FOREIGN KEY (fk_id_cliente) REFERENCES clientes(id_cliente)
);

-- ============================================================
-- INSERTS DE EXEMPLO
-- ============================================================
INSERT INTO clientes (id_cliente, nome) VALUES
(1, 'Ana'),
(2, 'Bruno'),
(3, 'Carla'),
(4, 'Diego');

INSERT INTO pedidos (id_pedido, fk_id_cliente, valor_total) VALUES
(101, 1, 150.00),
(102, 1, 200.00), 
(103, 2, 100.00), 
(104, 3, 300.00), 
(105, 4, 50.00),  
(106, 4, 80.00);  

-- ============================================================
-- ATIVIDADE PRINCIPAL:
-- "Listar todos os clientes que fizeram um valor total de compra
-- ACIMA da média geral de todos os pedidos."
-- ============================================================

-- Passo 1: Calcular média geral dos pedidos (subquery de linha única)
-- SELECT AVG(valor_total) FROM pedidos;

-- Passo 2 e 3: Agrupamento + HAVING com subquery
SELECT 
    c.nome,
    SUM(p.valor_total) AS total_cliente
FROM clientes c
JOIN pedidos p ON p.fk_id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome
HAVING SUM(p.valor_total) > (
    SELECT AVG(valor_total)
    FROM pedidos
)
ORDER BY total_cliente DESC;
