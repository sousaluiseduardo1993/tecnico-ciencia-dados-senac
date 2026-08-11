-- 1) Banco
DROP DATABASE IF EXISTS empresa_kpi;
CREATE DATABASE empresa_kpi;
USE empresa_kpi;

-- 2) Tabelas
CREATE TABLE clientes (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nome_cliente VARCHAR(100) NOT NULL,
  regiao VARCHAR(20) NOT NULL
);

CREATE TABLE vendas (
  id_venda INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  data_venda DATE NOT NULL,
  valor_venda DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_vendas_clientes
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- 3) Inserts (>=5 em cada)
INSERT INTO clientes (nome_cliente, regiao) VALUES
('Ana Souza', 'Sul'),
('Bruno Lima', 'Sudeste'),
('Carla Santos', 'Nordeste'),
('Diego Alves', 'Centro-Oeste'),
('Elaine Rocha', 'Norte');

-- Vendas no ano atual (usa o ano do sistema)
-- Meses diferentes + clientes/regiões diferentes
INSERT INTO vendas (id_cliente, data_venda, valor_venda) VALUES
(1, MAKEDATE(YEAR(CURDATE()), 10), 500.00),   -- Janeiro (aprox.)
(2, MAKEDATE(YEAR(CURDATE()), 35), 570.00),   -- Fevereiro (aprox.)
(3, MAKEDATE(YEAR(CURDATE()), 70), 410.00),   -- Março (aprox.)
(2, MAKEDATE(YEAR(CURDATE()), 95), 1200.00),  -- Abril (aprox.)
(1, MAKEDATE(YEAR(CURDATE()), 130), 550.00),  -- Maio (aprox.)
(4, MAKEDATE(YEAR(CURDATE()), 160), 800.00),  -- Junho (aprox.)
(5, MAKEDATE(YEAR(CURDATE()), 190), 300.00);  -- Julho (aprox.)

-- (Opcional, só pra testar o filtro) venda em ano anterior: não deve aparecer na view
INSERT INTO vendas (id_cliente, data_venda, valor_venda) VALUES
(3, DATE_SUB(CURDATE(), INTERVAL 400 DAY), 999.99);

-- 4) VIEW Analítica
DROP VIEW IF EXISTS Vendas_Mensais_Por_Regiao;

CREATE VIEW Vendas_Mensais_Por_Regiao AS
SELECT
  c.regiao AS regiao,
  YEAR(v.data_venda) AS ano,
  MONTH(v.data_venda) AS mes,
  SUM(v.valor_venda) AS total_vendido,
  AVG(v.valor_venda) AS ticket_medio,
  COUNT(*) AS total_pedidos
FROM vendas v
JOIN clientes c ON c.id_cliente = v.id_cliente
WHERE YEAR(v.data_venda) = YEAR(CURDATE())
GROUP BY
  c.regiao,
  YEAR(v.data_venda),
  MONTH(v.data_venda)
ORDER BY
  ano, mes, regiao;

-- 5) Validação (rodar e tirar print)
SELECT * FROM Vendas_Mensais_Por_Regiao;
