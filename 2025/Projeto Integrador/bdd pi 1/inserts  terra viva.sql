-- 1) Inserindo Categorias
-- ============================================================
INSERT INTO Categorias (nome) VALUES
    ('Almoço Executivo'),
    ('Pratos Principais'),
    ('Sobremesas'),
    ('Bebidas'),
    ('Extras');

-- 2) Inserindo Dietas
-- ============================================================
-- Verificar se a dieta já existe antes de inserir
INSERT INTO Dietas (nome, descricao)
SELECT 'PB', 'Plant-Based / Vegano'
WHERE NOT EXISTS (SELECT 1 FROM Dietas WHERE nome = 'PB');

INSERT INTO Dietas (nome, descricao)
SELECT 'OV', 'Ovolacto Vegetariano'
WHERE NOT EXISTS (SELECT 1 FROM Dietas WHERE nome = 'OV');

INSERT INTO Dietas (nome, descricao)
SELECT 'SG', 'Sem Glúten'
WHERE NOT EXISTS (SELECT 1 FROM Dietas WHERE nome = 'SG');


-- 3) Inserindo Alergênicos
-- ============================================================
INSERT INTO Alergenicos (nome, tipo) VALUES
    ('Castanhas', 'Oleaginosas'),
    ('Soja', 'Leguminosa'),
    ('Glúten', 'Trigo e derivados'),
    ('Coco', 'Fruto tropical'),
    ('Amendoim', 'Oleaginosa'),
    ('Lactose', 'Derivado do leite');

-- 4) Inserindo Ingredientes
-- ============================================================
INSERT INTO Ingredientes (nome, unidade_medida, tipo, origem, valor, contem_ovo, contem_leite, ativo) VALUES
    ('Caju', 'kg', 'fruta', 'vegetal', 18.00, 0, 0, 1),
    ('Banana da Terra', 'kg', 'fruta', 'vegetal', 9.00, 0, 0, 1),
    ('Leite de Coco', 'l', 'líquido', 'vegetal', 10.00, 0, 0, 1),
    ('Azeite de Dendê', 'l', 'óleo', 'vegetal', 22.00, 0, 0, 1),
    ('Arroz Integral', 'kg', 'grão', 'vegetal', 12.00, 0, 0, 1),
    ('Farofa de Dendê', 'kg', 'mistura', 'vegetal', 16.00, 0, 0, 1),
    ('Quinoa', 'kg', 'grão', 'vegetal', 28.00, 0, 0, 1),
    ('Arroz Selvagem', 'kg', 'grão', 'vegetal', 40.00, 0, 0, 1),
    ('Tofu', 'kg', 'proteína vegetal', 'vegetal', 24.00, 0, 0, 1),
    ('Brócolis', 'kg', 'verdura', 'vegetal', 12.00, 0, 0, 1),
    ('Edamame', 'kg', 'leguminosa', 'vegetal', 25.00, 0, 0, 1),
    ('Cenoura', 'kg', 'raiz', 'vegetal', 5.00, 0, 0, 1),
    ('Molho Tahine', 'kg', 'pasta', 'vegetal', 35.00, 0, 0, 1),
    ('Abobrinha', 'kg', 'legume', 'vegetal', 8.00, 0, 0, 1),
    ('Lentilha', 'kg', 'grão', 'vegetal', 14.00, 0, 0, 1),
    ('Molho de Tomate', 'kg', 'molho', 'vegetal', 9.00, 0, 0, 1),
    ('Queijo de Castanha', 'kg', 'vegano', 'vegetal', 60.00, 0, 0, 1),
    ('Grão-de-bico', 'kg', 'grão', 'vegetal', 12.00, 0, 0, 1),
    ('Cebola Caramelizada', 'kg', 'vegetal', 'vegetal', 15.00, 0, 0, 1),
    ('Batata Rústica', 'kg', 'legume', 'vegetal', 7.00, 0, 0, 1),
    ('Castanhas', 'kg', 'oleaginosa', 'vegetal', 60.00, 0, 0, 1),
    ('Cacau 70%', 'kg', 'cacau', 'vegetal', 80.00, 0, 0, 1),
    ('Sorbet de Morango', 'kg', 'sobremesa', 'vegetal', 35.00, 0, 0, 1),
    ('Couve', 'kg', 'verdura', 'vegetal', 6.00, 0, 0, 1),
    ('Gengibre', 'kg', 'raiz', 'vegetal', 20.00, 0, 0, 1),
    ('Maçã', 'kg', 'fruta', 'vegetal', 8.00, 0, 0, 1),
    ('Kombucha Base', 'l', 'bebida', 'vegetal', 12.00, 0, 0, 1),
    ('Água', 'l', 'líquido', 'mineral', 1.00, 0, 0, 1),
    ('Hortelã', 'kg', 'erva', 'vegetal', 18.00, 0, 0, 1),
    ('Linguiça Vegana', 'kg', 'proteína vegetal', 'vegetal', 38.00, 0, 0, 1),
    ('Carne de Legumes', 'kg', 'mistura vegetal', 'vegetal', 30.00, 0, 0, 1),
    ('Néctar de Coco', 'l', 'líquido', 'vegetal', 22.00, 0, 0, 1),
    ('Caldo Base', 'l', 'líquido', 'vegetal', 8.00, 0, 0, 1),
    ('Proteína Plant-Based', 'kg', 'proteína vegetal', 'vegetal', 34.00, 0, 0, 1),
    ('Feijão', 'kg', 'grão', 'vegetal', 10.00, 0, 0, 1);

