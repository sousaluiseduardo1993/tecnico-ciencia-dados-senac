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
-- Table structure for table `repassesplataforma`
--

DROP TABLE IF EXISTS `repassesplataforma`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `repassesplataforma` (
  `id_repasse` int NOT NULL AUTO_INCREMENT,
  `id_plataforma` int NOT NULL,
  `data_inicio` date NOT NULL,
  `data_fim` date NOT NULL,
  `valor_total` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id_repasse`),
  KEY `idx_repasses_plataforma` (`id_plataforma`),
  CONSTRAINT `repassesplataforma_ibfk_1` FOREIGN KEY (`id_plataforma`) REFERENCES `plataformas` (`id_plataforma`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `repassesplataforma`
--

LOCK TABLES `repassesplataforma` WRITE;
/*!40000 ALTER TABLE `repassesplataforma` DISABLE KEYS */;
INSERT INTO `repassesplataforma` VALUES (1,4,'2025-09-18','2025-11-23',4456.28),(2,4,'2025-06-24','2025-11-21',1359.15),(3,4,'2025-10-29','2025-12-07',4130.37),(4,1,'2025-09-14','2025-11-25',524.53),(5,4,'2025-07-20','2025-12-10',4255.43),(6,4,'2025-09-21','2025-12-07',1026.17),(7,1,'2025-06-05','2025-12-17',1187.19),(8,2,'2025-07-21','2025-11-27',2986.54),(9,1,'2025-08-10','2025-11-30',2120.27),(10,4,'2025-10-25','2025-11-20',4241.47),(11,1,'2025-07-28','2025-12-13',1983.74),(12,2,'2025-11-14','2025-12-14',763.08);
/*!40000 ALTER TABLE `repassesplataforma` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-19 11:59:13
