-- ==========================================
-- PROJETO: BANCO DE DADOS LOJA DE CALÇADOS
-- Atividade: Ciclo de Vida + SQL + KPI
-- ==========================================


-- ==========================================
-- 1 - CRIAÇÃO DO BANCO DE DADOS
-- ==========================================

DROP DATABASE IF EXISTS loja_calcados;
CREATE DATABASE loja_calcados;

USE loja_calcados;


-- ==========================================
-- 2 - CRIAÇÃO DAS TABELAS
-- ==========================================


-- TABELA CLIENTES
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    email VARCHAR(150) UNIQUE,
    data_cadastro DATE
);


-- TABELA PRODUTOS
CREATE TABLE produtos (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(150) NOT NULL,
    categoria VARCHAR(100),
    tamanho INT,
    preco_unitario DECIMAL(10,2) NOT NULL
);


-- TABELA REGIOES
CREATE TABLE regioes (
    id_regiao INT AUTO_INCREMENT PRIMARY KEY,
    nome_regiao VARCHAR(100) NOT NULL
);


-- TABELA VENDAS
CREATE TABLE vendas (
    id_venda INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT,
    produto_id INT,
    regiao_id INT,
    data_venda DATE,
    quantidade INT,
    valor_unitario DECIMAL(10,2),

    FOREIGN KEY (cliente_id) REFERENCES clientes(id_cliente),
    FOREIGN KEY (produto_id) REFERENCES produtos(id_produto),
    FOREIGN KEY (regiao_id) REFERENCES regioes(id_regiao)
);



-- ==========================================
-- 3 - INSERÇÃO DE DADOS DE EXEMPLO
-- ==========================================


-- CLIENTES
INSERT INTO clientes (nome, cpf, email, data_cadastro) VALUES
('Ana Silva','12345678900','ana@email.com', CURRENT_TIMESTAMP),
('Bruno Lima','98765432100','bruno@email.com', CURRENT_TIMESTAMP),
('Carla Souza','45612378900','carla@email.com', CURRENT_TIMESTAMP),
('Daniel Alves','74125896300','daniel@email.com', CURRENT_TIMESTAMP),
('Fernanda Rocha','36925814700','fernanda@email.com', CURRENT_TIMESTAMP);



-- PRODUTOS
INSERT INTO produtos (nome_produto, categoria, tamanho, preco_unitario) VALUES
('Tênis Esportivo','Tênis',40,199.90),
('Sandália Verão','Sandália',37,89.90),
('Bota Couro','Bota',41,299.90),
('Sapato Social','Sapato',42,249.90),
('Chinelo Casual','Chinelo',39,49.90);



-- REGIÕES
INSERT INTO regioes (nome_regiao) VALUES
('Sudeste'),
('Sul'),
('Nordeste'),
('Centro-Oeste'),
('Norte');



-- VENDAS
INSERT INTO vendas (cliente_id, produto_id, regiao_id, data_venda, quantidade, valor_unitario) VALUES
(1,1,1,'2026-01-10',1,199.90),
(2,2,1,'2026-01-15',2,89.90),
(3,3,2,'2026-02-05',1,299.90),
(1,2,3,'2026-02-20',3,89.90),
(2,1,3,'2026-03-01',1,199.90),
(3,1,2,'2026-03-12',2,199.90),
(4,4,4,'2026-03-20',1,249.90),
(5,5,5,'2026-03-25',4,49.90),
(1,3,1,'2026-04-05',1,299.90),
(2,4,2,'2026-04-15',2,249.90);



-- ==========================================
-- 4 - CRIAÇÃO DA VIEW ANALÍTICA
-- ==========================================

CREATE VIEW vw_vendas_por_regiao_mes AS

SELECT
    r.nome_regiao AS regiao,

    YEAR(v.data_venda) AS ano,

    MONTH(v.data_venda) AS mes,

    SUM(v.quantidade * v.valor_unitario) AS total_vendido,

    AVG(v.quantidade * v.valor_unitario) AS ticket_medio,

    COUNT(v.id_venda) AS total_pedidos

FROM vendas v

JOIN regioes r
ON v.regiao_id = r.id_regiao

WHERE YEAR(v.data_venda) = YEAR(CURDATE())

GROUP BY
    r.nome_regiao,
    YEAR(v.data_venda),
    MONTH(v.data_venda)

ORDER BY
    ano,
    mes;



-- ==========================================
-- 5 - CONSULTA FINAL (KPI ANALÍTICO)
-- ==========================================

SELECT * FROM vw_vendas_por_regiao_mes;