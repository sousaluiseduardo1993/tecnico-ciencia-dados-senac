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

SELECT * FROM Categorias;

-- Consultar Dietas
SELECT * FROM Dietas;

-- Consultar Alergênicos
SELECT * FROM Alergenicos;

-- Consultar Ingredientes
SELECT * FROM Ingredientes;

-- Consultar Pratos
SELECT * FROM Pratos;

-- Consultar Ingredientes por Prato
SELECT p.nome AS prato, i.nome AS ingrediente, pi.quantidade
FROM PratoIngrediente pi
JOIN Pratos p ON pi.id_prato = p.id_prato
JOIN Ingredientes i ON pi.id_ingrediente = i.id_ingrediente;

-- Consultar Dietas por Prato
SELECT p.nome AS prato, d.nome AS dieta
FROM PratoDieta pd
JOIN Pratos p ON pd.id_prato = p.id_prato
JOIN Dietas d ON pd.id_dieta = d.id_dieta;

-- Consultar Ingredientes Alergênicos
SELECT i.nome AS ingrediente, a.nome AS alergenico
FROM IngredienteAlergenico ia
JOIN Ingredientes i ON ia.id_ingrediente = i.id_ingrediente
JOIN Alergenicos a ON ia.id_alergenico = a.id_alergenico;