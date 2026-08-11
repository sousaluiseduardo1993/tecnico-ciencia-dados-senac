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
-- Table structure for table `pratos`
--

DROP TABLE IF EXISTS `pratos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pratos` (
  `id_prato` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(120) NOT NULL,
  `descricao` text,
  `preco_base` decimal(10,2) NOT NULL,
  `id_categoria` int NOT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `rotulo_certificado` varchar(120) DEFAULT NULL,
  PRIMARY KEY (`id_prato`),
  KEY `idx_prato_categoria` (`id_categoria`),
  CONSTRAINT `pratos_ibfk_1` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pratos`
--

LOCK TABLES `pratos` WRITE;
/*!40000 ALTER TABLE `pratos` DISABLE KEYS */;
INSERT INTO `pratos` VALUES (1,'Prato 001','Descrição do prato 1',18.68,7,1,''),(2,'Prato 002','Descrição do prato 2',15.39,1,1,''),(3,'Prato 003','Descrição do prato 3',40.79,3,1,''),(4,'Prato 004','Descrição do prato 4',44.54,5,1,''),(5,'Prato 005','Descrição do prato 5',11.18,7,1,''),(6,'Prato 006','Descrição do prato 6',16.12,7,1,''),(7,'Prato 007','Descrição do prato 7',10.14,1,1,''),(8,'Prato 008','Descrição do prato 8',30.58,1,1,''),(9,'Prato 009','Descrição do prato 9',25.76,5,1,''),(10,'Prato 010','Descrição do prato 10',10.03,6,1,''),(11,'Prato 011','Descrição do prato 11',22.33,8,1,''),(12,'Prato 012','Descrição do prato 12',33.66,7,1,'orgânico'),(13,'Prato 013','Descrição do prato 13',42.13,4,1,''),(14,'Prato 014','Descrição do prato 14',42.26,3,1,''),(15,'Prato 015','Descrição do prato 15',34.15,2,1,''),(16,'Prato 016','Descrição do prato 16',38.25,3,1,''),(17,'Prato 017','Descrição do prato 17',28.98,4,1,''),(18,'Prato 018','Descrição do prato 18',48.92,4,1,''),(19,'Prato 019','Descrição do prato 19',31.15,7,1,''),(20,'Prato 020','Descrição do prato 20',25.12,3,1,''),(21,'Prato 021','Descrição do prato 21',17.69,3,1,''),(22,'Prato 022','Descrição do prato 22',25.76,1,1,''),(23,'Prato 023','Descrição do prato 23',16.82,3,1,''),(24,'Prato 024','Descrição do prato 24',11.67,2,1,''),(25,'Prato 025','Descrição do prato 25',18.89,6,1,''),(26,'Prato 026','Descrição do prato 26',27.85,5,1,''),(27,'Prato 027','Descrição do prato 27',23.17,5,1,''),(28,'Prato 028','Descrição do prato 28',49.75,4,1,''),(29,'Prato 029','Descrição do prato 29',14.53,4,1,'orgânico'),(30,'Prato 030','Descrição do prato 30',30.18,1,0,''),(31,'Prato 031','Descrição do prato 31',35.63,3,0,'orgânico'),(32,'Prato 032','Descrição do prato 32',44.01,8,0,''),(33,'Prato 033','Descrição do prato 33',30.18,7,0,''),(34,'Prato 034','Descrição do prato 34',48.37,5,1,''),(35,'Prato 035','Descrição do prato 35',27.62,4,1,''),(36,'Prato 036','Descrição do prato 36',44.65,8,1,''),(37,'Prato 037','Descrição do prato 37',29.01,4,0,''),(38,'Prato 038','Descrição do prato 38',14.04,8,1,''),(39,'Prato 039','Descrição do prato 39',42.98,8,1,''),(40,'Prato 040','Descrição do prato 40',15.25,3,1,''),(41,'Prato 041','Descrição do prato 41',15.16,8,1,''),(42,'Prato 042','Descrição do prato 42',37.15,2,1,''),(43,'Prato 043','Descrição do prato 43',16.46,8,1,''),(44,'Prato 044','Descrição do prato 44',29.00,5,1,''),(45,'Prato 045','Descrição do prato 45',45.98,2,1,''),(46,'Prato 046','Descrição do prato 46',26.16,3,1,''),(47,'Prato 047','Descrição do prato 47',34.50,5,1,''),(48,'Prato 048','Descrição do prato 48',51.25,6,1,''),(49,'Prato 049','Descrição do prato 49',36.65,5,1,''),(50,'Prato 050','Descrição do prato 50',10.58,3,1,''),(51,'Prato 051','Descrição do prato 51',50.25,3,1,''),(52,'Prato 052','Descrição do prato 52',32.25,6,1,''),(53,'Prato 053','Descrição do prato 53',16.25,1,1,''),(54,'Prato 054','Descrição do prato 54',20.08,4,1,''),(55,'Prato 055','Descrição do prato 55',47.24,1,0,'orgânico'),(56,'Prato 056','Descrição do prato 56',41.96,8,1,''),(57,'Prato 057','Descrição do prato 57',52.07,3,1,''),(58,'Prato 058','Descrição do prato 58',54.86,1,1,'orgânico'),(59,'Prato 059','Descrição do prato 59',37.92,5,1,'orgânico'),(60,'Prato 060','Descrição do prato 60',17.80,3,1,'');
/*!40000 ALTER TABLE `pratos` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-19 11:59:10
