-- =====================================================
-- ATIVIDADE 02 - UC3: DA TEORIA À PRÁTICA COM SQL
-- Cenário: Loja Virtual
-- Autor: Luis Sousa
-- =====================================================

-- =======================
-- PARTE 1: CRIAÇÃO DO BANCO E TABELAS (DDL)
-- =======================

CREATE DATABASE LojaVirtual;
USE LojaVirtual;

-- =======================
-- TABELA CLIENTE
-- 3FN: Cada campo depende unicamente da chave primária.
-- =======================
CREATE TABLE Cliente (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE,
    endereco VARCHAR(200) NOT NULL
);

-- =======================
-- TABELA PRODUTO
-- 3FN: Nenhum campo depende de outro não-chave.
-- =======================
CREATE TABLE Produto (
    idProduto INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL
);

-- =======================
-- TABELA PEDIDO
-- Relacionamento N:1 com Cliente
-- =======================
CREATE TABLE Pedido (
    idPedido INT AUTO_INCREMENT PRIMARY KEY,
    dataPedido DATE NOT NULL,
    idCliente INT NOT NULL,
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
);

-- =======================
-- TABELA ITEMPEDIDO
-- Relação N:N resolvida entre Pedido e Produto
-- =======================
CREATE TABLE ItemPedido (
    idItem INT AUTO_INCREMENT PRIMARY KEY,
    idPedido INT NOT NULL,
    idProduto INT NOT NULL,
    quantidade INT NOT NULL,
    FOREIGN KEY (idPedido) REFERENCES Pedido(idPedido),
    FOREIGN KEY (idProduto) REFERENCES Produto(idProduto)
);

-- =======================
-- PARTE 2: INSERÇÃO DE DADOS (DML)
-- =======================

-- Inserindo Clientes
INSERT INTO Cliente (nome, cpf, email, endereco)
VALUES ('Ana Silva', '123.456.789-00', 'ana@email.com', 'Rua das Flores, 123'),
       ('Carlos Souza', '987.654.321-11', 'carlos@email.com', 'Av. Central, 45'),
       ('Marina Lima', '111.222.333-44', 'marina@email.com', 'Rua do Sol, 56');

-- Inserindo Produtos
INSERT INTO Produto (nome, preco, estoque)
VALUES ('Notebook', 3500.00, 10),
       ('Mouse Gamer', 120.00, 25),
       ('Teclado Mecânico', 250.00, 15);

-- Inserindo Pedidos
INSERT INTO Pedido (dataPedido, idCliente)
VALUES ('2025-11-10', 1),
       ('2025-11-11', 2),
       ('2025-11-12', 3);

-- Inserindo Itens dos Pedidos
INSERT INTO ItemPedido (idPedido, idProduto, quantidade)
VALUES (1, 1, 1),
       (1, 2, 2),
       (2, 3, 1);

-- =======================
-- TESTE DE INTEGRIDADE (NOT NULL)
-- =======================
-- Tentando inserir cliente sem nome (deve gerar erro)
-- INSERT INTO Cliente (cpf, email, endereco)
-- VALUES ('555.666.777-88', 'teste@email.com', 'Rua Sem Nome, 0');
-- >> Esperado: ERRO -> Campo 'nome' não pode ser nulo (NOT NULL constraint failed).

-- =======================
-- PARTE 3: ATUALIZAÇÃO DE DADOS (UPDATE)
-- =======================

-- Atualizando endereço de um cliente
UPDATE Cliente
SET endereco = 'Av. Brasil, 999'
WHERE idCliente = 2;

-- Aumentando o preço de um produto em 10%
UPDATE Produto
SET preco = preco * 1.10
WHERE idProduto = 1;

-- =======================
-- PARTE 4: EXCLUSÃO DE DADOS (DELETE)
-- =======================

-- Tentando remover um cliente com pedidos vinculados (deve gerar erro)
-- DELETE FROM Cliente WHERE idCliente = 1;
-- >> Esperado: ERRO -> Violação de integridade referencial (FK Pedido -> Cliente)

-- Solução: remover os registros dependentes primeiro
DELETE FROM ItemPedido WHERE idPedido IN (SELECT idPedido FROM Pedido WHERE idCliente = 1);
DELETE FROM Pedido WHERE idCliente = 1;
DELETE FROM Cliente WHERE idCliente = 1;

-- =======================
-- CONSULTA FINAL (VERIFICAÇÃO)
-- =======================
SELECT * FROM Cliente;
SELECT * FROM Produto;
SELECT * FROM Pedido;
SELECT * FROM ItemPedido;

-- =====================================================
-- FIM DO SCRIPT - TODAS AS ETAPAS DA ATIVIDADE 02 CONCLUÍDAS
-- Banco em 3ª Forma Normal (3FN) e com integridade referencial aplicada
-- =====================================================

-- ==============================================
-- TABELA FUNCIONARIOS - BANCO LojaVirtual
-- ==============================================

CREATE TABLE Funcionarios (
    idFuncionario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    salario DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Ativo'
);

-- ==============================================
-- INSERINDO DADOS DE EXEMPLO
-- ==============================================
INSERT INTO Funcionarios (nome, cargo, salario, status)
VALUES 
('João Mendes', 'Vendedor', 2500.00, 'Ativo'),
('Paula Rocha', 'Gerente', 4800.00, NULL),
('Rafaela Dias', 'Atendente', 2200.00, NULL),
('Marcos Silva', 'TI', 3200.00, 'Ativo');

-- ==============================================
-- 1️⃣ Verificar se há valores NULL
-- ==============================================
SELECT COUNT(*) AS total_nulos
FROM Funcionarios
WHERE status IS NULL;

-- Desativa o modo seguro nesta sessão
SET SQL_SAFE_UPDATES = 0;

-- ==============================================
-- 2️⃣ Atualizar valores NULL (se houver)
-- ==============================================
UPDATE Funcionarios
SET status = 'Ativo'
WHERE status IS NULL;

-- Reative o modo seguro (opcional, por segurança)
SET SQL_SAFE_UPDATES = 1;

-- ==============================================
-- 3️⃣ Adicionar restrição NOT NULL (MySQL)
-- ==============================================
ALTER TABLE Funcionarios
MODIFY COLUMN status VARCHAR(20) NOT NULL;

-- ==============================================
-- CONSULTA FINAL
-- ==============================================
SELECT * FROM Funcionarios;

