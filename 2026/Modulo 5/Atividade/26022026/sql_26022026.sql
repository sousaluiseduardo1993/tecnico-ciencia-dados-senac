/* =========================================================
   ROTEIRO TÉCNICO — PROJETO SQL (MySQL)
   Cenário: Relatório de vendas mensal
   Entregas:
   - Total vendido por categoria (mês atual)
   - Top 5 vendedores do mês atual
   - (extra do Sprint Planning) Vendas por região (Marketing)
   - (extra do Sprint Planning) Produtos sem vendas há 30 dias (Estoque)
========================================================= */


/* =========================
   01) MAPEAMENTO (Modelo)
   =========================
   Entidades mínimas:
   - vendedores
   - clientes (com regiao)
   - categorias
   - produtos (com categoria)
   - vendas (cabeçalho)
   - itens_venda (itens)
*/

DROP DATABASE IF EXISTS relatorio_vendas;
CREATE DATABASE relatorio_vendas;
USE relatorio_vendas;


/* =========================
   02) DESENVOLVIMENTO (DDL)
   ========================= */

CREATE TABLE vendedores (
  id_vendedor INT AUTO_INCREMENT PRIMARY KEY,
  nome        VARCHAR(120) NOT NULL
);

CREATE TABLE clientes (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nome       VARCHAR(120) NOT NULL,
  regiao     VARCHAR(50)  NOT NULL
);

