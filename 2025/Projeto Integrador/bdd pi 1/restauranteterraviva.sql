/* ============================================================
   restauranteterraviva - SCRIPT CONSOLIDADO (PRONTO PARA AWS RDS MySQL / Aurora MySQL)
   Gerado: consolidado, sem triggers de prevenção de estoque negativo,
   ingredientes consolidados (única lista), e INSERT IGNORE para dados iniciais.
   ============================================================ */

-- Ajuste de compatibilidade: execute com um usuário com privilégios adequados.

CREATE DATABASE IF NOT EXISTS restauranteterraviva
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE restauranteterraviva;

SET @@SESSION.sql_mode = CONCAT_WS(',', @@SESSION.sql_mode, 'STRICT_TRANS_TABLES'); -- opcional, recomendado

/* ============================================================
   1. DOMÍNIO DE CLIENTES E PREFERÊNCIAS
   ============================================================ */

CREATE TABLE IF NOT EXISTS Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(150) UNIQUE,
    telefone VARCHAR(20),
    data_cadastro DATE NOT NULL DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS PreferenciasAlimentares (
    id_preferencia INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(120) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ClientePreferencia (
    id_cliente INT NOT NULL,
    id_preferencia INT NOT NULL,
    PRIMARY KEY (id_cliente, id_preferencia),
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_preferencia) REFERENCES PreferenciasAlimentares(id_preferencia)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ============================================================
   2. DOMÍNIO DO CARDÁPIO (Categorias, Pratos e Ingredientes)
   ============================================================ */

CREATE TABLE IF NOT EXISTS Categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Pratos (
    id_prato INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    descricao TEXT,
    preco_base DECIMAL(10,2) DEFAULT NULL,
    id_categoria INT NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    rotulo_certificado VARCHAR(120) NULL,
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria)
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Ingredientes (
    id_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    unidade_medida VARCHAR(20) NOT NULL,
    tipo VARCHAR(50),
    origem VARCHAR(50),
    valor DECIMAL(10,4) NOT NULL DEFAULT 0.0000,
    contem_ovo BOOLEAN NOT NULL DEFAULT FALSE,
    contem_leite BOOLEAN NOT NULL DEFAULT FALSE,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE KEY uk_ingrediente_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS PratoIngrediente (
    id_prato INT NOT NULL,
    id_ingrediente INT NOT NULL,
    quantidade DECIMAL(10,3) NOT NULL,
    PRIMARY KEY (id_prato, id_ingrediente),
    FOREIGN KEY (id_prato) REFERENCES Pratos(id_prato)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_ingrediente) REFERENCES Ingredientes(id_ingrediente)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ValoresNutricionais (
    id_prato INT PRIMARY KEY,
    calorias INT NOT NULL,
    carboidratos DECIMAL(10,2),
    proteinas DECIMAL(10,2),
    gorduras DECIMAL(10,2),
    FOREIGN KEY (id_prato) REFERENCES Pratos(id_prato)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ============================================================
   3. ALERGÊNICOS – Mapeamento de ingredientes
   ============================================================ */

CREATE TABLE IF NOT EXISTS Alergenicos (
    id_alergenico INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS IngredienteAlergenico (
    id_ingrediente INT NOT NULL,
    id_alergenico INT NOT NULL,
    PRIMARY KEY (id_ingrediente, id_alergenico),
    FOREIGN KEY (id_ingrediente) REFERENCES Ingredientes(id_ingrediente)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_alergenico) REFERENCES Alergenicos(id_alergenico)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ============================================================
   4. MARKETPLACES E REGRAS DE REPASSES
   ============================================================ */

CREATE TABLE IF NOT EXISTS Plataformas (
    id_plataforma INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    taxa_percentual DECIMAL(5,2) NOT NULL,
    tipo_repasse ENUM('loja','plataforma') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS RepassesPlataforma (
    id_repasse INT AUTO_INCREMENT PRIMARY KEY,
    id_plataforma INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    valor_total DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (id_plataforma) REFERENCES Plataformas(id_plataforma)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_repasses_datas CHECK (data_fim >= data_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ============================================================
   5. MESAS E GESTÃO DE SALÃO
   ============================================================ */

CREATE TABLE IF NOT EXISTS Mesas (
    id_mesa INT AUTO_INCREMENT PRIMARY KEY,
    numero INT NOT NULL UNIQUE,
    capacidade INT NOT NULL,
    status ENUM('livre','ocupada','reservada','indisponivel') NOT NULL DEFAULT 'livre',
    observacao VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ============================================================
   6. RECURSOS HUMANOS – Cargos, Funcionários e Turnos
   ============================================================ */

CREATE TABLE IF NOT EXISTS Cargos (
    id_cargo INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    salario_base DECIMAL(10,2) DEFAULT 0.00,
    data_criacao DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Funcionarios (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    cpf CHAR(11) UNIQUE,
    email VARCHAR(150),
    telefone VARCHAR(20),
    id_cargo INT NOT NULL,
    tipo_funcao ENUM('atendimento','cozinha','caixa','estoque','gestao') NOT NULL DEFAULT 'atendimento',
    data_admissao DATE NOT NULL,
    status ENUM('ativo','ferias','afastado','demitido') NOT NULL DEFAULT 'ativo',
    data_desligamento DATE,
    observacoes TEXT,
    FOREIGN KEY (id_cargo) REFERENCES Cargos(id_cargo)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Turnos (
    id_turno INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    inicio TIME NOT NULL,
    fim TIME NOT NULL,
    carga_horaria DECIMAL(5,2) GENERATED ALWAYS AS (
        TIME_TO_SEC(TIMEDIFF(fim, inicio)) / 3600
    ) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS FuncionarioTurno (
    id_funcionario INT NOT NULL,
    id_turno INT NOT NULL,
    data_inicio DATE NOT NULL DEFAULT (CURRENT_DATE),
    data_fim DATE,
    PRIMARY KEY (id_funcionario, id_turno, data_inicio),
    FOREIGN KEY (id_funcionario) REFERENCES Funcionarios(id_funcionario)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_turno) REFERENCES Turnos(id_turno)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ============================================================
   7. PEDIDOS, ITENS E PAGAMENTOS
   ============================================================ */

CREATE TABLE IF NOT EXISTS Pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    id_plataforma INT,
    tipo ENUM('mesa','balcao','delivery') NOT NULL,
    status ENUM('aberto','preparo','entregue','finalizado','cancelado') NOT NULL DEFAULT 'aberto',
    data_hora DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    id_mesa INT,
    id_funcionario_atendente INT,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id_plataforma) REFERENCES Plataformas(id_plataforma)
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id_mesa) REFERENCES Mesas(id_mesa)
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id_funcionario_atendente) REFERENCES Funcionarios(id_funcionario)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ItensPedido (
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_prato INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    custo_estimado DECIMAL(10,2),
    id_funcionario_preparo INT,
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_prato) REFERENCES Pratos(id_prato)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_funcionario_preparo) REFERENCES Funcionarios(id_funcionario)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Pagamentos (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    metodo ENUM('dinheiro','cartao','pix') NOT NULL,
    data_hora DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    id_funcionario_caixa INT,
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_funcionario_caixa) REFERENCES Funcionarios(id_funcionario)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ============================================================
   8. ESTOQUE, FORNECEDORES E CUSTOS
   ============================================================ */

CREATE TABLE IF NOT EXISTS Fornecedores (
    id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    contato VARCHAR(120),
    telefone VARCHAR(30)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS MovimentosEstoque (
    id_movimento INT AUTO_INCREMENT PRIMARY KEY,
    id_ingrediente INT NOT NULL,
    tipo ENUM('entrada','saida','ajuste') NOT NULL,
    quantidade DECIMAL(10,3) NOT NULL,
    data_hora DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    id_fornecedor INT,
    id_funcionario_responsavel INT,
    observacao TEXT,
    FOREIGN KEY (id_ingrediente) REFERENCES Ingredientes(id_ingrediente)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedores(id_fornecedor)
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id_funcionario_responsavel) REFERENCES Funcionarios(id_funcionario)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS CustoIngredienteHistorico (
    id_ingrediente INT NOT NULL,
    data DATE NOT NULL,
    valor DECIMAL(10,4) NOT NULL,
    PRIMARY KEY (id_ingrediente, data),
    FOREIGN KEY (id_ingrediente) REFERENCES Ingredientes(id_ingrediente)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ============================================================
   9. DIETAS, CERTIFICAÇÕES E ZONAS DA COZINHA
   ============================================================ */

CREATE TABLE IF NOT EXISTS Dietas (
    id_dieta INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(60) NOT NULL UNIQUE,
    descricao VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS PratoDieta (
    id_prato INT NOT NULL,
    id_dieta INT NOT NULL,
    PRIMARY KEY (id_prato, id_dieta),
    FOREIGN KEY (id_prato) REFERENCES Pratos(id_prato) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_dieta) REFERENCES Dietas(id_dieta) 
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Certificacoes (
    id_certificacao INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    emissor VARCHAR(120),
    descricao TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ItemCertificacao (
    id_item_certificacao INT AUTO_INCREMENT PRIMARY KEY,
    tipo_enum ENUM('prato','ingrediente') NOT NULL,
    id_item INT NOT NULL,
    id_certificacao INT NOT NULL,
    FOREIGN KEY (id_certificacao) REFERENCES Certificacoes(id_certificacao)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ZonasCozinha (
    id_zona INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS IngredienteZona (
    id_ingrediente INT NOT NULL,
    id_zona INT NOT NULL,
    PRIMARY KEY (id_ingrediente, id_zona),
    FOREIGN KEY (id_ingrediente) REFERENCES Ingredientes(id_ingrediente) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_zona) REFERENCES ZonasCozinha(id_zona)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ============================================================
   10. MÓDULO DE COMPRAS (Compra + Itens)
   ============================================================ */

CREATE TABLE IF NOT EXISTS Compras (
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_fornecedor INT,
    numero_nota VARCHAR(80),
    data_hora DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    valor_total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    observacao TEXT,
    FOREIGN KEY (id_fornecedor) REFERENCES Fornecedores(id_fornecedor)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS CompraItens (
    id_compra_item INT AUTO_INCREMENT PRIMARY KEY,
    id_compra INT NOT NULL,
    id_ingrediente INT NOT NULL,
    quantidade DECIMAL(10,3) NOT NULL,
    valor_unitario DECIMAL(10,4) NOT NULL,
    valor_total DECIMAL(12,4) GENERATED ALWAYS AS (quantidade * valor_unitario) STORED,
    FOREIGN KEY (id_compra) REFERENCES Compras(id_compra)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_ingrediente) REFERENCES Ingredientes(id_ingrediente)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS IngredienteFornecedor (
    id_ingrediente INT NOT NULL,
    id_fornecedor INT NOT NULL,
    PRIMARY KEY (id_ingrediente, id_fornecedor),
    FOREIGN KEY (id_ingrediente)
        REFERENCES Ingredientes(id_ingrediente)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_fornecedor)
        REFERENCES Fornecedores(id_fornecedor)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ============================================================
   AUDIT / LOG
   ============================================================ */

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Audit_MovimentoEstoque (
    id_audit_mov BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_movimento INT NULL,
    id_ingrediente INT NULL,
    tipo ENUM('entrada','saida','ajuste') NULL,
    quantidade DECIMAL(10,3) NULL,
    data_hora DATETIME NULL,
    origem VARCHAR(80) NULL,
    usuario VARCHAR(120) NULL,
    criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* ============================================================
   ÍNDICES SUGERIDOS
   ============================================================ */

CREATE INDEX idx_cli_nome ON Clientes(nome);
CREATE INDEX idx_cli_email ON Clientes(email);

CREATE INDEX idx_prato_categoria ON Pratos(id_categoria);
CREATE INDEX idx_prato_ativo ON Pratos(ativo);

CREATE INDEX idx_ing_nome ON Ingredientes(nome);
CREATE INDEX idx_ing_ativo ON Ingredientes(ativo);

CREATE INDEX idx_pratoingrediente_ingrediente ON PratoIngrediente(id_ingrediente);
CREATE INDEX idx_pratoingrediente_prato ON PratoIngrediente(id_prato);

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

/* ============================================================
   VIEWS ANALÍTICAS
   ============================================================ */

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

/* ============================================================
   FUNÇÕES
   ============================================================ */

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
$$
DELIMITER ;

/* ============================================================
   TRIGGERS (mantidos importantes; TRIGGERS DE PREVENÇÃO DE ESTOQUE NEGATIVO REMOVIDAS)
   ============================================================ */

-- TRIGGER: validar consistência do pedido antes de inserir.
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

-- TRIGGER: Ao inserir item de compra -> gerar movimento de estoque 'entrada', atualizar valor e histórico
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

  -- 2) Atualizar valor atual do ingrediente
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

-- TRIGGER: ao atualizar Ingredientes.valor -> gravar no histórico automaticamente
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

/* ============================================================
   PROCEDURES
   ============================================================ */

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

DROP PROCEDURE IF EXISTS sp_top_pratos;
DELIMITER $$
CREATE PROCEDURE sp_top_pratos(IN limite INT)
BEGIN
    DECLARE v_limite INT;

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
    COMMIT;
    SELECT v_id_compra AS id_compra;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_recalcula_preco_sugerido;
DELIMITER $$
CREATE PROCEDURE sp_recalcula_preco_sugerido(IN p_margem_percent DECIMAL(5,2))
BEGIN
    UPDATE Pratos p
    SET preco_base = ROUND( fn_custo_prato(p.id_prato) / (1 - (p_margem_percent/100)), 2)
    WHERE fn_custo_prato(p.id_prato) > 0;
END$$
DELIMITER ;

/* ============================================================
   DADOS INICIAIS (INSERT IGNORE para reexecuções seguras)
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

-- Categorias
INSERT IGNORE INTO Categorias (nome) VALUES ('Prato Principal'), ('Bebida'), ('Sopa'), ('Almoço Executivo'), ('Pratos Principais'), ('Sobremesas'), ('Extras');

-- Ingredientes (consolidado - única lista)
INSERT IGNORE INTO Ingredientes (nome, unidade_medida, tipo, origem, valor, contem_ovo, contem_leite, ativo) VALUES
('Caju', 'kg', 'fruta', 'vegetal', 18.0000, 0, 0, 1),
('Banana da Terra', 'kg', 'fruta', 'vegetal', 9.0000, 0, 0, 1),
('Leite de Coco', 'l', 'líquido', 'vegetal', 10.0000, 0, 0, 1),
('Azeite de Dendê', 'l', 'óleo', 'vegetal', 22.0000, 0, 0, 1),
('Arroz Integral', 'kg', 'grão', 'vegetal', 12.0000, 0, 0, 1),
('Farofa de Dendê', 'kg', 'mistura', 'vegetal', 16.0000, 0, 0, 1),
('Quinoa', 'kg', 'grão', 'vegetal', 28.0000, 0, 0, 1),
('Arroz Selvagem', 'kg', 'grão', 'vegetal', 40.0000, 0, 0, 1),
('Tofu', 'kg', 'proteína vegetal', 'vegetal', 24.0000, 0, 0, 1),
('Brócolis', 'kg', 'verdura', 'vegetal', 12.0000, 0, 0, 1),
('Edamame', 'kg', 'leguminosa', 'vegetal', 25.0000, 0, 0, 1),
('Cenoura', 'kg', 'raiz', 'vegetal', 5.0000, 0, 0, 1),
('Molho Tahine', 'kg', 'pasta', 'vegetal', 35.0000, 0, 0, 1),
('Abobrinha', 'kg', 'legume', 'vegetal', 8.0000, 0, 0, 1),
('Lentilha', 'kg', 'grão', 'vegetal', 14.0000, 0, 0, 1),
('Molho de Tomate', 'kg', 'molho', 'vegetal', 9.0000, 0, 0, 1),
('Queijo de Castanha', 'kg', 'vegano', 'vegetal', 60.0000, 0, 0, 1),
('Grão-de-bico', 'kg', 'grão', 'vegetal', 12.0000, 0, 0, 1),
('Cebola Caramelizada', 'kg', 'vegetal', 'vegetal', 15.0000, 0, 0, 1),
('Batata Rústica', 'kg', 'legume', 'vegetal', 7.0000, 0, 0, 1),
('Castanhas', 'kg', 'oleaginosa', 'vegetal', 60.0000, 0, 0, 1),
('Cacau 70%', 'kg', 'cacau', 'vegetal', 80.0000, 0, 0, 1),
('Sorbet de Morango', 'kg', 'sobremesa', 'vegetal', 35.0000, 0, 0, 1),
('Couve', 'kg', 'verdura', 'vegetal', 6.0000, 0, 0, 1),
('Gengibre', 'kg', 'raiz', 'vegetal', 20.0000, 0, 0, 1),
('Maçã', 'kg', 'fruta', 'vegetal', 8.0000, 0, 0, 1),
('Kombucha Base', 'l', 'bebida', 'vegetal', 12.0000, 0, 0, 1),
('Água', 'l', 'líquido', 'mineral', 1.0000, 0, 0, 1),
('Hortelã', 'kg', 'erva', 'vegetal', 18.0000, 0, 0, 1),
('Linguiça Vegana', 'kg', 'proteína vegetal', 'vegetal', 38.0000, 0, 0, 1),
('Carne de Legumes', 'kg', 'mistura vegetal', 'vegetal', 30.0000, 0, 0, 1),
('Néctar de Coco', 'l', 'líquido', 'vegetal', 22.0000, 0, 0, 1),
('Caldo Base', 'l', 'líquido', 'vegetal', 8.0000, 0, 0, 1),
('Proteína Plant-Based', 'kg', 'proteína vegetal', 'vegetal', 34.0000, 0, 0, 1),
('Feijão', 'kg', 'grão', 'vegetal', 10.0000, 0, 0, 1);

-- Dietas
INSERT IGNORE INTO Dietas (nome, descricao) VALUES
('PB', 'Plant-Based / Vegano'),
('OV', 'Ovolacto Vegetariano'),
('SG', 'Sem Glúten');

-- Alergênicos
INSERT IGNORE INTO Alergenicos (nome, tipo) VALUES
('Castanhas', 'Oleaginosas'),
('Soja', 'Leguminosa'),
('Glúten', 'Trigo e derivados'),
('Coco', 'Fruto tropical'),
('Amendoim', 'Oleaginosa'),
('Lactose', 'Derivado do leite');

-- Pratos iniciais
INSERT IGNORE INTO Pratos (nome, descricao, preco_base, id_categoria, ativo) VALUES
('Moqueca de Caju e Banana da Terra', 'Prato vegano típico', 58.00, (SELECT id_categoria FROM Categorias WHERE nome='Pratos Principais' LIMIT 1), 1),
('Caldo do Dia', 'Sopa artesanal feita com legumes locais', 15.00, (SELECT id_categoria FROM Categorias WHERE nome='Extras' LIMIT 1), 1),
('Kombucha Artesanal', 'Bebida fermentada natural', 16.00, (SELECT id_categoria FROM Categorias WHERE nome='Bebidas' LIMIT 1), 1),
('Bowl de Grãos e Tofu', 'Tigela nutritiva de grãos e tofu grelhado', 48.00, (SELECT id_categoria FROM Categorias WHERE nome='Pratos Principais' LIMIT 1), 1);

-- Repasses / Fornecedores (exemplos mínimos)
INSERT IGNORE INTO Fornecedores (nome, contato, telefone) VALUES
('Fornecedor A', 'contato@forna.com', '11910101010');

-- Pedidos e Itens (exemplos)
INSERT IGNORE INTO Pedidos (id_cliente, id_plataforma, tipo, status, id_mesa, id_funcionario_atendente) VALUES
(1, NULL, 'mesa', 'aberto', 1, 1),
(2, NULL, 'mesa', 'aberto', 2, 1),
(3, 1, 'delivery', 'aberto', NULL, 1);

-- Itens do Pedido (exemplos)
INSERT IGNORE INTO ItensPedido (id_pedido, id_prato, quantidade, preco_unitario, custo_estimado, id_funcionario_preparo)
SELECT 1, id_prato, 1, preco_base, 10, 2 FROM Pratos WHERE nome = 'Moqueca de Caju e Banana da Terra' LIMIT 1;
INSERT IGNORE INTO ItensPedido (id_pedido, id_prato, quantidade, preco_unitario, custo_estimado, id_funcionario_preparo)
SELECT 1, id_prato, 1, preco_base, 7, 2 FROM Pratos WHERE nome = 'Caldo do Dia' LIMIT 1;
INSERT IGNORE INTO ItensPedido (id_pedido, id_prato, quantidade, preco_unitario, custo_estimado, id_funcionario_preparo)
SELECT 2, id_prato, 1, preco_base, 5, 2 FROM Pratos WHERE nome = 'Kombucha Artesanal' LIMIT 1;
INSERT IGNORE INTO ItensPedido (id_pedido, id_prato, quantidade, preco_unitario, custo_estimado, id_funcionario_preparo)
SELECT 3, id_prato, 1, preco_base, 9, 2 FROM Pratos WHERE nome = 'Bowl de Grãos e Tofu' LIMIT 1;

-- Pagamentos (exemplos)
INSERT IGNORE INTO Pagamentos (id_pedido, valor, metodo, id_funcionario_caixa)
VALUES (1, 58.00, 'cartao', 3), (2, 12.00, 'pix', 3);

/* ============================================================
   ASSOCIAÇÕES (PratoDieta, PratoIngrediente, IngredienteAlergenico)
   Observação: essas queries assumem que as entidades já existem.
   ============================================================ */

-- Associar pratos às dietas (exemplo geral: marcar todos como PB/SG)
INSERT IGNORE INTO PratoDieta (id_prato, id_dieta)
SELECT p.id_prato, d.id_dieta FROM Pratos p CROSS JOIN Dietas d WHERE d.nome IN ('PB','SG');

-- Exemplo de composição de Moqueca (se existirem os ingredientes)
INSERT IGNORE INTO PratoIngrediente (id_prato, id_ingrediente, quantidade)
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
JOIN Ingredientes i ON i.nome IN ('Caju', 'Banana da Terra', 'Leite de Coco', 'Azeite de Dendê', 'Arroz Integral', 'Farofa de Dendê')
WHERE p.nome='Moqueca de Caju e Banana da Terra';

-- Associar ingredientes a alérgenos (exemplo)
INSERT IGNORE INTO IngredienteAlergenico (id_ingrediente, id_alergenico)
SELECT i.id_ingrediente, a.id_alergenico
FROM Ingredientes i
JOIN Alergenicos a ON
    (i.nome = 'Castanhas' AND a.nome = 'Castanhas')
    OR (i.nome = 'Tofu' AND a.nome = 'Soja')
    OR (i.nome = 'Edamame' AND a.nome = 'Soja')
    OR (i.nome = 'Leite de Coco' AND a.nome = 'Coco')
    OR (i.nome = 'Néctar de Coco' AND a.nome = 'Coco');

-- IngredienteFornecedor (exemplo)
INSERT IGNORE INTO IngredienteFornecedor (id_ingrediente, id_fornecedor)
SELECT i.id_ingrediente, f.id_fornecedor FROM Ingredientes i CROSS JOIN Fornecedores f LIMIT 10;

/* ============================================================
   CONSULTAS DE VERIFICAÇÃO (opcional, podem ser rodadas manualmente)
   ============================================================ */

-- SHOW TABLES;
-- SHOW FULL TABLES WHERE TABLE_TYPE='VIEW';
-- SHOW FUNCTION STATUS WHERE Db='restauranteterraviva';
-- SHOW TRIGGERS;
-- SHOW PROCEDURE STATUS WHERE Db='restauranteterraviva';
-- SELECT TABLE_NAME, INDEX_NAME FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA='restauranteterraviva';

-- FIM DO SCRIPT
