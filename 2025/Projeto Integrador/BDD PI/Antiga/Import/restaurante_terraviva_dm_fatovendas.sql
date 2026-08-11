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
-- Table structure for table `dm_fatovendas`
--

DROP TABLE IF EXISTS `dm_fatovendas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dm_fatovendas` (
  `id_fato` int NOT NULL AUTO_INCREMENT,
  `id_tempo` int NOT NULL,
  `id_prato` int NOT NULL,
  `id_cliente` int DEFAULT NULL,
  `quantidade` int DEFAULT NULL,
  `receita` decimal(10,2) DEFAULT NULL,
  `custo` decimal(10,2) DEFAULT NULL,
  `lucro` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id_fato`),
  KEY `id_tempo` (`id_tempo`),
  KEY `id_prato` (`id_prato`),
  KEY `id_cliente` (`id_cliente`),
  CONSTRAINT `dm_fatovendas_ibfk_1` FOREIGN KEY (`id_tempo`) REFERENCES `dm_dimtempo` (`id_tempo`),
  CONSTRAINT `dm_fatovendas_ibfk_2` FOREIGN KEY (`id_prato`) REFERENCES `dm_dimprato` (`id_prato`),
  CONSTRAINT `dm_fatovendas_ibfk_3` FOREIGN KEY (`id_cliente`) REFERENCES `dm_dimcliente` (`id_cliente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dm_fatovendas`
--

LOCK TABLES `dm_fatovendas` WRITE;
/*!40000 ALTER TABLE `dm_fatovendas` DISABLE KEYS */;
/*!40000 ALTER TABLE `dm_fatovendas` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-19 11:59:11
