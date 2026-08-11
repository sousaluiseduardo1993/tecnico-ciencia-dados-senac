-- ============================================================
-- BANCO DE DADOS: Plataforma de Cursos Online
-- ============================================================

CREATE DATABASE plataforma_cursos;
USE plataforma_cursos;

-- ============================================================
-- TABELA: ALUNOS
-- ============================================================
CREATE TABLE alunos (
    id_aluno INT PRIMARY KEY,
    nome_aluno VARCHAR(100),
    email VARCHAR(150)
);

-- ============================================================
-- TABELA: CURSOS
-- ============================================================
CREATE TABLE cursos (
    id_curso INT PRIMARY KEY,
    titulo_curso VARCHAR(150),
    instrutor VARCHAR(100)
);

-- ============================================================
-- TABELA: INSCRICOES
-- ============================================================
CREATE TABLE inscricoes (
    id_inscricao INT PRIMARY KEY,
    fk_id_aluno INT,
    fk_id_curso INT,
    data_inscricao DATE,
    FOREIGN KEY (fk_id_aluno) REFERENCES alunos(id_aluno),
    FOREIGN KEY (fk_id_curso) REFERENCES cursos(id_curso)
);

-- ============================================================
-- INSERTS DE TESTE (EXATOS DA ATIVIDADE)
-- ============================================================

-- Alunos
INSERT INTO alunos (id_aluno, nome_aluno, email) VALUES
(1, 'Ana Silva', 'ana@email.com'),
(2, 'Bruno Costa', 'bruno@email.com'),
(3, 'Carla Souza', 'carla@email.com'); -- sem inscrição

-- Cursos
INSERT INTO cursos (id_curso, titulo_curso, instrutor) VALUES
(10, 'Introdução ao Python', 'Prof. Marcos'),
(20, 'SQL Avançado', 'Prof. Joana'),
(30, 'Modelagem de Dados', 'Prof. Felipe'); -- sem inscrições

-- Inscrições
INSERT INTO inscricoes (id_inscricao, fk_id_aluno, fk_id_curso, data_inscricao) VALUES
(100, 1, 10, '2024-01-10'),
(101, 1, 20, '2024-01-15'),
(102, 2, 10, '2024-02-01');

-- ============================================================
-- TAREFA 1: INNER JOIN
-- Objetivo: Listar SOMENTE alunos que possuem inscrição.
-- Resultado esperado:
-- Ana Silva  | Introdução ao Python
-- Ana Silva  | SQL Avançado
-- Bruno Costa | Introdução ao Python
-- ============================================================

SELECT 
    a.nome_aluno,
    c.titulo_curso
FROM alunos a
INNER JOIN inscricoes i ON a.id_aluno = i.fk_id_aluno
INNER JOIN cursos c ON c.id_curso = i.fk_id_curso
ORDER BY a.nome_aluno, c.titulo_curso;

-- ============================================================
-- TAREFA 2 : LEFT JOIN + COUNT
-- Objetivo: Listar TODOS os cursos e contar quantos alunos
-- estão inscritos (incluindo cursos com **zero** inscrições).
-- Resultado esperado:
-- Introdução ao Python | 2
-- SQL Avançado         | 1
-- Modelagem de Dados   | 0
-- ============================================================

SELECT 
    c.titulo_curso,
    COUNT(i.fk_id_curso) AS total_inscricoes
FROM cursos c
LEFT JOIN inscricoes i ON c.id_curso = i.fk_id_curso
GROUP BY c.id_curso, c.titulo_curso
ORDER BY total_inscricoes DESC;
