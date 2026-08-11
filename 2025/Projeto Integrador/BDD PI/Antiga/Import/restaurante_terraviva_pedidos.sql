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
-- Table structure for table `pedidos`
--

DROP TABLE IF EXISTS `pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedidos` (
  `id_pedido` int NOT NULL AUTO_INCREMENT,
  `id_cliente` int DEFAULT NULL,
  `id_plataforma` int DEFAULT NULL,
  `tipo` enum('mesa','balcao','delivery') NOT NULL,
  `status` enum('aberto','preparo','entregue','finalizado','cancelado') NOT NULL DEFAULT 'aberto',
  `data_hora` datetime NOT NULL DEFAULT (now()),
  `id_mesa` int DEFAULT NULL,
  `id_funcionario_atendente` int DEFAULT NULL,
  PRIMARY KEY (`id_pedido`),
  KEY `id_funcionario_atendente` (`id_funcionario_atendente`),
  KEY `idx_pedido_cliente` (`id_cliente`),
  KEY `idx_pedido_data` (`data_hora`),
  KEY `idx_pedido_plat` (`id_plataforma`),
  KEY `idx_pedido_mesa` (`id_mesa`),
  CONSTRAINT `pedidos_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `pedidos_ibfk_2` FOREIGN KEY (`id_plataforma`) REFERENCES `plataformas` (`id_plataforma`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `pedidos_ibfk_3` FOREIGN KEY (`id_mesa`) REFERENCES `mesas` (`id_mesa`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `pedidos_ibfk_4` FOREIGN KEY (`id_funcionario_atendente`) REFERENCES `funcionarios` (`id_funcionario`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=151 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedidos`
--

LOCK TABLES `pedidos` WRITE;
/*!40000 ALTER TABLE `pedidos` DISABLE KEYS */;
INSERT INTO `pedidos` VALUES (1,68,2,'delivery','preparo','2025-10-22 17:32:06',4,5),(2,8,NULL,'balcao','finalizado','2025-11-11 07:32:06',11,18),(3,73,NULL,'delivery','finalizado','2025-11-10 22:32:06',9,18),(4,99,NULL,'balcao','finalizado','2025-11-11 02:32:06',16,14),(5,40,NULL,'mesa','preparo','2025-11-03 05:32:06',NULL,7),(6,116,3,'balcao','finalizado','2025-10-21 22:32:06',20,5),(7,77,NULL,'balcao','entregue','2025-11-10 09:32:06',NULL,39),(8,111,NULL,'balcao','preparo','2025-11-16 19:32:06',NULL,35),(9,99,1,'mesa','cancelado','2025-11-07 08:32:06',6,32),(10,25,NULL,'balcao','cancelado','2025-10-27 08:32:06',13,26),(11,29,3,'balcao','finalizado','2025-11-15 03:32:06',15,11),(12,29,1,'mesa','aberto','2025-10-27 09:32:06',6,33),(13,29,NULL,'mesa','aberto','2025-10-30 17:32:06',NULL,27),(14,22,NULL,'delivery','finalizado','2025-11-16 06:32:06',3,29),(15,31,4,'balcao','finalizado','2025-11-11 14:32:06',14,34),(16,23,3,'delivery','finalizado','2025-11-18 19:32:06',NULL,36),(17,11,NULL,'balcao','preparo','2025-10-27 12:32:06',1,39),(18,91,NULL,'delivery','preparo','2025-10-30 18:32:06',16,34),(19,99,NULL,'delivery','entregue','2025-11-05 10:32:06',NULL,32),(20,56,NULL,'mesa','preparo','2025-11-18 23:32:06',7,20),(21,47,1,'balcao','preparo','2025-10-23 04:32:06',1,18),(22,19,4,'balcao','finalizado','2025-11-17 18:32:06',NULL,14),(23,120,NULL,'delivery','preparo','2025-11-08 08:32:06',NULL,12),(24,52,1,'balcao','entregue','2025-10-21 13:32:06',8,9),(25,107,NULL,'mesa','aberto','2025-10-22 22:32:06',14,3),(26,34,2,'delivery','preparo','2025-11-12 03:32:06',19,12),(27,72,4,'mesa','entregue','2025-11-14 20:32:06',16,21),(28,36,NULL,'delivery','cancelado','2025-11-13 22:32:06',20,36),(29,68,1,'delivery','cancelado','2025-10-30 15:32:06',NULL,20),(30,89,4,'mesa','finalizado','2025-11-06 07:32:06',NULL,6),(31,6,NULL,'delivery','entregue','2025-11-05 10:32:06',NULL,35),(32,48,3,'mesa','cancelado','2025-10-28 19:32:06',6,8),(33,5,NULL,'mesa','entregue','2025-11-08 01:32:06',9,10),(34,112,NULL,'delivery','finalizado','2025-11-06 12:32:06',4,21),(35,5,NULL,'balcao','cancelado','2025-11-16 07:32:06',NULL,19),(36,58,NULL,'balcao','preparo','2025-11-13 17:32:06',13,2),(37,35,4,'mesa','entregue','2025-11-04 18:32:06',13,20),(38,60,4,'delivery','preparo','2025-11-14 17:32:06',12,31),(39,20,1,'balcao','aberto','2025-10-28 12:32:06',3,30),(40,52,NULL,'mesa','aberto','2025-11-16 06:32:06',13,26),(41,33,2,'mesa','aberto','2025-10-21 23:32:06',7,10),(42,36,NULL,'delivery','cancelado','2025-11-06 18:32:06',9,33),(43,84,1,'balcao','cancelado','2025-11-18 08:32:06',16,3),(44,4,NULL,'delivery','cancelado','2025-10-31 15:32:06',18,39),(45,20,NULL,'mesa','aberto','2025-10-22 15:32:06',1,2),(46,16,1,'balcao','entregue','2025-11-01 07:32:06',13,7),(47,120,3,'mesa','finalizado','2025-11-05 15:32:06',7,7),(48,109,2,'balcao','cancelado','2025-10-23 06:32:06',NULL,3),(49,3,NULL,'balcao','preparo','2025-11-07 07:32:06',5,12),(50,86,NULL,'balcao','preparo','2025-11-18 22:32:06',18,35),(51,84,NULL,'mesa','cancelado','2025-11-13 16:32:06',2,34),(52,107,NULL,'mesa','entregue','2025-11-05 17:32:06',NULL,2),(53,16,2,'mesa','aberto','2025-10-28 03:32:06',19,11),(54,76,3,'balcao','preparo','2025-10-23 05:32:06',NULL,7),(55,55,NULL,'delivery','aberto','2025-11-13 12:32:06',NULL,20),(56,114,3,'mesa','entregue','2025-11-02 12:32:06',6,8),(57,16,4,'balcao','preparo','2025-11-09 19:32:06',NULL,19),(58,81,NULL,'delivery','finalizado','2025-11-04 09:32:06',4,35),(59,91,4,'balcao','aberto','2025-11-03 05:32:06',NULL,32),(60,106,3,'delivery','finalizado','2025-10-24 07:32:06',NULL,13),(61,77,1,'mesa','finalizado','2025-10-31 01:32:06',3,40),(62,74,2,'delivery','entregue','2025-10-22 20:32:06',NULL,33),(63,41,1,'delivery','entregue','2025-10-27 12:32:06',13,25),(64,25,1,'balcao','entregue','2025-11-13 09:32:06',6,24),(65,13,NULL,'delivery','aberto','2025-11-11 11:32:06',17,27),(66,111,1,'mesa','finalizado','2025-11-15 13:32:06',19,30),(67,3,NULL,'mesa','preparo','2025-11-14 18:32:06',NULL,17),(68,90,1,'balcao','preparo','2025-11-06 17:32:06',20,19),(69,51,NULL,'balcao','finalizado','2025-11-13 08:32:06',12,29),(70,105,3,'delivery','preparo','2025-10-28 04:32:06',NULL,9),(71,119,2,'balcao','finalizado','2025-11-11 16:32:06',7,15),(72,101,4,'balcao','cancelado','2025-10-22 17:32:06',NULL,17),(73,19,1,'mesa','aberto','2025-11-15 05:32:06',NULL,37),(74,67,3,'delivery','finalizado','2025-11-05 22:32:06',10,37),(75,11,NULL,'balcao','entregue','2025-10-28 23:32:06',NULL,23),(76,116,4,'balcao','finalizado','2025-11-02 15:32:06',1,20),(77,45,4,'balcao','cancelado','2025-10-22 01:32:06',NULL,35),(78,15,NULL,'balcao','cancelado','2025-10-25 21:32:06',9,39),(79,65,NULL,'balcao','finalizado','2025-11-12 22:32:06',NULL,14),(80,83,1,'balcao','finalizado','2025-11-12 19:32:06',7,27),(81,45,NULL,'delivery','preparo','2025-10-27 01:32:06',NULL,12),(82,76,3,'balcao','preparo','2025-10-21 15:32:06',NULL,5),(83,63,4,'delivery','preparo','2025-11-10 02:32:06',8,17),(84,4,NULL,'balcao','aberto','2025-11-04 06:32:06',9,22),(85,54,3,'balcao','preparo','2025-11-18 03:32:06',18,8),(86,40,2,'balcao','aberto','2025-10-26 20:32:06',2,38),(87,59,2,'balcao','preparo','2025-10-29 22:32:06',NULL,14),(88,75,3,'mesa','entregue','2025-11-19 07:32:06',NULL,7),(89,110,3,'delivery','finalizado','2025-10-29 10:32:06',3,12),(90,9,1,'balcao','finalizado','2025-11-14 18:32:06',NULL,2),(91,62,3,'mesa','aberto','2025-11-01 15:32:06',1,17),(92,117,NULL,'mesa','entregue','2025-11-09 01:32:06',5,29),(93,108,1,'mesa','preparo','2025-11-02 21:32:06',NULL,33),(94,51,NULL,'delivery','cancelado','2025-11-06 12:32:06',12,7),(95,15,1,'mesa','cancelado','2025-11-08 04:32:06',4,20),(96,112,1,'mesa','preparo','2025-10-29 14:32:06',NULL,5),(97,2,NULL,'balcao','aberto','2025-11-11 09:32:06',6,30),(98,99,NULL,'mesa','aberto','2025-11-17 11:32:06',NULL,26),(99,34,3,'mesa','finalizado','2025-10-30 15:32:06',5,18),(100,58,4,'balcao','preparo','2025-11-02 17:32:06',NULL,33),(101,41,2,'balcao','entregue','2025-11-10 20:32:06',10,11),(102,102,3,'mesa','aberto','2025-10-24 20:32:06',NULL,34),(103,22,2,'balcao','entregue','2025-10-24 00:32:06',8,36),(104,35,NULL,'delivery','finalizado','2025-11-15 16:32:06',NULL,23),(105,58,NULL,'mesa','preparo','2025-10-24 04:32:06',NULL,4),(106,25,NULL,'mesa','cancelado','2025-10-22 19:32:06',NULL,11),(107,113,NULL,'balcao','aberto','2025-10-24 18:32:06',9,6),(108,48,3,'delivery','cancelado','2025-11-04 19:32:06',18,37),(109,116,3,'balcao','entregue','2025-11-14 17:32:06',6,15),(110,112,1,'mesa','finalizado','2025-11-01 19:32:06',NULL,32),(111,92,1,'mesa','aberto','2025-11-02 18:32:06',16,14),(112,51,1,'balcao','finalizado','2025-11-04 12:32:06',13,38),(113,97,2,'balcao','entregue','2025-10-24 03:32:06',NULL,32),(114,32,NULL,'mesa','entregue','2025-11-06 22:32:06',3,4),(115,16,3,'delivery','aberto','2025-11-08 19:32:06',14,17),(116,118,NULL,'balcao','finalizado','2025-10-29 13:32:06',4,5),(117,1,NULL,'balcao','preparo','2025-10-23 13:32:06',NULL,34),(118,5,NULL,'balcao','cancelado','2025-11-11 22:32:06',4,6),(119,19,2,'delivery','finalizado','2025-11-10 07:32:06',18,13),(120,118,NULL,'balcao','entregue','2025-10-24 19:32:06',6,26),(121,43,NULL,'balcao','preparo','2025-11-08 14:32:06',NULL,13),(122,109,NULL,'mesa','finalizado','2025-10-22 09:32:06',19,22),(123,115,4,'delivery','cancelado','2025-10-29 08:32:06',NULL,12),(124,46,1,'mesa','finalizado','2025-10-23 09:32:06',13,29),(125,80,4,'mesa','preparo','2025-11-16 12:32:06',13,39),(126,118,NULL,'mesa','preparo','2025-10-23 20:32:06',NULL,22),(127,22,4,'balcao','preparo','2025-11-17 21:32:06',11,5),(128,13,2,'mesa','entregue','2025-11-01 01:32:06',13,26),(129,35,4,'balcao','aberto','2025-10-21 14:32:06',14,32),(130,111,3,'delivery','aberto','2025-10-22 00:32:06',8,4),(131,48,NULL,'mesa','cancelado','2025-11-09 19:32:06',NULL,13),(132,69,NULL,'delivery','finalizado','2025-10-27 07:32:06',NULL,28),(133,10,1,'mesa','entregue','2025-10-31 03:32:06',NULL,10),(134,86,NULL,'mesa','finalizado','2025-10-27 07:32:06',3,6),(135,41,2,'mesa','preparo','2025-11-07 15:32:06',NULL,24),(136,14,NULL,'balcao','entregue','2025-10-23 20:32:06',NULL,29),(137,113,4,'mesa','cancelado','2025-10-26 13:32:06',17,34),(138,77,NULL,'balcao','aberto','2025-11-05 06:32:06',5,28),(139,90,NULL,'mesa','entregue','2025-11-02 17:32:06',13,16),(140,120,NULL,'mesa','finalizado','2025-11-16 03:32:06',15,38),(141,64,NULL,'balcao','entregue','2025-10-28 01:32:06',16,10),(142,102,1,'balcao','aberto','2025-10-26 16:32:06',18,4),(143,92,2,'balcao','aberto','2025-11-18 02:32:06',NULL,27),(144,50,1,'delivery','finalizado','2025-11-18 09:32:06',NULL,28),(145,68,NULL,'mesa','preparo','2025-11-16 14:32:06',NULL,32),(146,15,3,'delivery','aberto','2025-10-31 12:32:06',14,4),(147,41,1,'delivery','cancelado','2025-11-06 04:32:06',2,38),(148,51,2,'balcao','aberto','2025-11-18 15:32:06',NULL,38),(149,103,4,'balcao','finalizado','2025-11-09 00:32:06',NULL,5),(150,14,3,'balcao','preparo','2025-11-02 05:32:06',NULL,4);
/*!40000 ALTER TABLE `pedidos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_validacao_pedido` BEFORE INSERT ON `pedidos` FOR EACH ROW BEGIN
    IF NEW.tipo = 'delivery' THEN
        IF NEW.id_plataforma IS NULL OR NEW.id_mesa IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Pedido delivery exige plataforma e não permite mesa.';
        END IF;
    END IF;

    IF NEW.tipo = 'mesa' THEN
        IF NEW.id_mesa IS NULL OR NEW.id_plataforma IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Pedido de mesa exige id_mesa e não permite plataforma.';
        END IF;
    END IF;

    IF NEW.tipo = 'balcao' THEN
        IF NEW.id_mesa IS NOT NULL OR NEW.id_plataforma IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Pedido de balcão não permite mesa nem plataforma.';
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-19 11:59:14
