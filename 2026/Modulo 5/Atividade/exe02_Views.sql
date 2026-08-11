-- ==========================================
-- ATIVIDADE: Monitoramento ESG da Frota
-- ==========================================

-- 0) Criação do Banco
CREATE DATABASE IF NOT EXISTS transportadora_esg;
USE transportadora_esg;

-- Limpeza
DROP VIEW IF EXISTS Relatorio_Eficiencia_Frota;
DROP TABLE IF EXISTS Viagens;
DROP TABLE IF EXISTS Veiculos;

-- 1) Estruturação

CREATE TABLE Veiculos (
    id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
    modelo VARCHAR(80) NOT NULL,
    tipo_combustivel ENUM('Diesel','Elétrico','Flex') NOT NULL,
    capacidade_carga INT NOT NULL
);

CREATE TABLE Viagens (
    id_viagem INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo INT NOT NULL,
    distancia_km DECIMAL(10,2) NOT NULL,
    consumo_combustivel DECIMAL(10,2) NOT NULL,
    data_viagem DATE NOT NULL,
    FOREIGN KEY (id_veiculo) REFERENCES Veiculos(id_veiculo)
);

-- 2) Inserção de Dados

INSERT INTO Veiculos (modelo, tipo_combustivel, capacidade_carga) VALUES
('Volvo FH 540', 'Diesel', 25000),
('Renault Kangoo E-Tech', 'Elétrico', 800),
('Fiat Ducato', 'Flex', 1600);

INSERT INTO Viagens (id_veiculo, distancia_km, consumo_combustivel, data_viagem) VALUES
(1, 320, 80, '2026-02-10'),
(1, 180, 45, '2026-01-18'),
(1, 410, 102.5, '2025-11-20'),
(2, 95, 18.5, '2026-02-03'),
(2, 120, 22, '2025-12-15'),
(2, 60, 12, '2025-09-05'),
(3, 200, 28, '2026-02-01'),
(3, 150, 21.5, '2025-08-10'),
(3, 175, 25, '2025-07-12');

-- 3) Criação da VIEW

CREATE VIEW Relatorio_Eficiencia_Frota AS
SELECT
    v.modelo,
    v.tipo_combustivel,
    SUM(vi.distancia_km) AS total_km_rodados,
    ROUND(SUM(vi.distancia_km) / SUM(vi.consumo_combustivel), 2) 
        AS media_consumo_km_por_litro,
    COUNT(vi.id_viagem) AS quantidade_viagens
FROM Veiculos v
JOIN Viagens vi ON v.id_veiculo = vi.id_veiculo
WHERE vi.data_viagem >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY v.id_veiculo, v.modelo, v.tipo_combustivel;

-- 4) Validação

SELECT * 
FROM Relatorio_Eficiencia_Frota
ORDER BY total_km_rodados DESC;