-- ============================================================
-- ÍNDICES (consolidados; crie apenas uma vez)
-- ============================================================
CREATE INDEX idx_cli_nome ON Clientes(nome);
CREATE INDEX idx_cli_email ON Clientes(email);
CREATE INDEX idx_prato_categoria ON Pratos(id_categoria);
CREATE INDEX idx_ing_nome ON Ingredientes(nome);
CREATE INDEX idx_pratoingrediente_ingrediente ON PratoIngrediente(id_ingrediente);

CREATE INDEX idx_pedido_cliente ON Pedidos(id_cliente);
CREATE INDEX idx_pedido_data ON Pedidos(data_hora);
CREATE INDEX idx_pedido_plat ON Pedidos(id_plataforma);
CREATE INDEX idx_pedido_mesa ON Pedidos(id_mesa);

CREATE INDEX idx_item_pedido ON ItensPedido(id_pedido);
CREATE INDEX idx_item_prato ON ItensPedido(id_prato);

CREATE INDEX idx_mov_ingrediente ON MovimentosEstoque(id_ingrediente);
CREATE INDEX idx_mov_data ON MovimentosEstoque(data_hora);

CREATE INDEX idx_func_cargo ON Funcionarios(id_cargo);
CREATE INDEX idx_repasses_plataforma ON RepassesPlataforma(id_plataforma);

CREATE INDEX idx_pratodieta_dieta ON PratoDieta(id_dieta);
CREATE INDEX idx_ingrediente_alergenico ON IngredienteAlergenico(id_alergenico);

-- ============================================================
-- VIEWS (consolidadas)
-- ============================================================
CREATE OR REPLACE VIEW vw_vendas_por_prato AS
SELECT
    p.id_prato,
    p.nome AS prato,
    SUM(i.quantidade) AS total_quantidade,
    SUM(i.quantidade * i.preco_unitario) AS receita_total
FROM ItensPedido i
JOIN Pratos p ON p.id_prato = i.id_prato
GROUP BY p.id_prato, p.nome;

CREATE OR REPLACE VIEW vw_vendas_plataforma AS
SELECT
    COALESCE(pl.nome,'Interno') AS plataforma,
    COUNT(DISTINCT ped.id_pedido) AS total_pedidos,
    SUM(pg.valor) AS receita_total
FROM Pagamentos pg
JOIN Pedidos ped ON ped.id_pedido = pg.id_pedido
LEFT JOIN Plataformas pl ON pl.id_plataforma = ped.id_plataforma
GROUP BY plataforma;

CREATE OR REPLACE VIEW vw_custo_prato AS
SELECT
    p.id_prato,
    p.nome,
    SUM(pi.quantidade * (
        SELECT c.valor
        FROM CustoIngredienteHistorico c
        WHERE c.id_ingrediente = pi.id_ingrediente
        ORDER BY c.data DESC
        LIMIT 1
    )) AS custo_total
FROM PratoIngrediente pi
JOIN Pratos p ON p.id_prato = pi.id_prato
GROUP BY p.id_prato, p.nome;

CREATE OR REPLACE VIEW vw_margem_lucro AS
SELECT
    v.id_prato,
    v.prato,
    v.receita_total,
    c.custo_total,
    (v.receita_total - c.custo_total) AS lucro_bruto,
    ROUND(
      CASE WHEN v.receita_total = 0 THEN 0
           ELSE ((v.receita_total - c.custo_total) / v.receita_total) * 100 END
    , 2) AS margem_percentual
FROM vw_vendas_por_prato v
JOIN vw_custo_prato c ON c.id_prato = v.id_prato;

-- ============================================================
-- FUNÇÕES, TRIGGERS E PROCEDURES (uso de DELIMITER)
-- ============================================================
DELIMITER $$

CREATE FUNCTION fn_custo_ingrediente_atual(id_ing INT)
RETURNS DECIMAL(10,4)
DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN (
        SELECT COALESCE(c.valor, 0.0000)
        FROM CustoIngredienteHistorico c
        WHERE c.id_ingrediente = id_ing
        ORDER BY c.data DESC
        LIMIT 1
    );
END $$

