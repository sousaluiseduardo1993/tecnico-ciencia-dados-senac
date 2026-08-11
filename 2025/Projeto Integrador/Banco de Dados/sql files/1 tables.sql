/* ============================================================
   BANCO DE DADOS PRINCIPAL
   ============================================================ */
CREATE DATABASE IF NOT EXISTS restaurante_terraviva
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE restaurante_terraviva;


/* ============================================================
   1. DOMÍNIO DE CLIENTES E PREFERÊNCIAS
   ============================================================ */

-- Clientes cadastrados
CREATE TABLE IF NOT EXISTS Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(150) UNIQUE,
    telefone VARCHAR(20),
    data_cadastro DATE NOT NULL DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tipos de preferências alimentares
CREATE TABLE IF NOT EXISTS PreferenciasAlimentares (
    id_preferencia INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(120) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Relação N:N cliente ↔ preferências
CREATE TABLE IF NOT EXISTS ClientePreferencia (
    id_cliente INT NOT NULL,
    id_preferencia INT NOT NULL,
    PRIMARY KEY (id_cliente, id_preferencia),
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_preferencia) REFERENCES PreferenciasAlimentares(id_preferencia)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* ============================================================
   2. DOMÍNIO DO CARDÁPIO (Categorias, Pratos e Ingredientes)
   ============================================================ */

-- Categorias de pratos
CREATE TABLE IF NOT EXISTS Categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Pratos do cardápio
CREATE TABLE IF NOT EXISTS Pratos (
    id_prato INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    descricao TEXT,
    preco_base DECIMAL(10,2) DEFAULT NULL,   -- Preço pode ser definido depois
    id_categoria INT NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    rotulo_certificado VARCHAR(120) NULL,
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria)
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Cadastro de ingredientes
CREATE TABLE IF NOT EXISTS Ingredientes (
    id_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    unidade_medida VARCHAR(20) NOT NULL,
    tipo VARCHAR(50),
    origem VARCHAR(50),
    valor DECIMAL(10,4) NOT NULL DEFAULT 0.0000,
    contem_ovo BOOLEAN NOT NULL DEFAULT FALSE,
    contem_leite BOOLEAN NOT NULL DEFAULT FALSE,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Relação N:N prato ↔ ingredientes
CREATE TABLE IF NOT EXISTS PratoIngrediente (
    id_prato INT NOT NULL,
    id_ingrediente INT NOT NULL,
    quantidade DECIMAL(10,3) NOT NULL,
    PRIMARY KEY (id_prato, id_ingrediente),
    FOREIGN KEY (id_prato) REFERENCES Pratos(id_prato)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_ingrediente) REFERENCES Ingredientes(id_ingrediente)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Valores nutricionais de cada prato
CREATE TABLE IF NOT EXISTS ValoresNutricionais (
    id_prato INT PRIMARY KEY,
    calorias INT NOT NULL,
    carboidratos DECIMAL(10,2),
    proteinas DECIMAL(10,2),
    gorduras DECIMAL(10,2),
    FOREIGN KEY (id_prato) REFERENCES Pratos(id_prato)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* ============================================================
   3. ALERGÊNICOS – Mapeamento de ingredientes
   ============================================================ */

CREATE TABLE IF NOT EXISTS Alergenicos (
    id_alergenico INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS IngredienteAlergenico (
    id_ingrediente INT NOT NULL,
    id_alergenico INT NOT NULL,
    PRIMARY KEY (id_ingrediente, id_alergenico),
    FOREIGN KEY (id_ingrediente) REFERENCES Ingredientes(id_ingrediente)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_alergenico) REFERENCES Alergenicos(id_alergenico)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* ============================================================
   4. MARKETPLACES E REGRAS DE REPASSES
   ============================================================ */

-- Plataformas como iFood, UberEats etc.
CREATE TABLE IF NOT EXISTS Plataformas (
    id_plataforma INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    taxa_percentual DECIMAL(5,2) NOT NULL,
    tipo_repasse ENUM('loja','plataforma') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS RepassesPlataforma (
    id_repasse INT AUTO_INCREMENT PRIMARY KEY,
    id_plataforma INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    valor_total DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (id_plataforma) REFERENCES Plataformas(id_plataforma)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* ============================================================
   5. MESAS E GESTÃO DE SALÃO
   ============================================================ */

CREATE TABLE IF NOT EXISTS Mesas (
    id_mesa INT AUTO_INCREMENT PRIMARY KEY,
    numero INT NOT NULL UNIQUE,
    capacidade INT NOT NULL,
    status ENUM('livre','ocupada','reservada','indisponivel') NOT NULL DEFAULT 'livre',
    observacao VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* ============================================================
   6. RECURSOS HUMANOS – Cargos, Funcionários e Turnos
   ============================================================ */

CREATE TABLE IF NOT EXISTS Cargos (
    id_cargo INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    salario_base DECIMAL(10,2) DEFAULT 0.00,
    data_criacao DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS Turnos (
    id_turno INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    inicio TIME NOT NULL,
    fim TIME NOT NULL,
    carga_horaria DECIMAL(5,2) GENERATED ALWAYS AS (
        TIME_TO_SEC(TIMEDIFF(fim, inicio)) / 3600
    ) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Relação funcionário ↔ turno ao longo do tempo
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* ============================================================
   8. ESTOQUE, FORNECEDORES E CUSTOS
   ============================================================ */

CREATE TABLE IF NOT EXISTS Fornecedores (
    id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    contato VARCHAR(120),
    telefone VARCHAR(30)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Histórico de custos por ingrediente
CREATE TABLE IF NOT EXISTS CustoIngredienteHistorico (
    id_ingrediente INT NOT NULL,
    data DATE NOT NULL,
    valor DECIMAL(10,4) NOT NULL,
    PRIMARY KEY (id_ingrediente, data),
    FOREIGN KEY (id_ingrediente) REFERENCES Ingredientes(id_ingrediente)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


/* ============================================================
   9. DIETAS, CERTIFICAÇÕES E ZONAS DA COZINHA
   ============================================================ */

CREATE TABLE IF NOT EXISTS Dietas (
    id_dieta INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(60) NOT NULL UNIQUE,
    descricao VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS PratoDieta (
    id_prato INT NOT NULL,
    id_dieta INT NOT NULL,
    PRIMARY KEY (id_prato, id_dieta),
    FOREIGN KEY (id_prato) REFERENCES Pratos(id_prato) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_dieta) REFERENCES Dietas(id_dieta) 
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS Certificacoes (
    id_certificacao INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    emissor VARCHAR(120),
    descricao TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Certificação pode ser associada a ingrediente ou prato
CREATE TABLE IF NOT EXISTS ItemCertificacao (
    id_item_certificacao INT AUTO_INCREMENT PRIMARY KEY,
    tipo_enum ENUM('prato','ingrediente') NOT NULL,
    id_item INT NOT NULL,
    id_certificacao INT NOT NULL,
    FOREIGN KEY (id_certificacao) REFERENCES Certificacoes(id_certificacao)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ZonasCozinha (
    id_zona INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS IngredienteZona (
    id_ingrediente INT NOT NULL,
    id_zona INT NOT NULL,
    PRIMARY KEY (id_ingrediente, id_zona),
    FOREIGN KEY (id_ingrediente) REFERENCES Ingredientes(id_ingrediente) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_zona) REFERENCES ZonasCozinha(id_zona)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

USE restaurante_terraviva;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;