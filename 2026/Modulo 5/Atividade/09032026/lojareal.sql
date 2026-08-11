DROP DATABASE IF EXISTS lojareal;

CREATE DATABASE lojareal
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_unicode_ci;

USE lojareal;

-- Tabela de regiões
CREATE TABLE regioes (
    id_regiao INT PRIMARY KEY,
    nome_regiao VARCHAR(50) NOT NULL
);

-- Tabela de clientes
CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    id_regiao INT,
    data_cadastro DATE,
    FOREIGN KEY (id_regiao) REFERENCES regioes(id_regiao)
);

-- Tabela de vendas
CREATE TABLE vendas (
    id_pedido INT PRIMARY KEY,
    id_cliente INT,
    data_venda DATE,
    valor_venda DECIMAL(10,2),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- Inserindo regiões
INSERT INTO regioes VALUES
(1,'Norte'),
(2,'Nordeste'),
(3,'Sudeste'),
(4,'Sul'),
(5,'Centro-Oeste');

-- Inserindo clientes
INSERT INTO clientes VALUES
(1,'Ana Silva','ana@email.com',3,'2026-01-10'),
(2,'João Souza','joao@email.com',4,'2026-01-15'),
(3,'Maria Lima','maria@email.com',2,'2026-02-01'),
(4,'Carlos Pereira','carlos@email.com',1,'2026-02-05'),
(5,'Fernanda Alves','fernanda@email.com',3,'2026-02-20');

-- Inserindo vendas
INSERT INTO vendas VALUES
(1,1,'2026-01-12',500),
(2,1,'2026-01-18',300),
(3,2,'2026-01-20',700),
(4,3,'2026-02-02',400),
(5,4,'2026-02-10',200),
(6,5,'2026-02-15',900),
(7,2,'2026-03-05',650),
(8,3,'2026-03-12',350);

-- Criando VIEW
CREATE VIEW view_vendas_regiao_mes AS
SELECT
    r.nome_regiao AS regiao,
    MONTH(v.data_venda) AS mes,
    SUM(v.valor_venda) AS total_vendido,
    AVG(v.valor_venda) AS ticket_medio,
    COUNT(v.id_pedido) AS total_pedidos
FROM vendas v
JOIN clientes c ON v.id_cliente = c.id_cliente
JOIN regioes r ON c.id_regiao = r.id_regiao
WHERE YEAR(v.data_venda) = 2026
GROUP BY
    r.nome_regiao,
    MONTH(v.data_venda)
ORDER BY
    r.nome_regiao,
    mes;
    
SELECT * FROM view_vendas_regiao_mes;