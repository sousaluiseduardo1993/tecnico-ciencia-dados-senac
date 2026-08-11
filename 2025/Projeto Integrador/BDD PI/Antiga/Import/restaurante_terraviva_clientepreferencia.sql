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
-- Table structure for table `clientepreferencia`
--

DROP TABLE IF EXISTS `clientepreferencia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientepreferencia` (
  `id_cliente` int NOT NULL,
  `id_preferencia` int NOT NULL,
  PRIMARY KEY (`id_cliente`,`id_preferencia`),
  KEY `id_preferencia` (`id_preferencia`),
  CONSTRAINT `clientepreferencia_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `clientepreferencia_ibfk_2` FOREIGN KEY (`id_preferencia`) REFERENCES `preferenciasalimentares` (`id_preferencia`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientepreferencia`
--

LOCK TABLES `clientepreferencia` WRITE;
/*!40000 ALTER TABLE `clientepreferencia` DISABLE KEYS */;
INSERT INTO `clientepreferencia` VALUES (2,1),(3,1),(4,1),(6,1),(9,1),(11,1),(14,1),(18,1),(19,1),(21,1),(23,1),(24,1),(26,1),(37,1),(38,1),(39,1),(40,1),(45,1),(51,1),(52,1),(54,1),(55,1),(58,1),(59,1),(60,1),(61,1),(67,1),(74,1),(83,1),(84,1),(86,1),(87,1),(88,1),(91,1),(92,1),(97,1),(101,1),(103,1),(104,1),(106,1),(112,1),(117,1),(5,2),(16,2),(17,2),(20,2),(24,2),(25,2),(26,2),(32,2),(36,2),(42,2),(43,2),(48,2),(49,2),(62,2),(66,2),(68,2),(71,2),(76,2),(81,2),(83,2),(96,2),(100,2),(103,2),(6,3),(9,3),(10,3),(16,3),(22,3),(27,3),(28,3),(35,3),(39,3),(41,3),(44,3),(45,3),(64,3),(65,3),(75,3),(82,3),(89,3),(90,3),(102,3),(104,3),(107,3),(110,3),(116,3),(118,3),(119,3),(120,3),(5,4),(8,4),(12,4),(13,4),(28,4),(29,4),(34,4),(35,4),(37,4),(38,4),(49,4),(53,4),(55,4),(63,4),(64,4),(71,4),(72,4),(73,4),(76,4),(78,4),(79,4),(84,4),(86,4),(88,4),(96,4),(105,4),(106,4),(108,4),(113,4),(114,4),(116,4),(3,5),(7,5),(15,5),(17,5),(27,5),(30,5),(33,5),(68,5),(69,5),(77,5),(79,5),(80,5),(85,5),(87,5),(94,5),(95,5),(97,5),(100,5),(102,5),(107,5),(111,5),(117,5),(118,5),(1,6),(7,6),(12,6),(30,6),(31,6),(36,6),(42,6),(46,6),(47,6),(50,6),(52,6),(53,6),(56,6),(57,6),(61,6),(67,6),(69,6),(70,6),(73,6),(77,6),(89,6),(93,6),(94,6),(95,6),(98,6),(99,6),(109,6),(111,6),(113,6),(115,6);
/*!40000 ALTER TABLE `clientepreferencia` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-19 11:59:16
