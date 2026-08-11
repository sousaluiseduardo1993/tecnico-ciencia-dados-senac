USE restaurante_terraviva;

-- =============================================================
-- 1) AUDIT / LOG (Tabelas auxiliares para rastreabilidade)
-- =============================================================
CREATE TABLE IF NOT EXISTS Audit_Log (
    id_audit BIGINT AUTO_INCREMENT PRIMARY KEY,
    tabela_nome VARCHAR(128) NOT NULL,
    acao ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    registro_id VARCHAR(128) NULL,
    usuario VARCHAR(120) NULL,
    data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dados_antes JSON NULL,
    dados_depois JSON NULL,
    comentario VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Auditar movimentos de estoque críticos (resumo rápido)
CREATE TABLE IF NOT EXISTS Audit_MovimentoEstoque (
    id_audit_mov BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_movimento INT NULL,
    id_ingrediente INT NULL,
    tipo ENUM('entrada','saida','ajuste') NULL,
    quantidade DECIMAL(10,3) NULL,
    data_hora DATETIME NULL,
    origem VARCHAR(80) NULL, -- ex: 'compra','pedido','manual'
    usuario VARCHAR(120) NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =============================================================
-- 2) ÍNDICES OTIMIZADOS (adicionados/ajustados)
-- =============================================================
-- Observação: IF NOT EXISTS para índices não existe em MySQL; usamos
-- CREATE INDEX normalmente — se já existir, ignore o erro ou cheque metadata.
-- Para segurança, rodar scripts de criação de índices via migrador (liquibase/flyway).
-- Aqui criamos índices sugeridos:

-- Clientes
CREATE INDEX idx_cli_nome ON Clientes(nome);
CREATE INDEX idx_cli_email ON Clientes(email);

-- Pratos e Categorias
CREATE INDEX idx_prato_categoria ON Pratos(id_categoria);
CREATE INDEX idx_prato_ativo ON Pratos(ativo);

-- Ingredientes
CREATE INDEX idx_ing_nome ON Ingredientes(nome);
CREATE INDEX idx_ing_ativo ON Ingredientes(ativo);

-- PratoIngrediente
CREATE INDEX idx_pratoingrediente_ingrediente ON PratoIngrediente(id_ingrediente);
CREATE INDEX idx_pratoingrediente_prato ON PratoIngrediente(id_prato);

-- Pedidos e Itens
CREATE INDEX idx_pedido_cliente ON Pedidos(id_cliente);
CREATE INDEX idx_pedido_data ON Pedidos(data_hora);
CREATE INDEX idx_pedido_plat ON Pedidos(id_plataforma);
CREATE INDEX idx_pedido_mesa ON Pedidos(id_mesa);
CREATE INDEX idx_item_pedido ON ItensPedido(id_pedido);
CREATE INDEX idx_item_prato ON ItensPedido(id_prato);

-- Movimentos de estoque
CREATE INDEX idx_mov_ingrediente ON MovimentosEstoque(id_ingrediente);
CREATE INDEX idx_mov_data ON MovimentosEstoque(data_hora);

-- Funcionarios e Cargos
CREATE INDEX idx_func_cargo ON Funcionarios(id_cargo);

-- Repasses e Mapas
CREATE INDEX idx_repasses_plataforma ON RepassesPlataforma(id_plataforma);

-- Outras relações N:N
CREATE INDEX idx_pratodieta_dieta ON PratoDieta(id_dieta);
CREATE INDEX idx_ingrediente_alergenico ON IngredienteAlergenico(id_alergenico);


-- =============================================================
-- 3) VIEWS ANALÍTICAS (otimizadas, com aliases e segurança contra NULL)
-- =============================================================
DROP VIEW IF EXISTS vw_vendas_por_prato;
CREATE VIEW vw_vendas_por_prato AS
SELECT
    p.id_prato,
    p.nome AS prato,
    COALESCE(SUM(i.quantidade),0) AS total_quantidade,
    COALESCE(SUM(i.quantidade * i.preco_unitario),0.00) AS receita_total
FROM ItensPedido i
JOIN Pratos p ON p.id_prato = i.id_prato
GROUP BY p.id_prato, p.nome;

DROP VIEW IF EXISTS vw_vendas_plataforma;
CREATE VIEW vw_vendas_plataforma AS
SELECT
    COALESCE(pl.nome,'Interno') AS plataforma,
    COUNT(DISTINCT ped.id_pedido) AS total_pedidos,
    COALESCE(SUM(pg.valor),0.00) AS receita_total