-- 5) Inserindo Pratos
-- ============================================================
INSERT INTO Pratos (nome, descricao, preco_base, id_categoria, ativo)
SELECT 'Almoço Executivo', 'Seleção diária...', 69.90, id_categoria, 1 FROM Categorias WHERE nome='Almoço Executivo'
UNION ALL
SELECT 'Buffet a Quilo Sazonal', 'Buffet...', 0.00, id_categoria, 1 FROM Categorias WHERE nome='Almoço Executivo'
UNION ALL
SELECT 'Prato Feito Raízes (PF)', 'Proteína PB...', 38.00, id_categoria, 1 FROM Categorias WHERE nome='Almoço Executivo'
UNION ALL
SELECT 'Caldo do Dia', 'Caldo funcional...', 15.00, id_categoria, 1 FROM Categorias WHERE nome='Extras'
UNION ALL
SELECT 'Moqueca de Caju e Banana da Terra', 'Moqueca...', 58.00, id_categoria, 1 FROM Categorias WHERE nome='Pratos Principais'
UNION ALL
SELECT 'Bowl de Grãos e Tofu', 'Base de quinoa...', 48.00, id_categoria, 1 FROM Categorias WHERE nome='Pratos Principais'
UNION ALL
SELECT 'Lasanha de Abobrinha', 'Fatias de abobrinha...', 65.00, id_categoria, 1 FROM Categorias WHERE nome='Pratos Principais'
UNION ALL
SELECT 'Hambúrguer de Grão-de-Bico', 'Hambúrguer...', 55.00, id_categoria, 1 FROM Categorias WHERE nome='Pratos Principais'
UNION ALL
SELECT 'Feijoada Vegana Gourmet', 'Feijoada...', 56.00, id_categoria, 1 FROM Categorias WHERE nome='Pratos Principais'
UNION ALL
SELECT 'Cheesecake de Maracujá Vivo', 'Cheesecake...', 38.00, id_categoria, 1 FROM Categorias WHERE nome='Sobremesas'
UNION ALL
SELECT 'Brownie Vegano e SG', 'Brownie...', 22.00, id_categoria, 1 FROM Categorias WHERE nome='Sobremesas'
UNION ALL
SELECT 'Suco Detox Prensado a Frio', 'Suco...', 18.00, id_categoria, 1 FROM Categorias WHERE nome='Bebidas'
UNION ALL
SELECT 'Kombucha Artesanal', 'Kombucha...', 16.00, id_categoria, 1 FROM Categorias WHERE nome='Bebidas'
UNION ALL
SELECT 'Água Aromatizada', 'Água...', 0.00, id_categoria, 1 FROM Categorias WHERE nome='Bebidas';

-- 6) Associando Pratos às Dietas
-- ============================================================
INSERT INTO PratoDieta (id_prato, id_dieta)
SELECT id_prato, (SELECT id_dieta FROM Dietas WHERE nome='PB') FROM Pratos;

INSERT INTO PratoDieta (id_prato, id_dieta)
SELECT id_prato, (SELECT id_dieta FROM Dietas WHERE nome='SG') FROM Pratos;

INSERT INTO PratoDieta (id_prato, id_dieta)
SELECT id_prato, (SELECT id_dieta FROM Dietas WHERE nome='OV') 
FROM Pratos WHERE nome IN ('Almoço Executivo','Prato Feito Raízes (PF)');

-- 7) Associando Ingredientes aos Pratos
-- ============================================================
-- Prato Feito Raízes
INSERT INTO PratoIngrediente (id_prato, id_ingrediente, quantidade)
SELECT p.id_prato, i.id_ingrediente,
    CASE i.nome
        WHEN 'Proteína Plant-Based' THEN 0.18
        WHEN 'Arroz Integral' THEN 0.18
        WHEN 'Couve' THEN 0.08
        ELSE 0
    END
FROM Pratos p
JOIN Ingredientes i ON i.nome IN ('Proteína Plant-Based', 'Arroz Integral', 'Couve')
WHERE p.nome = 'Prato Feito Raízes (PF)';

-- Caldo do Dia
INSERT INTO PratoIngrediente (id_prato, id_ingrediente, quantidade)
SELECT p.id_prato, i.id_ingrediente, 0.30
FROM Pratos p
JOIN Ingredientes i ON i.nome='Caldo Base'
WHERE p.nome='Caldo do Dia';

-- Moqueca
INSERT INTO PratoIngrediente (id_prato, id_ingrediente, quantidade)
SELECT p.id_prato, i.id_ingrediente,
    CASE i.nome
        WHEN 'Caju' THEN 0.25
        WHEN 'Banana da Terra' THEN 0.15
        WHEN 'Leite de Coco' THEN 0.20
        WHEN 'Azeite de Dendê' THEN 0.02
        WHEN 'Arroz Integral' THEN 0.18
        WHEN 'Farofa de Dendê' THEN 0.15
        ELSE 0
    END
FROM Pratos p
JOIN Ingredientes i ON i.nome IN (
    'Caju', 'Banana da Terra', 'Leite de Coco',
    'Azeite de Dendê', 'Arroz Integral', 'Farofa de Dendê'
)
WHERE p.nome='Moqueca de Caju e Banana da Terra';

-- (Replicar a mesma estrutura para os outros pratos...)

-- 8) Associando Ingredientes aos Alergênicos
-- ============================================================
INSERT INTO IngredienteAlergenico (id_ingrediente, id_alergenico)
SELECT i.id_ingrediente, a.id_alergenico
FROM Ingredientes i
JOIN Alergenicos a ON
    (i.nome = 'Castanhas' AND a.nome = 'Castanhas')
    OR (i.nome = 'Tofu' AND a.nome = 'Soja')
    OR (i.nome = 'Edamame' AND a.nome = 'Soja')
    OR (i.nome = 'Leite de Coco' AND a.nome = 'Coco')
    OR (i.nome = 'Néctar de Coco' AND a.nome = 'Coco');


-- Consultar Categorias
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