CREATE TABLE categorias (
  id_categoria INT AUTO_INCREMENT PRIMARY KEY,
  nome         VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE produtos (
  id_produto   INT AUTO_INCREMENT PRIMARY KEY,
  nome         VARCHAR(120) NOT NULL,
  id_categoria INT NOT NULL,
  CONSTRAINT fk_produtos_categorias
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

CREATE TABLE vendas (
  id_venda     BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_cliente   INT NOT NULL,
  id_vendedor  INT NOT NULL,
  data_venda   DATE NOT NULL,
  CONSTRAINT fk_vendas_clientes
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
  CONSTRAINT fk_vendas_vendedores
    FOREIGN KEY (id_vendedor) REFERENCES vendedores(id_vendedor)
);

CREATE TABLE itens_venda (
  id_item      BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_venda     BIGINT NOT NULL,
  id_produto   INT NOT NULL,
  quantidade   INT NOT NULL CHECK (quantidade > 0),
  valor_unitario DECIMAL(10,2) NOT NULL CHECK (valor_unitario >= 0),
  CONSTRAINT fk_itens_venda_vendas
    FOREIGN KEY (id_venda) REFERENCES vendas(id_venda),
  CONSTRAINT fk_itens_venda_produtos
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);


/* =========================
   (Opcional) CARGA EXEMPLO
   ========================= */
INSERT INTO vendedores (nome) VALUES
('Ana'), ('Bruno'), ('Carla'), ('Diego'), ('Eva'), ('Felipe');

INSERT INTO clientes (nome, regiao) VALUES
('Cliente A', 'Norte'),
('Cliente B', 'Sul'),
('Cliente C', 'Sudeste'),
('Cliente D', 'Centro-Oeste');

INSERT INTO categorias (nome) VALUES
('Suplementos'), ('Roupas'), ('Acessórios');

INSERT INTO produtos (nome, id_categoria) VALUES
('Whey', 1),
('Creatina', 1),
('Camiseta Dry', 2),
('Luvas', 3),
('Garrafa', 3);

-- vendas em datas variadas (inclui mês atual e anteriores)
INSERT INTO vendas (id_cliente, id_vendedor, data_venda) VALUES
(1, 1, CURDATE()),
(2, 2, CURDATE() - INTERVAL 3 DAY),
(3, 3, CURDATE() - INTERVAL 10 DAY),
(4, 4, CURDATE() - INTERVAL 20 DAY),
(1, 2, CURDATE() - INTERVAL 40 DAY);

INSERT INTO itens_venda (id_venda, id_produto, quantidade, valor_unitario) VALUES
(1, 1, 1, 120.00),
(1, 4, 2, 35.00),
(2, 2, 1, 95.00),
(2, 3, 1, 70.00),
(3, 5, 3, 25.00),
(4, 1, 1, 120.00),
(5, 3, 2, 70.00);


/* =========================
   03) FILTROS (Período)
   =========================
   Padrão “mês atual” (MySQL):
   data_venda >= 1º dia do mês atual
   e data_venda < 1º dia do próximo mês
*/

-- janelas de data (mês atual)
SET @inicio_mes := DATE_FORMAT(CURDATE(), '%Y-%m-01');
SET @inicio_prox_mes := DATE_ADD(@inicio_mes, INTERVAL 1 MONTH);


/* =========================
   RELATÓRIO 1 (Diretoria)
   Total vendido por categoria — mês atual
   ========================= */
SELECT
  c.nome AS categoria,
  ROUND(SUM(iv.quantidade * iv.valor_unitario), 2) AS total_vendido
FROM vendas v
JOIN itens_venda iv ON iv.id_venda = v.id_venda
JOIN produtos p     ON p.id_produto = iv.id_produto
JOIN categorias c   ON c.id_categoria = p.id_categoria
WHERE v.data_venda >= @inicio_mes
  AND v.data_venda <  @inicio_prox_mes
GROUP BY c.id_categoria, c.nome
ORDER BY total_vendido DESC;


 /* =========================
    RELATÓRIO 2 (Diretoria)
    Top 5 vendedores — mês atual
    ========================= */
SELECT
  vd.nome AS vendedor,
  ROUND(SUM(iv.quantidade * iv.valor_unitario), 2) AS total_vendido
FROM vendas v
JOIN vendedores vd ON vd.id_vendedor = v.id_vendedor
JOIN itens_venda iv ON iv.id_venda = v.id_venda
WHERE v.data_venda >= @inicio_mes
  AND v.data_venda <  @inicio_prox_mes
GROUP BY vd.id_vendedor, vd.nome
ORDER BY total_vendido DESC
LIMIT 5;


 /* =========================
    (Sprint Planning) Marketing
    Vendas por região — mês atual
    ========================= */
SELECT
  cl.regiao,
  ROUND(SUM(iv.quantidade * iv.valor_unitario), 2) AS total_vendido,
  COUNT(DISTINCT v.id_venda) AS qtd_vendas,
  ROUND(SUM(iv.quantidade * iv.valor_unitario) / NULLIF(COUNT(DISTINCT v.id_venda),0), 2) AS ticket_medio
FROM vendas v
JOIN clientes cl    ON cl.id_cliente = v.id_cliente
JOIN itens_venda iv ON iv.id_venda = v.id_venda
WHERE v.data_venda >= @inicio_mes
  AND v.data_venda <  @inicio_prox_mes
GROUP BY cl.regiao
ORDER BY total_vendido DESC;


 /* =========================
    (Sprint Planning) Estoque
    Produtos sem vendas há 30 dias
    ========================= */
SELECT
  p.id_produto,
  p.nome AS produto,
  c.nome AS categoria,
  MAX(v.data_venda) AS ultima_venda,
  DATEDIFF(CURDATE(), MAX(v.data_venda)) AS dias_sem_venda
FROM produtos p
JOIN categorias c ON c.id_categoria = p.id_categoria
LEFT JOIN itens_venda iv ON iv.id_produto = p.id_produto
LEFT JOIN vendas v       ON v.id_venda = iv.id_venda
GROUP BY p.id_produto, p.nome, c.nome
HAVING (ultima_venda IS NULL) OR (ultima_venda < CURDATE() - INTERVAL 30 DAY)
ORDER BY dias_sem_venda DESC, produto;


/* =========================
   04) VALIDAÇÃO (Checagens)
   ========================= */

-- Validação 1: total geral do mês (soma de itens)
SELECT
  ROUND(SUM(iv.quantidade * iv.valor_unitario), 2) AS total_geral_mes
FROM vendas v
JOIN itens_venda iv ON iv.id_venda = v.id_venda
WHERE v.data_venda >= @inicio_mes
  AND v.data_venda <  @inicio_prox_mes;

-- Validação 2: conferir se categorias somam o total geral (deve bater com o total_geral_mes)
SELECT
  ROUND(SUM(total_por_categoria), 2) AS soma_categorias_mes
FROM (
  SELECT SUM(iv.quantidade * iv.valor_unitario) AS total_por_categoria
  FROM vendas v
  JOIN itens_venda iv ON iv.id_venda = v.id_venda
  JOIN produtos p ON p.id_produto = iv.id_produto
  WHERE v.data_venda >= @inicio_mes
    AND v.data_venda <  @inicio_prox_mes
  GROUP BY p.id_categoria
) t;


/* =========================
   05) OTIMIZAÇÃO (Índices)
   =========================
   Foco: acelerar filtros por data e joins.
*/

CREATE INDEX idx_vendas_data ON vendas (data_venda);
CREATE INDEX idx_vendas_vendedor_data ON vendas (id_vendedor, data_venda);
CREATE INDEX idx_itens_venda_venda ON itens_venda (id_venda);
CREATE INDEX idx_itens_venda_produto ON itens_venda (id_produto);
CREATE INDEX idx_produtos_categoria ON produtos (id_categoria);

-- (opcional) checar plano de execução:
-- EXPLAIN SELECT ... (cole qualquer uma das queries acima)


/* =========================
   06) ENTREGA
   =========================
   - Salvar este arquivo como: relatorio_vendas_mensal.sql
   - Versionar no repositório do grupo
   - Garantir que o PO valide os resultados
*/