FROM Pagamentos pg
JOIN Pedidos ped ON ped.id_pedido = pg.id_pedido
LEFT JOIN Plataformas pl ON pl.id_plataforma = ped.id_plataforma
GROUP BY plataforma;

DROP VIEW IF EXISTS vw_custo_prato;
CREATE VIEW vw_custo_prato AS
SELECT
    p.id_prato,
    p.nome,
    COALESCE(SUM(pi.quantidade * COALESCE((
        SELECT c.valor
        FROM CustoIngredienteHistorico c
        WHERE c.id_ingrediente = pi.id_ingrediente
        ORDER BY c.data DESC
        LIMIT 1
    ), 0.0000)), 0.00) AS custo_total
FROM PratoIngrediente pi
JOIN Pratos p ON p.id_prato = pi.id_prato
GROUP BY p.id_prato, p.nome;

DROP VIEW IF EXISTS vw_margem_lucro;
CREATE VIEW vw_margem_lucro AS
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


-- =============================================================
-- 4) FUNÇÕES (determinísticas/defensivas)
-- =============================================================
DELIMITER $$

DROP FUNCTION IF EXISTS fn_custo_ingrediente_atual $$
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
/* fn_custo_ingrediente_atual: retorna último custo conhecido do ingrediente. */

DROP FUNCTION IF EXISTS fn_custo_prato $$
CREATE FUNCTION fn_custo_prato(idp INT)
RETURNS DECIMAL(12,4)
DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN (
        SELECT COALESCE(SUM(pi.quantidade * fn_custo_ingrediente_atual(pi.id_ingrediente)),0.0000)
        FROM PratoIngrediente pi
        WHERE pi.id_prato = idp
    );
END $$
/* fn_custo_prato: soma custo atual dos ingredientes do prato. */

DROP FUNCTION IF EXISTS fn_saldo_ingrediente $$
CREATE FUNCTION fn_saldo_ingrediente(id_ing INT)
RETURNS DECIMAL(12,3)
DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN (
        SELECT COALESCE(SUM(
            CASE WHEN tipo = 'entrada' THEN quantidade
                 WHEN tipo = 'saida' THEN -quantidade
                 ELSE 0 END
        ), 0)
        FROM MovimentosEstoque
        WHERE id_ingrediente = id_ing
    );
END $$
/* fn_saldo_ingrediente: calcula saldo atual a partir dos movimentos. */

DELIMITER ;


-- =============================================================
-- 5) TRIGGERS (refatoradas, defensivas, e com audit)
-- =============================================================

/* TRIGGER: validar consistência do pedido antes de inserir.
   Regras:
   - delivery: precisa id_plataforma e não permite id_mesa
   - mesa: precisa id_mesa e não permite id_plataforma
   - balcao: não permite id_mesa nem id_plataforma
*/
DROP TRIGGER IF EXISTS trg_validacao_pedido;
DELIMITER $$
CREATE TRIGGER trg_validacao_pedido
BEFORE INSERT ON Pedidos
FOR EACH ROW
BEGIN
    IF NEW.tipo = 'delivery' THEN
        IF NEW.id_plataforma IS NULL OR NEW.id_mesa IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pedido delivery exige plataforma e não permite mesa.';
        END IF;
    ELSEIF NEW.tipo = 'mesa' THEN
        IF NEW.id_mesa IS NULL OR NEW.id_plataforma IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pedido de mesa exige id_mesa e não permite plataforma.';
        END IF;
    ELSEIF NEW.tipo = 'balcao' THEN
        IF NEW.id_mesa IS NOT NULL OR NEW.id_plataforma IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pedido de balcão não permite mesa nem plataforma.';
        END IF;
    END IF;
END$$
DELIMITER ;

/* TRIGGER: Ao inserir item de pedido -> gera movimentos de estoque 'saida' para cada ingrediente do prato.
   - Bloqueio não é usado aqui; trigger é AFTER INSERT (está dentro da mesma transação).
   - Antes, checamos saldo via função fn_saldo_ingrediente para prevenir estoque negativo.
   - Também registramos em Audit_MovimentoEstoque.
*/

DROP TRIGGER IF EXISTS trg_evitar_estoque_negativo;
DELIMITER $$

