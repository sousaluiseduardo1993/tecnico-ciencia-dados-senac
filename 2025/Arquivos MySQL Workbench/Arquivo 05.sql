-- ============================================
-- DATABASE
-- ============================================
CREATE DATABASE IF NOT EXISTS restaurante_vegano
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE restaurante_vegano;

-- ============================================================
-- SCHEMA COMPLETO – TABELAS BASE (100% MODELADAS EM 4FN)
-- ============================================================

-- ============================
-- A) CLIENTES
-- ============================

CREATE TABLE Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(150) UNIQUE,
    telefone VARCHAR(20),
    data_cadastro DATE NOT NULL
);

CREATE TABLE PreferenciasAlimentares (
    id_preferencia INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(120) NOT NULL
);

CREATE TABLE ClientePreferencia (
    id_cliente INT NOT NULL,
    id_preferencia INT NOT NULL,
    PRIMARY KEY (id_cliente, id_preferencia),
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    FOREIGN KEY (id_preferencia) REFERENCES PreferenciasAlimentares(id_preferencia)
);

-- ============================
-- B) CARDÁPIO
-- ============================

CREATE TABLE Categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE Pratos (
    id_prato INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    descricao TEXT,
    preco_base DECIMAL(10,2) NOT NULL,
    id_categoria INT NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria)
);

CREATE TABLE Ingredientes (
    id_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    unidade_medida VARCHAR(20) NOT NULL,
    tipo VARCHAR(50),
    valor DECIMAL(10,4) NOT NULL DEFAULT 0
);

CREATE TABLE PratoIngrediente (
    id_prato INT NOT NULL,
    id_ingrediente INT NOT NULL,
    quantidade DECIMAL(10,3) NOT NULL,
    PRIMARY KEY (id_prato, id_ingrediente),
    FOREIGN KEY (id_prato) REFERENCES Pratos(id_prato),
    FOREIGN KEY (id_ingrediente) REFERENCES Ingredientes(id_ingrediente)
);

CREATE TABLE ValoresNutricionais (
    id_prato INT PRIMARY KEY,
    calorias INT NOT NULL,
    carboidratos DECIMAL(10,2),
    proteinas DECIMAL(10,2),
    gorduras DECIMAL(10,2),
    FOREIGN KEY (id_prato) REFERENCES Pratos(id_prato)
);

-- ============================
-- C) ALERGÊNICOS
-- ============================

CREATE TABLE Alergenicos (
    id_alergenico INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(100)
);

CREATE TABLE IngredienteAlergenico (
    id_ingrediente INT NOT NULL,
    id_alergenico INT NOT NULL,
    PRIMARY KEY (id_ingrediente, id_alergenico),
    FOREIGN KEY (id_ingrediente) REFERENCES Ingredientes(id_ingrediente),
    FOREIGN KEY (id_alergenico) REFERENCES Alergenicos(id_alergenico)
);

-- ============================
-- D) MARKETPLACES (iFood, 99Food)
-- ============================

CREATE TABLE Plataformas (
    id_plataforma INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    taxa_percentual DECIMAL(5,2) NOT NULL,
    tipo_repasse ENUM('loja','plataforma') NOT NULL
);

CREATE TABLE RepassesPlataforma (
    id_repasse INT AUTO_INCREMENT PRIMARY KEY,
    id_plataforma INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    valor_total DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (id_plataforma) REFERENCES Plataformas(id_plataforma)
);

-- ============================
-- E) MESAS (VERSÃO FINAL)
-- ============================

CREATE TABLE Mesas (
    id_mesa INT AUTO_INCREMENT PRIMARY KEY,
    numero INT NOT NULL UNIQUE,
    capacidade INT NOT NULL,
    status ENUM('livre','ocupada','reservada','indisponivel') 
        NOT NULL DEFAULT 'livre',
    observacao VARCHAR(255)
);

-- ============================
-- F) PEDIDOS (VERSÃO FINAL)
-- ============================

CREATE TABLE Pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    id_plataforma INT,
    tipo ENUM('mesa','balcao','delivery') NOT NULL,
    status ENUM('aberto','finalizado','cancelado') NOT NULL,
    data_hora DATETIME NOT NULL,

    -- Adicionada para suportar pedidos de mesa
    id_mesa INT NULL,

    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    FOREIGN KEY (id_plataforma) REFERENCES Plataformas(id_plataforma),
    FOREIGN KEY (id_mesa) REFERENCES Mesas(id_mesa)
);


CREATE TABLE ItensPedido (
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_prato INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    custo_estimado DECIMAL(10,2),

    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido),
    FOREIGN KEY (id_prato) REFERENCES Pratos(id_prato)
);


CREATE TABLE Pagamentos (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    meio_pagamento ENUM('cartao','pix','dinheiro','online'),
    valor DECIMAL(10,2) NOT NULL,
    data_hora DATETIME NOT NULL,

    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido)
);

-- ============================
-- G) ESTOQUE & FORNECEDORES
-- ============================

CREATE TABLE Fornecedores (
    id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    contato VARCHAR(150)
);

CREATE TABLE MovimentosEstoque (
    id_movimento INT AUTO_INCREMENT PRIMARY KEY,
    id_ingrediente INT NOT NULL,
    tipo ENUM('entrada','saida') NOT NULL,
    quantidade DECIMAL(10,3) NOT NULL,
    data_hora DATETIME NOT NULL,
    id_fornecedor INT,
    FOREIGN KEY (id_ingrediente) REFERENCES Ingredientes(id_ingrediente),
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedores(id_fornecedor)
);

CREATE TABLE CustoIngredienteHistorico (
    id_custo INT AUTO_INCREMENT PRIMARY KEY,
    id_ingrediente INT NOT NULL,
    data DATE NOT NULL,
    valor DECIMAL(10,4) NOT NULL,
    FOREIGN KEY (id_ingrediente) REFERENCES Ingredientes(id_ingrediente),
    UNIQUE KEY uk_custo (id_ingrediente, data)
);

-- ============================
-- H) RH
-- ============================

CREATE TABLE Cargos (
    id_cargo INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE Funcionarios (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    id_cargo INT NOT NULL,
    data_admissao DATE NOT NULL,
    FOREIGN KEY (id_cargo) REFERENCES Cargos(id_cargo)
);

CREATE TABLE Turnos (
    id_turno INT AUTO_INCREMENT PRIMARY KEY,
    inicio TIME NOT NULL,
    fim TIME NOT NULL
);

CREATE TABLE FuncionarioTurno (
    id_funcionario INT NOT NULL,
    id_turno INT NOT NULL,
    PRIMARY KEY (id_funcionario, id_turno),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionarios(id_funcionario),
    FOREIGN KEY (id_turno) REFERENCES Turnos(id_turno)
);
