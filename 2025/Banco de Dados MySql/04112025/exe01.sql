-- Cria o banco de dados
CREATE DATABASE loja;

-- Usa o banco de dados criado
USE loja;

-- Agora crie as tabelas
CREATE TABLE CLIENTE (
  id_cliente INT PRIMARY KEY AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  cpf CHAR(11) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE,
  telefone VARCHAR(15),
  endereco VARCHAR(200)
);

CREATE TABLE CATEGORIA (
  id_categoria INT PRIMARY KEY AUTO_INCREMENT,
  nome_categoria VARCHAR(100) UNIQUE NOT NULL,
  descricao TEXT
);

CREATE TABLE PRODUTO (
  id_produto INT PRIMARY KEY AUTO_INCREMENT,
  id_categoria INT NOT NULL,
  nome_produto VARCHAR(100) NOT NULL,
  descricao TEXT,
  preco_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  estoque INT NOT NULL DEFAULT 0,
  FOREIGN KEY (id_categoria) REFERENCES CATEGORIA(id_categoria)
);

CREATE TABLE PEDIDO (
  id_pedido INT PRIMARY KEY AUTO_INCREMENT,
  id_cliente INT NOT NULL,
  data_pedido DATE NOT NULL DEFAULT (CURRENT_DATE),
  valor_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',
  forma_pagamento VARCHAR(50),
  FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)
);

CREATE TABLE ITEM_PEDIDO (
  id_pedido INT NOT NULL,
  id_produto INT NOT NULL,
  quantidade INT NOT NULL DEFAULT 1,
  preco_unitario DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_pedido, id_produto),
  FOREIGN KEY (id_pedido) REFERENCES PEDIDO(id_pedido),
  FOREIGN KEY (id_produto) REFERENCES PRODUTO(id_produto)
);