CREATE TRIGGER trg_evitar_estoque_negativo
BEFORE INSERT ON MovimentosEstoque
FOR EACH ROW
BEGIN
    DECLARE v_saldo DECIMAL(12,3);

    -- Só verifica quando for uma saída de estoque
    IF NEW.tipo = 'saida' THEN
        SET v_saldo = (
            SELECT COALESCE(SUM(
                CASE tipo 
                    WHEN 'entrada' THEN quantidade
                    WHEN 'saida' THEN -quantidade
                    ELSE 0 END
            ),0)
            FROM MovimentosEstoque
            WHERE id_ingrediente = NEW.id_ingrediente
        );

        -- Se o saldo atual menos a saída resultar negativo, apenas registra no log
        IF (v_saldo - NEW.quantidade) < 0 THEN
            INSERT INTO Audit_Log (
                tabela_nome,
                acao,
                registro_id,
                usuario,
                comentario,
                dados_antes,
                dados_depois
            )
            VALUES (
                'MovimentosEstoque',
                'INSERT',
                NEW.id_ingrediente,
                NEW.id_funcionario_responsavel,
                CONCAT('Aviso: saldo negativo após saída. Saldo anterior: ', v_saldo, ', saída: ', NEW.quantidade),
                JSON_OBJECT('saldo_anterior', v_saldo),
                JSON_OBJECT('nova_saida', NEW.quantidade)
            );
            -- Nenhum bloqueio, apenas registro.
        END IF;
    END IF;
END$$

DELIMITER ;

/* TRIGGER: Ao inserir item de compra -> gerar movimento de estoque 'entrada', atualizar valor do ingrediente e gravar histórico.
   - Implementada com cuidado para evitar duplicidade de histórico (ON DUPLICATE).
*/
DROP TRIGGER IF EXISTS after_insert_compra_item;
DELIMITER $$
CREATE TRIGGER after_insert_compra_item
AFTER INSERT ON CompraItens
FOR EACH ROW
BEGIN
  -- 1) Inserir movimento de estoque do tipo 'entrada'
  INSERT INTO MovimentosEstoque (id_ingrediente, tipo, quantidade, data_hora, id_fornecedor, observacao, id_funcionario_responsavel)
  VALUES (
      NEW.id_ingrediente,
      'entrada',
      NEW.quantidade,
      NOW(),
      (SELECT c.id_fornecedor FROM Compras c WHERE c.id_compra = NEW.id_compra LIMIT 1),
      CONCAT('Entrada via compra id=', NEW.id_compra),
      NULL
  );

  -- 2) Atualizar valor atual do ingrediente para o preço unitário da compra
  UPDATE Ingredientes
    SET valor = NEW.valor_unitario
    WHERE id_ingrediente = NEW.id_ingrediente;

  -- 3) Inserir entrada no histórico de custo
  INSERT INTO CustoIngredienteHistorico (id_ingrediente, data, valor)
  VALUES (NEW.id_ingrediente, CURDATE(), NEW.valor_unitario)
  ON DUPLICATE KEY UPDATE valor = NEW.valor_unitario;

  -- 4) Registrar no audit
  INSERT INTO Audit_MovimentoEstoque (id_movimento, id_ingrediente, tipo, quantidade, data_hora, origem, usuario)
  VALUES (LAST_INSERT_ID(), NEW.id_ingrediente, 'entrada', NEW.quantidade, NOW(), CONCAT('compra#', NEW.id_compra), NULL);
END$$
DELIMITER ;

/* TRIGGER: ao atualizar Ingredientes.valor -> gravar no histórico automaticamente
   - Use AFTER UPDATE; se valor mudou, insere novo registro de custo.
*/
DROP TRIGGER IF EXISTS trg_historico_custo;
DELIMITER $$
CREATE TRIGGER trg_historico_custo
AFTER UPDATE ON Ingredientes
FOR EACH ROW
BEGIN
    IF NEW.valor <> OLD.valor THEN
        INSERT INTO CustoIngredienteHistorico (id_ingrediente, data, valor)
        VALUES (NEW.id_ingrediente, CURDATE(), NEW.valor)
        ON DUPLICATE KEY UPDATE valor = NEW.valor;
        -- Auditoria simples
        INSERT INTO Audit_Log (tabela_nome, acao, registro_id, dados_antes, dados_depois, comentario)
        VALUES ('Ingredientes','UPDATE', NEW.id_ingrediente, JSON_OBJECT('valor', OLD.valor), JSON_OBJECT('valor', NEW.valor), 'Atualização automática do histórico de custo');
    END IF;
END$$
DELIMITER ;


