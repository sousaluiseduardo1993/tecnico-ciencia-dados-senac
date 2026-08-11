USE restaurante_terraviva;

DELIMITER $$

DROP PROCEDURE IF EXISTS popular_restaurante$$
CREATE PROCEDURE popular_restaurante()
BEGIN
  DECLARE v_N_CARGOS INT DEFAULT 8;
  DECLARE v_N_FUNCIONARIOS INT DEFAULT 40;
  DECLARE v_N_CLIENTES INT DEFAULT 120;
  DECLARE v_N_PREFS INT DEFAULT 6;
  DECLARE v_N_INGREDIENTES INT DEFAULT 80;
  DECLARE v_N_CATEGORIAS INT DEFAULT 8;
  DECLARE v_N_PRATOS INT DEFAULT 60;
  DECLARE v_MIN_ING_POR_PRATO INT DEFAULT 3;
  DECLARE v_MAX_ING_POR_PRATO INT DEFAULT 6;
  DECLARE v_N_ALERGENICOS INT DEFAULT 6;
  DECLARE v_N_PLATAFORMAS INT DEFAULT 4;
  DECLARE v_N_REPASSES INT DEFAULT 12;
  DECLARE v_N_MESAS INT DEFAULT 20;
  DECLARE v_N_FORNECEDORES INT DEFAULT 15;
  DECLARE v_N_MOVIMENTOS INT DEFAULT 160;
  DECLARE v_N_CUSTO_HIST INT DEFAULT 120;
  DECLARE v_N_DIETAS INT DEFAULT 6;
  DECLARE v_N_CERTS INT DEFAULT 6;
  DECLARE v_N_ZONAS INT DEFAULT 4;
  DECLARE v_N_PEDIDOS INT DEFAULT 150;
  DECLARE v_N_ITENSPEDIDO_GOAL INT DEFAULT 420;
  DECLARE v_N_PAGAMENTOS INT DEFAULT 140;

  DECLARE i,j,k,p,cnt INT DEFAULT 0;
  DECLARE rand_cargo, rand_tipo, v_max_ing, v_max_prato, v_max_al, v_max_diet, v_max_cert, v_max_zona, tmp_q, last_id, id_prato_escolhido INT DEFAULT 0;
  DECLARE ing_sel, dias_sel INT DEFAULT 0;

  -- === CARGOS ===
  SET i = 1;
  WHILE i <= v_N_CARGOS DO
    INSERT INTO Cargos (nome, descricao, salario_base)
    VALUES (CONCAT('Cargo ', i), CONCAT('Descrição para cargo ', i), 1200 + (i * 100));
    SET i = i + 1;
  END WHILE;

  -- === FUNCIONÁRIOS ===
  SET i = 1;
  WHILE i <= v_N_FUNCIONARIOS DO
    SET rand_cargo = FLOOR(1 + RAND() * v_N_CARGOS);
    INSERT INTO Funcionarios (nome, cpf, email, telefone, id_cargo, tipo_funcao, data_admissao, status)
    VALUES (
      CONCAT('Funcionario ', LPAD(i,3,'0')),
      LPAD(FLOOR(RAND()*99999999999),11,'0'),
      CONCAT('func',i,'@rest.veg'),
      CONCAT('11', LPAD(FLOOR(RAND()*9999999),7,'0')),
      rand_cargo,
      ELT(1 + FLOOR(RAND()*5), 'atendimento','cozinha','caixa','estoque','gestao'),
      DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*1000) DAY),
      IF(RAND() < 0.02,'afastado','ativo')
    );
    SET i = i + 1;
  END WHILE;

  -- === CLIENTES E PREFERÊNCIAS ===
  INSERT IGNORE INTO PreferenciasAlimentares (descricao)
  VALUES ('vegano'),('vegetariano'),('ovo-lacto'),('lacto'),('ovo'),('pescatariano');

  SET i = 1;
  WHILE i <= v_N_CLIENTES DO
    INSERT INTO Clientes (nome, email, telefone, data_cadastro)
    VALUES (
      CONCAT('Cliente ', LPAD(i,4,'0')),
      CONCAT('cliente',i,'@mail.com'),
      CONCAT('21', LPAD(FLOOR(RAND()*99999999),8,'0')),
      DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*400) DAY)
    );
    SET last_id = LAST_INSERT_ID();
    SET j = 1 + FLOOR(RAND()*2);
    SET k = 1;
    WHILE k <= j DO
      INSERT IGNORE INTO ClientePreferencia (id_cliente, id_preferencia)
      VALUES (last_id, 1 + FLOOR(RAND()*v_N_PREFS));
      SET k = k + 1;
    END WHILE;
    SET i = i + 1;
  END WHILE;

  -- === INGREDIENTES ===
  SET i = 1;
  WHILE i <= v_N_INGREDIENTES DO
    SET rand_tipo = 1 + FLOOR(RAND()*5);
    INSERT INTO Ingredientes (nome, unidade_medida, tipo, origem, valor, contem_ovo, contem_leite, ativo)
    VALUES (
      CONCAT('Ingred_', LPAD(i,3,'0')),
      ELT(1 + FLOOR(RAND()*4),'kg','g','un','l'),
      ELT(rand_tipo,'verdura','grãos','laticinio','ovo','temperos'),
      ELT(rand_tipo,'vegetal','vegetal','animal','animal','vegetal'),
      ROUND(0.5 + RAND()*20,4),
      rand_tipo=4,
      rand_tipo=3,
      TRUE
    );
    SET i = i + 1;
  END WHILE;

  -- === CATEGORIAS ===
  SET i = 1;
  WHILE i <= v_N_CATEGORIAS DO
    INSERT INTO Categorias (nome) VALUES (CONCAT('Categoria ', i));
    SET i = i + 1;
  END WHILE;

  -- === PRATOS ===
  SET i = 1;
  WHILE i <= v_N_PRATOS DO
    SET tmp_q = 1 + FLOOR(RAND()*v_N_CATEGORIAS);
    INSERT INTO Pratos (nome, descricao, preco_base, id_categoria, ativo, rotulo_certificado)
    VALUES (
      CONCAT('Prato ', LPAD(i,3,'0')),
      CONCAT('Descrição do prato ', i),
      ROUND(10 + RAND()*45,2),
      tmp_q,
      IF(RAND() < 0.9, TRUE, FALSE),
      IF(RAND() < 0.08, 'orgânico','')
    );
    SET last_id = LAST_INSERT_ID();
    INSERT IGNORE INTO ValoresNutricionais (id_prato, calorias, carboidratos, proteinas, gorduras)
    VALUES (last_id, 200 + FLOOR(RAND()*500), ROUND(RAND()*80,2), ROUND(RAND()*40,2), ROUND(RAND()*30,2));
    SET i = i + 1;
  END WHILE;

  -- === RELACIONAR PRATO/INGREDIENTES ===
  SET v_max_ing = (SELECT MAX(id_ingrediente) FROM Ingredientes);
  SET v_max_prato = (SELECT MAX(id_prato) FROM Pratos);

  SET p = 1;
  WHILE p <= v_max_prato DO
    SET tmp_q = v_MIN_ING_POR_PRATO + FLOOR(RAND()*(v_MAX_ING_POR_PRATO - v_MIN_ING_POR_PRATO + 1));
    SET k = 1;
    WHILE k <= tmp_q DO
      INSERT IGNORE INTO PratoIngrediente (id_prato, id_ingrediente, quantidade)
      VALUES (p, 1 + FLOOR(RAND()*v_max_ing), ROUND(0.05 + RAND()*2.0,3));
      SET k = k + 1;
    END WHILE;
    SET p = p + 1;
  END WHILE;

  -- === ALERGÊNICOS ===
  INSERT IGNORE INTO Alergenicos (nome,tipo)
  VALUES ('leite','proteína láctea'),('ovo','proteína do ovo'),('soja','soja'),
         ('gluten','trigo'),('amendoim','castanhas'),('nozes','castanhas');

  SET v_max_al = (SELECT MAX(id_alergenico) FROM Alergenicos);

  SET i = 1;
  WHILE i <= v_max_ing DO
    IF RAND() < 0.18 THEN
      INSERT IGNORE INTO IngredienteAlergenico (id_ingrediente, id_alergenico)
      VALUES (i, 1 + FLOOR(RAND()*v_max_al));
    END IF;
    SET i = i + 1;
  END WHILE;

  -- === PLATAFORMAS & REPASSES ===
  INSERT IGNORE INTO Plataformas (nome, taxa_percentual, tipo_repasse)
  VALUES ('AppFast', 12.5, 'plataforma'),('MenuJá', 10.0, 'plataforma'),('SiteLoja', 0.0, 'loja'),('Telefone', 0.0, 'loja');

  SET i = 1;
  WHILE i <= v_N_REPASSES DO
    INSERT INTO RepassesPlataforma (id_plataforma, data_inicio, data_fim, valor_total)
    VALUES (1 + FLOOR(RAND()*v_N_PLATAFORMAS), DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*200) DAY),
            DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND()*30) DAY), ROUND(100 + RAND()*5000,2));
    SET i = i + 1;
  END WHILE;

  -- === MESAS ===
  SET i = 1;
  WHILE i <= v_N_MESAS DO
    INSERT INTO Mesas (numero, capacidade, status, observacao)
    VALUES (i, 2 + FLOOR(RAND()*6),
            ELT(1 + FLOOR(RAND()*4),'livre','ocupada','reservada','indisponivel'),
            IF(RAND() < 0.05, 'Mesa reservada',''));
    SET i = i + 1;
  END WHILE;

  -- === FORNECEDORES ===
  SET i = 1;
  WHILE i <= v_N_FORNECEDORES DO
    INSERT INTO Fornecedores (nome, contato, telefone)
    VALUES (CONCAT('Fornecedor ',LPAD(i,3,'0')), CONCAT('contato',i,'@forn.com'),
            CONCAT('31', LPAD(FLOOR(RAND()*99999999),8,'0')));
    SET i = i + 1;
  END WHILE;

  -- === MOVIMENTOS DE ESTOQUE ===
  SET i = 1;
  WHILE i <= v_N_MOVIMENTOS DO
    INSERT INTO MovimentosEstoque (id_ingrediente, tipo, quantidade, data_hora, id_fornecedor, id_funcionario_responsavel, observacao)
    VALUES (1 + FLOOR(RAND()*v_max_ing), ELT(1 + FLOOR(RAND()*3),'entrada','saida','ajuste'),
            ROUND(0.1 + RAND()*20,3), DATE_SUB(CURRENT_TIMESTAMP, INTERVAL FLOOR(RAND()*400) HOUR),
            1 + FLOOR(RAND()*v_N_FORNECEDORES), 1 + FLOOR(RAND()*v_N_FUNCIONARIOS),
            CONCAT('Movimento automático #', i));
    SET i = i + 1;
  END WHILE;

  -- === HISTÓRICO DE CUSTOS ===
  SET i = 1;
  WHILE i <= v_N_CUSTO_HIST DO
    SET ing_sel = 1 + FLOOR(RAND()*v_max_ing);
    SET dias_sel = FLOOR(RAND()*365);
    INSERT INTO CustoIngredienteHistorico (id_ingrediente, data, valor)
    VALUES (ing_sel, DATE_SUB(CURDATE(), INTERVAL dias_sel DAY), ROUND(0.2 + RAND()*25,4))
    ON DUPLICATE KEY UPDATE valor = VALUES(valor);
    SET i = i + 1;
  END WHILE;

  -- === DIETAS ===
  INSERT IGNORE INTO Dietas (nome, descricao)
  VALUES ('vegano','Sem produtos de origem animal'),('vegetariano','Sem carne ou peixe'),
         ('ovo-lacto','Aceita ovos e laticínios'),('lacto','Apenas laticínios'),
         ('ovo','Apenas ovos'),('pescatariano','Inclui peixe');
  SET v_max_diet = (SELECT MAX(id_dieta) FROM Dietas);

  -- === CERTIFICAÇÕES ===
  INSERT IGNORE INTO Certificacoes (nome, emissor, descricao)
  VALUES ('Orgânico Local','CertOrg','Orgânico local'),('Selo Vegetariano','VegSeal','Vegetariano'),
         ('Fornecedor Qualificado','FQ','Fornecedor validado'),('Sem Glúten','SG','Sem glúten'),
         ('Sem Lactose','SL','Sem lactose'),('FairTrade','FT','Comércio justo');
  SET v_max_cert = (SELECT MAX(id_certificacao) FROM Certificacoes);

  -- === ZONAS ===
  INSERT IGNORE INTO ZonasCozinha (nome, descricao)
  VALUES ('zona_laticinios','Laticínios'),('zona_ovos','Ovos'),('zona_vegana','Vegana'),('zona_temperos','Temperos');
  SET v_max_zona = (SELECT MAX(id_zona) FROM ZonasCozinha);

  -- === PEDIDOS ===
  SET i = 1;
  WHILE i <= v_N_PEDIDOS DO
    INSERT INTO Pedidos (id_cliente, id_plataforma, tipo, status, data_hora, id_mesa, id_funcionario_atendente)
    VALUES (1 + FLOOR(RAND()*v_N_CLIENTES),
            IF(RAND()<0.6,1+FLOOR(RAND()*v_N_PLATAFORMAS),NULL),
            ELT(1 + FLOOR(RAND()*3),'mesa','balcao','delivery'),
            ELT(1 + FLOOR(RAND()*5),'aberto','preparo','entregue','finalizado','cancelado'),
            DATE_SUB(CURRENT_TIMESTAMP, INTERVAL FLOOR(RAND()*720) HOUR),
            IF(RAND()<0.6,1+FLOOR(RAND()*v_N_MESAS),NULL),
            1+FLOOR(RAND()*v_N_FUNCIONARIOS));
    SET i = i + 1;
  END WHILE;

  -- === ITENS PEDIDO ===
  SET v_max_prato = (SELECT MAX(id_prato) FROM Pratos);
  SET cnt = 0;
  WHILE cnt <= v_N_ITENSPEDIDO_GOAL DO
    SET p = 1 + FLOOR(RAND()*(SELECT MAX(id_pedido) FROM Pedidos));
    SET id_prato_escolhido = 1 + FLOOR(RAND()*v_max_prato);
    SET tmp_q = 1 + FLOOR(RAND()*4);
    INSERT INTO ItensPedido (id_pedido,id_prato,quantidade,preco_unitario,custo_estimado,id_funcionario_preparo)
    VALUES (p,id_prato_escolhido,tmp_q,(SELECT preco_base FROM Pratos WHERE id_prato=id_prato_escolhido),
            ROUND((SELECT AVG(valor) FROM Ingredientes)*0.8,2),1+FLOOR(RAND()*v_N_FUNCIONARIOS));
    SET cnt = cnt + 1;
  END WHILE;

  -- === PAGAMENTOS ===
  SET i = 1;
  WHILE i <= v_N_PAGAMENTOS DO
    SET p = 1 + FLOOR(RAND()*(SELECT MAX(id_pedido) FROM Pedidos));
    INSERT INTO Pagamentos (id_pedido, valor, metodo, data_hora, id_funcionario_caixa)
    VALUES (p, ROUND(5 + RAND()*80,2), ELT(1 + FLOOR(RAND()*3),'dinheiro','cartao','pix'),
            DATE_SUB(CURRENT_TIMESTAMP, INTERVAL FLOOR(RAND()*720) HOUR),
            1 + FLOOR(RAND()*v_N_FUNCIONARIOS));
    SET i = i + 1;
  END WHILE;

END$$

DELIMITER ;

CALL popular_restaurante();
DROP PROCEDURE IF EXISTS popular_restaurante;
