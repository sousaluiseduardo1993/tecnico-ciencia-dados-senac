-- setup.sql
-- Rodar como root (ou outro DBA) no MySQL 8.0
-- Ajustado e aprimorado para MySQL Workbench 8.0 CE
-- Inclui todas as funcionalidades do original + melhorias DBA nível sênior 🧙‍♂️

-- 0. Cria base e usa
DROP DATABASE IF EXISTS empresa_db;
CREATE DATABASE empresa_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE empresa_db;

-- 1. Tabelas
CREATE TABLE IF NOT EXISTS Clientes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE,
  cpf VARCHAR(20) UNIQUE,
  criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Produtos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  descricao TEXT,
  preco DECIMAL(10,2) CHECK (preco >= 0),
  criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Pedidos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  cliente_id INT,
  data_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
  valor_total DECIMAL(10,2) CHECK (valor_total >= 0),
  FOREIGN KEY (cliente_id) REFERENCES Clientes(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS TabelaPrecos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  produto_id INT NOT NULL,
  preco DECIMAL(10,2) CHECK (preco >= 0),
  atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (produto_id) REFERENCES Produtos(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 2. Inserir alguns dados de teste
INSERT INTO Clientes (nome, email, cpf) VALUES ('Cliente Teste', 'cliente@ex.com','000.000.000-00');
INSERT INTO Produtos (nome, descricao, preco) VALUES ('Produto A','Desc A', 10.00);
INSERT INTO TabelaPrecos (produto_id, preco) VALUES (1, 10.00);

-- 3. Criar roles
DROP ROLE IF EXISTS leitor, editor, administrador;
CREATE ROLE leitor;
CREATE ROLE editor;
CREATE ROLE administrador;

-- 4. Criar users de teste
DROP USER IF EXISTS 'joao'@'localhost', 'maria'@'localhost', 'admin_user'@'localhost';
CREATE USER 'joao'@'localhost' IDENTIFIED BY 'senha_joao_123';
CREATE USER 'maria'@'localhost' IDENTIFIED BY 'senha_maria_456';
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'senha_admin_789';

-- 5. Atribuir roles aos usuários
GRANT leitor TO 'joao'@'localhost';
GRANT editor TO 'maria'@'localhost';
GRANT administrador TO 'admin_user'@'localhost';

-- Opcional: definir role padrão ao conectar
SET DEFAULT ROLE leitor FOR 'joao'@'localhost';
SET DEFAULT ROLE editor FOR 'maria'@'localhost';
SET DEFAULT ROLE administrador FOR 'admin_user'@'localhost';

-- 6. Conceder privilégios por role (uso do DB qualificado)
-- LEITOR: SELECT apenas
GRANT SELECT ON empresa_db.Clientes TO leitor;
GRANT SELECT ON empresa_db.Pedidos TO leitor;
GRANT SELECT ON empresa_db.Produtos TO leitor;
GRANT SELECT ON empresa_db.TabelaPrecos TO leitor;

-- EDITOR: SELECT, INSERT, UPDATE (inicialmente com UPDATE em TabelaPrecos)
GRANT SELECT, INSERT, UPDATE ON empresa_db.Clientes TO editor;
GRANT SELECT, INSERT, UPDATE ON empresa_db.Pedidos TO editor;
GRANT SELECT, INSERT, UPDATE ON empresa_db.Produtos TO editor;
GRANT SELECT, INSERT, UPDATE ON empresa_db.TabelaPrecos TO editor;

-- ADMINISTRADOR: ALL PRIVILEGES nas tabelas
GRANT ALL PRIVILEGES ON empresa_db.* TO administrador;

-- View para auditoria de permissões
CREATE OR REPLACE VIEW v_roles_permissoes AS
SELECT grantee, table_name, privilege_type
FROM information_schema.table_privileges
WHERE table_schema = 'empresa_db';

-- Trigger de auditoria
DROP TABLE IF EXISTS AuditoriaPrecos;
CREATE TABLE AuditoriaPrecos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  produto_id INT,
  preco_antigo DECIMAL(10,2),
  preco_novo DECIMAL(10,2),
  alterado_por VARCHAR(100),
  alterado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER trg_update_preco
BEFORE UPDATE ON TabelaPrecos
FOR EACH ROW
BEGIN
  INSERT INTO AuditoriaPrecos (produto_id, preco_antigo, preco_novo, alterado_por)
  VALUES (OLD.produto_id, OLD.preco, NEW.preco, CURRENT_USER());
END //
DELIMITER ;

FLUSH PRIVILEGES;

-- tests_manual.sql
USE empresa_db;

-- 1) Teste como JOAO (role leitor)
-- Conectar como 'joao'@'localhost' e executar:
SELECT '--- JOAO: TESTE SELECT Clientes ---' AS etapa;
SELECT * FROM Clientes;                 -- deve funcionar
-- Tentar INSERT (deve falhar)
INSERT INTO Clientes (nome, email, cpf) VALUES ('X Joao','x@ex.com','111');  -- deve falhar

-- 2) Teste como MARIA (role editor)
SELECT '--- MARIA: TESTE SELECT ---' AS etapa;
SELECT * FROM TabelaPrecos;             -- deve funcionar
SELECT '--- MARIA: TESTE INSERT ---' AS etapa;
INSERT INTO TabelaPrecos (produto_id, preco) VALUES (1, 11.11);  -- deve funcionar
SELECT '--- MARIA: TESTE UPDATE ---' AS etapa;
UPDATE TabelaPrecos SET preco = 12.34 WHERE id = 1;             -- deve funcionar
SELECT '--- MARIA: TESTE DELETE ---' AS etapa;
DELETE FROM TabelaPrecos WHERE id = 9999;                       -- deve falhar

-- 3) Teste como ADMIN_USER (role administrador)
SELECT '--- ADMIN: TESTE UPDATE ---' AS etapa;
UPDATE TabelaPrecos SET preco = 99.99 WHERE id = 1;  -- deve funcionar
SELECT '--- ADMIN: TESTE DELETE ---' AS etapa;
DELETE FROM TabelaPrecos WHERE id = 2;               -- deve funcionar

-- apply_policy_revoke.sql
USE empresa_db;

-- Revogar UPDATE na TabelaPrecos do role editor
REVOKE UPDATE ON empresa_db.TabelaPrecos FROM editor;
FLUSH PRIVILEGES;

-- tests_automated.sh
-- (mantido conforme original, sem alterações significativas para Workbench)

-- cleanup.sql
USE mysql;

DROP USER IF EXISTS 'joao'@'localhost';
DROP USER IF EXISTS 'maria'@'localhost';
DROP USER IF EXISTS 'admin_user'@'localhost';
DROP ROLE IF EXISTS leitor, editor, administrador;
DROP DATABASE IF EXISTS empresa_db;

FLUSH PRIVILEGES;
