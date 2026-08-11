-- ===========================================
-- BANCO DE DADOS: empresa_db
-- TABELA: Cliente
-- Normalizada até 3FN
-- ===========================================

-- 1️⃣ Criar o banco de dados
CREATE DATABASE IF NOT EXISTS empresa_db;
USE empresa_db;

-- 2️⃣ Criar tabela Cliente
CREATE TABLE Cliente (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    cpf VARCHAR(11) NOT NULL UNIQUE,
    telefone VARCHAR(15),
    data_cadastro DATE NOT NULL DEFAULT (CURRENT_DATE),
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

-- 3️⃣ Inserir registros de exemplo
INSERT INTO Cliente (nome, email, cpf, telefone)
VALUES
('Ana Souza', 'ana.souza@email.com', '12345678901', '11987654321'),
('Carlos Pereira', 'carlos.pereira@email.com', '98765432100', NULL),
('Beatriz Lima', 'beatriz.lima@email.com', '74185296300', '11911223344');

-- 4️⃣ Testes de unicidade
-- ✅ este falha (email duplicado)
-- INSERT INTO Cliente (nome, email, cpf) VALUES ('Maria', 'ana.souza@email.com', '11122233344');

-- 5️⃣ Consultas simples
SELECT * FROM Cliente;
SELECT nome, email FROM Cliente WHERE ativo = TRUE;

-- ===========================================
-- Tabela: Produto
-- Normalizada e com restrições CHECK
-- ===========================================
CREATE TABLE Produto (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(150) NOT NULL,
    descricao TEXT NOT NULL,
    preco DECIMAL(10,2) NOT NULL CHECK (preco > 0),
    estoque INT NOT NULL CHECK (estoque >= 0),
    codigo_barras VARCHAR(13) UNIQUE,
    data_cadastro DATE NOT NULL DEFAULT (CURRENT_DATE)
);

-- ===========================================
-- Tabela: Pedido
-- FK referenciando Cliente
-- ===========================================
CREATE TABLE Pedido (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    data_pedido DATE NOT NULL DEFAULT (CURRENT_DATE),
    valor_total DECIMAL(10,2) NOT NULL CHECK (valor_total > 0),
    status VARCHAR(20) NOT NULL DEFAULT 'Pendente',
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id)
);

-- Inserir produtos
INSERT INTO Produto (nome_produto, descricao, preco, estoque, codigo_barras)
VALUES
('Notebook Lenovo', 'Notebook 15" com 8GB RAM', 3500.00, 10, '1234567890123'),
('Mouse Sem Fio', 'Mouse óptico sem fio Logitech', 120.00, 25, '9876543210987'),
('Monitor 24"', 'Monitor Full HD 24 polegadas', 950.00, 5, '7418529630012');

-- Inserir pedidos (assumindo clientes já criados)
INSERT INTO Pedido (id_cliente, valor_total, status)
VALUES
(1, 3500.00, 'Pago'),
(2, 1070.00, 'Pendente');

-- Listar pedidos com nome do cliente
SELECT p.id AS id_pedido, c.nome AS cliente, p.valor_total, p.status
FROM Pedido p
JOIN Cliente c ON p.id_cliente = c.id;

-- Verificar estoque abaixo de 5 unidades
SELECT nome_produto, estoque FROM Produto WHERE estoque < 5;

SELECT * FROM Cliente;
SELECT * FROM Produto;
SELECT * FROM Pedido;
