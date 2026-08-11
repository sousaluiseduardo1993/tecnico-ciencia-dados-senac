-- MySQL dump 10.13  Distrib 8.0.36, for Win64 (x86_64)
--
-- Host: localhost    Database: restaurante_terraviva
-- ------------------------------------------------------
-- Server version	8.0.36

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `funcionarios`
--

DROP TABLE IF EXISTS `funcionarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `funcionarios` (
  `id_funcionario` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(120) NOT NULL,
  `cpf` char(11) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `id_cargo` int NOT NULL,
  `tipo_funcao` enum('atendimento','cozinha','caixa','estoque','gestao') NOT NULL DEFAULT 'atendimento',
  `data_admissao` date NOT NULL,
  `status` enum('ativo','ferias','afastado','demitido') NOT NULL DEFAULT 'ativo',
  `data_desligamento` date DEFAULT NULL,
  `observacoes` text,
  PRIMARY KEY (`id_funcionario`),
  UNIQUE KEY `cpf` (`cpf`),
  KEY `idx_func_cargo` (`id_cargo`),
  CONSTRAINT `funcionarios_ibfk_1` FOREIGN KEY (`id_cargo`) REFERENCES `cargos` (`id_cargo`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `funcionarios`
--

LOCK TABLES `funcionarios` WRITE;
/*!40000 ALTER TABLE `funcionarios` DISABLE KEYS */;
INSERT INTO `funcionarios` VALUES (1,'Funcionario 001','70917445114','func1@rest.veg','112482524',1,'atendimento','2023-08-19','ativo',NULL,NULL),(2,'Funcionario 002','76739771548','func2@rest.veg','115752924',4,'caixa','2025-06-27','afastado',NULL,NULL),(3,'Funcionario 003','91790023530','func3@rest.veg','118305827',5,'cozinha','2024-07-03','ativo',NULL,NULL),(4,'Funcionario 004','56213131878','func4@rest.veg','114902677',1,'estoque','2024-12-01','ativo',NULL,NULL),(5,'Funcionario 005','13625007880','func5@rest.veg','117449023',3,'cozinha','2024-12-10','ativo',NULL,NULL),(6,'Funcionario 006','84944130092','func6@rest.veg','117457344',7,'atendimento','2024-01-25','ativo',NULL,NULL),(7,'Funcionario 007','22836089993','func7@rest.veg','113978036',8,'cozinha','2024-12-28','ativo',NULL,NULL),(8,'Funcionario 008','93573521536','func8@rest.veg','118220725',5,'cozinha','2025-10-01','ativo',NULL,NULL),(9,'Funcionario 009','70075330389','func9@rest.veg','118742351',5,'cozinha','2023-11-29','ativo',NULL,NULL),(10,'Funcionario 010','82966712566','func10@rest.veg','116058068',7,'caixa','2023-06-21','ativo',NULL,NULL),(11,'Funcionario 011','21859356036','func11@rest.veg','111332851',3,'atendimento','2024-02-05','ativo',NULL,NULL),(12,'Funcionario 012','36757204901','func12@rest.veg','111944707',2,'gestao','2023-10-17','ativo',NULL,NULL),(13,'Funcionario 013','25769018498','func13@rest.veg','119468907',7,'gestao','2023-03-29','ativo',NULL,NULL),(14,'Funcionario 014','34206280795','func14@rest.veg','112003327',7,'gestao','2025-02-16','ativo',NULL,NULL),(15,'Funcionario 015','87460705997','func15@rest.veg','110284293',4,'caixa','2024-07-01','ativo',NULL,NULL),(16,'Funcionario 016','89278827969','func16@rest.veg','113701688',3,'atendimento','2023-10-30','ativo',NULL,NULL),(17,'Funcionario 017','04604885638','func17@rest.veg','113669803',8,'estoque','2024-11-02','ativo',NULL,NULL),(18,'Funcionario 018','38355930557','func18@rest.veg','110046165',8,'gestao','2024-12-06','ativo',NULL,NULL),(19,'Funcionario 019','49790949513','func19@rest.veg','117682124',5,'cozinha','2024-09-13','ativo',NULL,NULL),(20,'Funcionario 020','11909498844','func20@rest.veg','117113240',3,'atendimento','2023-07-11','ativo',NULL,NULL),(21,'Funcionario 021','80094729717','func21@rest.veg','110362237',8,'estoque','2023-09-29','ativo',NULL,NULL),(22,'Funcionario 022','99147392435','func22@rest.veg','113207622',5,'estoque','2025-05-19','ativo',NULL,NULL),(23,'Funcionario 023','00311694946','func23@rest.veg','111504660',5,'estoque','2025-03-01','ativo',NULL,NULL),(24,'Funcionario 024','99584304167','func24@rest.veg','110222995',6,'atendimento','2024-05-16','ativo',NULL,NULL),(25,'Funcionario 025','34785896944','func25@rest.veg','118235036',3,'atendimento','2023-06-04','ativo',NULL,NULL),(26,'Funcionario 026','54361531747','func26@rest.veg','116984145',6,'gestao','2025-04-23','ativo',NULL,NULL),(27,'Funcionario 027','19378859195','func27@rest.veg','118052644',6,'caixa','2023-09-03','ativo',NULL,NULL),(28,'Funcionario 028','48701069083','func28@rest.veg','110646933',1,'gestao','2025-07-24','afastado',NULL,NULL),(29,'Funcionario 029','29813311928','func29@rest.veg','115060973',6,'estoque','2024-01-27','ativo',NULL,NULL),(30,'Funcionario 030','92215397573','func30@rest.veg','115330301',1,'gestao','2023-06-09','ativo',NULL,NULL),(31,'Funcionario 031','65025869909','func31@rest.veg','116648630',2,'cozinha','2023-06-30','ativo',NULL,NULL),(32,'Funcionario 032','29162881270','func32@rest.veg','116423104',5,'cozinha','2023-10-25','ativo',NULL,NULL),(33,'Funcionario 033','63802641782','func33@rest.veg','114177140',5,'atendimento','2024-03-10','ativo',NULL,NULL),(34,'Funcionario 034','31841566536','func34@rest.veg','115694549',1,'gestao','2023-10-30','ativo',NULL,NULL),(35,'Funcionario 035','54472640579','func35@rest.veg','112477773',2,'estoque','2025-02-12','ativo',NULL,NULL),(36,'Funcionario 036','70892375679','func36@rest.veg','112628262',1,'atendimento','2025-06-24','ativo',NULL,NULL),(37,'Funcionario 037','72478345755','func37@rest.veg','112658976',4,'atendimento','2023-03-18','ativo',NULL,NULL),(38,'Funcionario 038','67057556068','func38@rest.veg','117863077',2,'gestao','2025-03-24','ativo',NULL,NULL),(39,'Funcionario 039','10554021047','func39@rest.veg','110701173',4,'atendimento','2023-04-05','ativo',NULL,NULL),(40,'Funcionario 040','90876455595','func40@rest.veg','117466677',5,'atendimento','2023-09-16','ativo',NULL,NULL);
/*!40000 ALTER TABLE `funcionarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-19 11:59:14