CREATE FUNCTION fn_custo_prato(idp INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN (
        SELECT COALESCE(SUM(pi.quantidade * fn_custo_ingrediente_atual(pi.id_ingrediente)),0)
        FROM PratoIngrediente pi
        WHERE pi.id_prato = idp
    );
END $$

CREATE FUNCTION fn_lucro_prato(idp INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN (
        SELECT COALESCE((v.receita_total - c.custo_total),0)
        FROM vw_vendas_por_prato v
        JOIN vw_custo_prato c ON c.id_prato = v.id_prato
        WHERE v.id_prato = idp
        LIMIT 1
    );
END $$

-- Trigger: valida tipo de pedido
CREATE TRIGGER trg_validacao_pedido
BEFORE INSERT ON Pedidos
FOR EACH ROW
BEGIN
    IF NEW.tipo = 'delivery' THEN
        IF NEW.id_plataforma IS NULL OR NEW.id_mesa IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Pedido delivery exige plataforma e não permite mesa.';
        END IF;
    END IF;

    IF NEW.tipo = 'mesa' THEN
        IF NEW.id_mesa IS NULL OR NEW.id_plataforma IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Pedido de mesa exige id_mesa e não permite plataforma.';
        END IF;
    END IF;

    IF NEW.tipo = 'balcao' THEN
        IF NEW.id_mesa IS NOT NULL OR NEW.id_plataforma IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Pedido de balcão não permite mesa nem plataforma.';
        END IF;
    END IF;
END $$

-- Trigger: gerar saídas de estoque ao inserir item de pedido
CREATE TRIGGER trg_saida_estoque
AFTER INSERT ON ItensPedido
FOR EACH ROW
BEGIN
    INSERT INTO MovimentosEstoque (id_ingrediente, tipo, quantidade, data_hora, id_fornecedor, id_funcionario_responsavel, observacao)
    SELECT
        pi.id_ingrediente,
        'saida',
        pi.quantidade * NEW.quantidade,
        CURRENT_TIMESTAMP,
        NULL,
        NULL,
        CONCAT('Saída automática por pedido #', NEW.id_pedido)
    FROM PratoIngrediente pi
    WHERE pi.id_prato = NEW.id_prato;
END $$

-- Trigger: gravar histórico de custo ao atualizar ingrediente
CREATE TRIGGER trg_historico_custo
AFTER UPDATE ON Ingredientes
FOR EACH ROW
BEGIN
    INSERT INTO CustoIngredienteHistorico (id_ingrediente, data, valor)
    VALUES (NEW.id_ingrediente, CURDATE(), NEW.valor)
    ON DUPLICATE KEY UPDATE valor = NEW.valor;
END $$

-- Trigger: evitar estoque negativo (ao inserir movimento)
CREATE TRIGGER trg_evitar_estoque_negativo
BEFORE INSERT ON MovimentosEstoque
FOR EACH ROW
BEGIN
    IF NEW.tipo = 'saida' THEN
        IF (
            SELECT COALESCE(SUM(
                CASE tipo WHEN 'entrada' THEN quantidade
                WHEN 'saida' THEN -quantidade ELSE 0 END
            ),0)
            FROM MovimentosEstoque
            WHERE id_ingrediente = NEW.id_ingrediente
        ) - NEW.quantidade < 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Saída maior que saldo disponível no estoque!';
        END IF;
    END IF;
END $$

-- PROCEDURES
CREATE PROCEDURE sp_relatorio_financeiro(IN dt_ini DATE, IN dt_fim DATE)
BEGIN
    SELECT
        ped.id_pedido,
        ped.data_hora,
        SUM(i.preco_unitario * i.quantidade) AS receita,
        SUM(COALESCE(i.custo_estimado, fn_custo_prato(i.id_prato)) * i.quantidade) AS custo,
        SUM(i.preco_unitario * i.quantidade)
          - SUM(COALESCE(i.custo_estimado, fn_custo_prato(i.id_prato)) * i.quantidade) AS lucro
    FROM Pedidos ped
    JOIN ItensPedido i ON i.id_pedido = ped.id_pedido
    WHERE DATE(ped.data_hora) BETWEEN dt_ini AND dt_fim
    GROUP BY ped.id_pedido;
END $$

CREATE PROCEDURE sp_top_pratos(IN limite INT)
BEGIN
    SELECT *
    FROM vw_vendas_por_prato
    ORDER BY total_quantidade DESC
    LIMIT limite;
END $$

CREATE PROCEDURE sp_estoque_atual()
BEGIN
    SELECT
        ing.id_ingrediente,
        ing.nome,
        COALESCE(SUM(
            CASE me.tipo WHEN 'entrada' THEN me.quantidade
            WHEN 'saida' THEN -me.quantidade ELSE 0 END
        ), 0) AS saldo_atual
    FROM Ingredientes ing
    LEFT JOIN MovimentosEstoque me ON me.id_ingrediente = ing.id_ingrediente
    GROUP BY ing.id_ingrediente;
END $$

DELIMITER ;

-- ============================================================
-- DATA MART (tabelas simples para ETL/população posterior)
-- ============================================================
CREATE TABLE IF NOT EXISTS DM_DimTempo (
    id_tempo INT PRIMARY KEY,
    data DATE NOT NULL,
    ano INT,
    mes INT,
    dia INT,
    trimestre INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS DM_DimPrato (
    id_prato INT PRIMARY KEY,
    nome VARCHAR(120),
    categoria VARCHAR(120)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS DM_DimCliente (
    id_cliente INT PRIMARY KEY,
    nome VARCHAR(120)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS DM_FatoVendas (
    id_fato INT AUTO_INCREMENT PRIMARY KEY,
    id_tempo INT NOT NULL,
    id_prato INT NOT NULL,
    id_cliente INT,
    quantidade INT,
    receita DECIMAL(10,2),
    custo DECIMAL(10,2),
    lucro DECIMAL(10,2),
    FOREIGN KEY (id_tempo) REFERENCES DM_DimTempo(id_tempo),
    FOREIGN KEY (id_prato) REFERENCES DM_DimPrato(id_prato),
    FOREIGN KEY (id_cliente) REFERENCES DM_DimCliente(id_cliente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;