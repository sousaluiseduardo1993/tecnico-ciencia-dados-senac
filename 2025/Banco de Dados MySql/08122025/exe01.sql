-- ============================================================
-- 🏪 PROJETO: Loja Virtual - Script Completo MySQL Workbench
-- ============================================================

-- ============================================================
-- 1️ CRIAÇÃO DO BANCO DE DADOS
-- ============================================================

DROP DATABASE IF EXISTS loja_virtual;
CREATE DATABASE loja_virtual;
USE loja_virtual;

-- ============================================================
-- 2️ CRIAÇÃO DAS TABELAS (DDL)
-- ============================================================

-- Tabela de Clientes
CREATE TABLE clientes (
    cliente_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cidade VARCHAR(50),
    data_cadastro DATE DEFAULT (CURRENT_DATE)
);

-- Tabela de Produtos
CREATE TABLE produtos (
    produto_id INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50),
    preco DECIMAL(10,2) NOT NULL CHECK (preco > 0),
    estoque INT NOT NULL CHECK (estoque >= 0)
);

-- Tabela de Vendas (com chaves estrangeiras)
CREATE TABLE vendas (
    venda_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    data_venda DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id),
    FOREIGN KEY (produto_id) REFERENCES produtos(produto_id)
);

-- ============================================================
-- 3️ INSERÇÃO DE DADOS (DML)
-- ============================================================

INSERT INTO clientes (nome, email, cidade) VALUES
('João Silva', 'joao@email.com', 'São Paulo'),
('Maria Souza', 'maria@email.com', 'Rio de Janeiro'),
('Pedro Costa', 'pedro@email.com', 'Belo Horizonte'),
('Ana Lima', 'ana@email.com', 'Curitiba'),
('Luiza Melo', 'luiza@email.com', 'Porto Alegre');

INSERT INTO produtos (nome_produto, categoria, preco, estoque) VALUES
('Notebook X', 'Eletrônicos', 4500.00, 10),
('Mouse Gamer', 'Acessórios', 150.00, 50),
('Teclado Mecânico', 'Acessórios', 350.00, 30),
('Cadeira Ergonômica', 'Móveis', 1200.00, 20),
('Monitor 27\"', 'Eletrônicos', 1800.00, 15);

INSERT INTO vendas (cliente_id, produto_id, quantidade) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 1),
(4, 4, 1),
(5, 5, 1);

-- ============================================================
-- 4️ CONSULTAS DE TESTE (SELECT)
-- ============================================================

-- Ver todos os dados
SELECT * FROM clientes;
SELECT * FROM produtos;
SELECT * FROM vendas;

-- Consultas com filtros
SELECT * FROM clientes WHERE cidade = 'São Paulo';
SELECT * FROM produtos WHERE preco > 1000;
SELECT * FROM vendas WHERE quantidade >= 2;

-- Consulta com JOIN entre tabelas

SELECT 
    v.venda_id,
    c.nome AS cliente,
    p.nome_produto,
    v.quantidade,
    p.preco,
    (v.quantidade * p.preco) AS valor_gasto,
    v.data_venda
FROM vendas v
JOIN clientes c ON v.cliente_id = c.cliente_id
JOIN produtos p ON v.produto_id = p.produto_id
ORDER BY v.venda_id;

-- ============================================================
-- 5️ TESTES DE ATUALIZAÇÃO E EXCLUSÃO (UPDATE / DELETE)
-- ============================================================

-- ⚙️ Desativa modo seguro para evitar erro 1175
SET SQL_SAFE_UPDATES = 0;

-- Atualizar preço dos produtos da categoria "Acessórios"
UPDATE produtos
SET preco = preco * 1.10
WHERE categoria = 'Acessórios';

-- Excluir venda específica
DELETE FROM vendas WHERE venda_id = 3;

-- ⚙️ Reativa modo seguro
SET SQL_SAFE_UPDATES = 1;

-- ============================================================
-- 6️ PAPÉIS E PERMISSÕES (DCL)
-- ============================================================

-- Criar papéis (roles)
CREATE ROLE IF NOT EXISTS role_vendedor;
CREATE ROLE IF NOT EXISTS role_analista_bi;
CREATE ROLE IF NOT EXISTS role_dba;

-- Criar usuários fictícios (para testes)
CREATE USER IF NOT EXISTS 'vendedor'@'localhost' IDENTIFIED BY 'senha123';
CREATE USER IF NOT EXISTS 'analista_bi'@'localhost' IDENTIFIED BY 'senha123';
CREATE USER IF NOT EXISTS 'dba'@'localhost' IDENTIFIED BY 'senha123';

-- Associar papéis aos usuários
GRANT role_vendedor TO 'vendedor'@'localhost';
GRANT role_analista_bi TO 'analista_bi'@'localhost';
GRANT role_dba TO 'dba'@'localhost';

-- Conceder privilégios aos papéis
-- 🧾 VENDEDOR: pode ver clientes e registrar vendas
GRANT SELECT ON loja_virtual.clientes TO role_vendedor;
GRANT SELECT, INSERT ON loja_virtual.vendas TO role_vendedor;

-- 📊 ANALISTA BI: apenas leitura
GRANT SELECT ON loja_virtual.* TO role_analista_bi;

-- 🧙 DBA: acesso total
GRANT ALL PRIVILEGES ON loja_virtual.* TO role_dba;

-- ============================================================
-- 7️ VALIDAÇÃO DE PERMISSÕES
-- ============================================================

SHOW TABLES;
SHOW GRANTS FOR role_vendedor;
SHOW GRANTS FOR role_analista_bi;
SHOW GRANTS FOR role_dba;

SHOW GRANTS FOR 'vendedor'@'localhost';
SHOW GRANTS FOR 'analista_bi'@'localhost';
SHOW GRANTS FOR 'dba'@'localhost';

-- ============================================================
-- 8️ TESTES DE PAPÉIS (opcional)
-- ============================================================

-- Ativar papel e testar permissões manualmente:
-- SET ROLE role_vendedor;
-- SELECT * FROM clientes; -- OK
-- INSERT INTO vendas (cliente_id, produto_id, quantidade) VALUES (1,2,1); -- OK
-- DELETE FROM produtos; -- ❌ deve falhar

-- SET ROLE role_analista_bi;
-- SELECT * FROM vendas; -- OK
-- UPDATE produtos SET preco = 10; -- ❌ deve falhar

-- SET ROLE role_dba;
-- DROP TABLE vendas; -- ⚠️ permitido, use com cuidado

-- ============================================================
-- 9️ FIM DO SCRIPT
-- ============================================================