-- TRIGGER de prevenção de estoque negativo em MovimentosEstoque (antes insert)
DROP TRIGGER IF EXISTS trg_evitar_estoque_negativo;
DELIMITER $$
CREATE TRIGGER trg_evitar_estoque_negativo
BEFORE INSERT ON MovimentosEstoque
FOR EACH ROW
BEGIN
    IF NEW.tipo = 'saida' THEN
        IF (SELECT COALESCE(SUM(
                CASE tipo WHEN 'entrada' THEN quantidade
                WHEN 'saida' THEN -quantidade ELSE 0 END
             ),0) FROM MovimentosEstoque WHERE id_ingrediente = NEW.id_ingrediente) - NEW.quantidade < 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saída maior que saldo disponível no estoque!';
        END IF;
    END IF;
END$$
DELIMITER ;


-- =============================================================
-- 6) PROCEDURES (transacionais e utilitárias)
-- =============================================================

-- Relatório financeiro entre datas (transacionalmente seguro; retorna por pedido)
DROP PROCEDURE IF EXISTS sp_relatorio_financeiro;
DELIMITER $$
CREATE PROCEDURE sp_relatorio_financeiro(IN dt_ini DATE, IN dt_fim DATE)
BEGIN
    SELECT
        ped.id_pedido,
        ped.data_hora,
        COALESCE(SUM(i.preco_unitario * i.quantidade),0) AS receita,
        COALESCE(SUM(COALESCE(i.custo_estimado, fn_custo_prato(i.id_prato)) * i.quantidade),0) AS custo,
        COALESCE(SUM(i.preco_unitario * i.quantidade),0) - COALESCE(SUM(COALESCE(i.custo_estimado, fn_custo_prato(i.id_prato)) * i.quantidade),0) AS lucro
    FROM Pedidos ped
    JOIN ItensPedido i ON i.id_pedido = ped.id_pedido
    WHERE DATE(ped.data_hora) BETWEEN dt_ini AND dt_fim
    GROUP BY ped.id_pedido
    ORDER BY ped.data_hora;
END$$
DELIMITER ;

-- Procedure: top pratos (limite por parâmetro)
DROP PROCEDURE IF EXISTS sp_top_pratos;
DELIMITER $$

CREATE PROCEDURE sp_top_pratos(IN limite INT)
BEGIN
    DECLARE v_limite INT;

    -- Garante que o valor fique entre 1 e 100
    SET v_limite = limite;

    IF v_limite IS NULL OR v_limite < 1 THEN
        SET v_limite = 1;
    ELSEIF v_limite > 100 THEN
        SET v_limite = 100;
    END IF;

    SELECT *
    FROM vw_vendas_por_prato
    ORDER BY total_quantidade DESC
    LIMIT v_limite;
END$$

DELIMITER ;


-- Procedure transacional: criar compra + itens (atomicidade)
DROP PROCEDURE IF EXISTS sp_criar_compra_com_itens;
DELIMITER $$
CREATE PROCEDURE sp_criar_compra_com_itens(
    IN p_id_fornecedor INT,
    IN p_numero_nota VARCHAR(80),
    IN p_usuario VARCHAR(120)
)
BEGIN
    DECLARE v_id_compra INT;
    START TRANSACTION;
    INSERT INTO Compras (id_fornecedor, numero_nota, data_hora, valor_total, observacao)
    VALUES (p_id_fornecedor, p_numero_nota, NOW(), 0.00, CONCAT('Criado por ', p_usuario));
    SET v_id_compra = LAST_INSERT_ID();

    -- Observação: itens devem ser inseridos em seguida via INSERT INTO CompraItens (id_compra = v_id_compra, ...)
    -- Exemplo de uso:
    -- CALL sp_criar_compra_com_itens(1,'NF123','sistema');
    -- INSERT INTO CompraItens (id_compra, id_ingrediente, quantidade, valor_unitario) VALUES (v_id_compra, ...);
    COMMIT;
    SELECT v_id_compra AS id_compra;
END$$
DELIMITER ;


-- =============================================================
-- 7) ROTINAS DE MANUTENÇÃO (ex.: recalcular preço de venda sugerido)
-- =============================================================

-- Procedure que gera sugestão de preco de venda baseado em margem desejada (ex.: 60%)
DROP PROCEDURE IF EXISTS sp_recalcula_preco_sugerido;
DELIMITER $$
CREATE PROCEDURE sp_recalcula_preco_sugerido(IN p_margem_percent DECIMAL(5,2))
BEGIN
    UPDATE Pratos p
    SET preco_base = ROUND( fn_custo_prato(p.id_prato) / (1 - (p_margem_percent/100)), 2)
    WHERE fn_custo_prato(p.id_prato) > 0;
END$$
DELIMITER ;