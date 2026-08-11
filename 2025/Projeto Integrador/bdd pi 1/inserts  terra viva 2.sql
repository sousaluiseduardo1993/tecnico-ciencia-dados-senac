/* ============================================================
   DADOS INICIAIS
   ============================================================ */

-- Cargos
INSERT IGNORE INTO Cargos (nome, descricao, salario_base) VALUES
('Atendente', 'Atendimento ao cliente', 1800),
('Cozinheiro', 'Preparo de pratos', 2400),
('Chef', 'Liderança de cozinha', 3500),
('Auxiliar', 'Suporte operacional', 1600),
('Caixa', 'Operação de caixa', 1900),
('Estoquista', 'Controle de estoque', 2000),
('Barista', 'Preparo de bebidas', 2100),
('Supervisor', 'Gestão de turno', 2600);

-- Funcionários
INSERT IGNORE INTO Funcionarios (nome, cpf, email, telefone, id_cargo, tipo_funcao, data_admissao, status) VALUES
('Maria Alves', '11111111111', 'maria@rest.com', '11911112222', 1, 'atendimento', '2023-01-01', 'ativo'),
('João Pedro', '22222222222', 'joao@rest.com', '11922223333', 2, 'cozinha', '2022-10-10', 'ativo'),
('Luana Silva', '33333333333', 'luana@rest.com', '11933334444', 5, 'caixa', '2024-03-01', 'ativo'),
('Carlos Lima', '44444444444', 'carlos@rest.com', '11944445555', 4, 'atendimento', '2024-02-01', 'ativo'),
('Ana Paula', '55555555555', 'ana@rest.com', '11955556666', 3, 'cozinha', '2023-12-01', 'ativo'),
('Felipe Gomes', '66666666666', 'felipe@rest.com', '11966667777', 6, 'estoque', '2023-07-15', 'ativo'),
('Renata Soares', '77777777777', 'renata@rest.com', '11977778888', 7, 'atendimento', '2024-01-20', 'ativo'),
('Thiago Moura', '88888888888', 'thiago@rest.com', '11988889999', 8, 'gestao', '2024-03-10', 'ativo');

-- Clientes
INSERT IGNORE INTO Clientes (nome, email, telefone, data_cadastro) VALUES
('Carlos Ramos', 'carlos@mail.com', '11999998888', '2024-01-10'),
('Juliana Costa', 'ju@mail.com', '11988887777', '2024-01-20'),
('Fernanda Rocha', 'fe@mail.com', '11977776666', '2024-02-01'),
('Marcos Silva', 'marcos@mail.com', '11966665555', '2024-02-15'),
('Patrícia Souza', 'patricia@mail.com', '11955554444', '2024-02-18');

-- Mesas
INSERT IGNORE INTO Mesas (numero, capacidade, status) VALUES
(1, 4, 'livre'),
(2, 2, 'livre'),
(3, 6, 'livre'),
(4, 4, 'livre'),
(5, 2, 'livre');

-- Plataformas
INSERT IGNORE INTO Plataformas (nome, taxa_percentual, tipo_repasse) VALUES
('iFood', 13.00, 'plataforma'),
('UberEats', 12.00, 'plataforma'),
('Site Próprio', 0.00, 'loja');

-- Categorias e Pratos
INSERT IGNORE INTO Categorias (nome) VALUES ('Prato Principal'), ('Bebida'), ('Sopa');

INSERT IGNORE INTO Pratos (nome, descricao, preco_base, id_categoria) VALUES
('Moqueca de Caju e Banana da Terra', 'Prato vegano típico', 48.00, 1),
('Caldo do Dia', 'Sopa artesanal feita com legumes locais', 10.00, 3),
('Kombucha Artesanal', 'Bebida fermentada natural', 12.00, 2),
('Bowl de Grãos e Tofu', 'Tigela nutritiva de grãos e tofu grelhado', 45.00, 1);

-- Pedidos
INSERT IGNORE INTO Pedidos (id_cliente, id_plataforma, tipo, status, id_mesa, id_funcionario_atendente) VALUES
(1, NULL, 'mesa', 'aberto', 1, 1),
(2, NULL, 'mesa', 'aberto', 2, 1),
(3, 1, 'delivery', 'aberto', NULL, 1);

-- Itens do Pedido
INSERT IGNORE INTO ItensPedido (id_pedido, id_prato, quantidade, preco_unitario, custo_estimado, id_funcionario_preparo)
SELECT 1, id_prato, 1, preco_base, 10, 2 FROM Pratos WHERE nome = 'Moqueca de Caju e Banana da Terra';
INSERT IGNORE INTO ItensPedido (id_pedido, id_prato, quantidade, preco_unitario, custo_estimado, id_funcionario_preparo)
SELECT 1, id_prato, 1, preco_base, 7, 2 FROM Pratos WHERE nome = 'Caldo do Dia';
INSERT IGNORE INTO ItensPedido (id_pedido, id_prato, quantidade, preco_unitario, custo_estimado, id_funcionario_preparo)
SELECT 2, id_prato, 1, preco_base, 5, 2 FROM Pratos WHERE nome = 'Kombucha Artesanal';
INSERT IGNORE INTO ItensPedido (id_pedido, id_prato, quantidade, preco_unitario, custo_estimado, id_funcionario_preparo)
SELECT 3, id_prato, 1, preco_base, 9, 2 FROM Pratos WHERE nome = 'Bowl de Grãos e Tofu';

-- Pagamentos
INSERT IGNORE INTO Pagamentos (id_pedido, valor, metodo, id_funcionario_caixa)
VALUES (1, 58.00, 'cartao', 3), (2, 12.00, 'pix', 3);

SELECT 
  p.id_pedido,
  c.nome AS cliente,
  f.nome AS atendente,
  p.tipo,
  p.status,
  p.data_hora
FROM Pedidos p
LEFT JOIN Clientes c ON p.id_cliente = c.id_cliente
LEFT JOIN Funcionarios f ON p.id_funcionario_atendente = f.id_funcionario;

SELECT 
  metodo,
  SUM(valor) AS total_faturado
FROM Pagamentos
GROUP BY metodo;

SELECT 
  i.id_pedido,
  pr.nome AS prato,
  i.quantidade,
  i.preco_unitario,
  (i.quantidade * i.preco_unitario) AS total_item
FROM ItensPedido i
JOIN Pratos pr ON i.id_prato = pr.id_prato;

SELECT 
  pr.nome AS prato,
  SUM(i.quantidade) AS total_vendido
FROM ItensPedido i
JOIN Pratos pr ON i.id_prato = pr.id_prato
GROUP BY pr.nome
ORDER BY total_vendido DESC;

SELECT 
  tipo_funcao,
  ROUND(AVG(c.salario_base),2) AS salario_medio
FROM Funcionarios f
JOIN Cargos c ON f.id_cargo = c.id_cargo
GROUP BY tipo_funcao;
