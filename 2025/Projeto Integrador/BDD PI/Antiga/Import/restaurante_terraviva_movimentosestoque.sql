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
-- Table structure for table `movimentosestoque`
--

DROP TABLE IF EXISTS `movimentosestoque`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `movimentosestoque` (
  `id_movimento` int NOT NULL AUTO_INCREMENT,
  `id_ingrediente` int NOT NULL,
  `tipo` enum('entrada','saida','ajuste') NOT NULL,
  `quantidade` decimal(10,3) NOT NULL,
  `data_hora` datetime NOT NULL DEFAULT (now()),
  `id_fornecedor` int DEFAULT NULL,
  `id_funcionario_responsavel` int DEFAULT NULL,
  `observacao` text,
  PRIMARY KEY (`id_movimento`),
  KEY `id_fornecedor` (`id_fornecedor`),
  KEY `id_funcionario_responsavel` (`id_funcionario_responsavel`),
  KEY `idx_mov_ingrediente` (`id_ingrediente`),
  KEY `idx_mov_data` (`data_hora`),
  CONSTRAINT `movimentosestoque_ibfk_1` FOREIGN KEY (`id_ingrediente`) REFERENCES `ingredientes` (`id_ingrediente`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `movimentosestoque_ibfk_2` FOREIGN KEY (`id_fornecedor`) REFERENCES `fornecedores` (`id_fornecedor`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `movimentosestoque_ibfk_3` FOREIGN KEY (`id_funcionario_responsavel`) REFERENCES `funcionarios` (`id_funcionario`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=161 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimentosestoque`
--

LOCK TABLES `movimentosestoque` WRITE;
/*!40000 ALTER TABLE `movimentosestoque` DISABLE KEYS */;
INSERT INTO `movimentosestoque` VALUES (1,50,'ajuste',14.291,'2025-11-12 19:32:06',14,8,'Movimento automático #1'),(2,28,'entrada',12.437,'2025-11-07 22:32:06',10,1,'Movimento automático #2'),(3,21,'entrada',5.163,'2025-11-08 14:32:06',8,25,'Movimento automático #3'),(4,41,'ajuste',19.245,'2025-11-07 18:32:06',10,5,'Movimento automático #4'),(5,51,'ajuste',3.813,'2025-11-11 11:32:06',13,33,'Movimento automático #5'),(6,38,'ajuste',5.833,'2025-11-09 05:32:06',4,10,'Movimento automático #6'),(7,41,'ajuste',14.127,'2025-11-03 06:32:06',12,36,'Movimento automático #7'),(8,12,'entrada',15.523,'2025-11-07 01:32:06',7,34,'Movimento automático #8'),(9,73,'entrada',7.932,'2025-11-04 11:32:06',6,40,'Movimento automático #9'),(10,72,'saida',16.694,'2025-11-08 14:32:06',12,37,'Movimento automático #10'),(11,20,'saida',13.457,'2025-11-04 12:32:06',8,31,'Movimento automático #11'),(12,28,'saida',4.369,'2025-11-07 16:32:06',14,17,'Movimento automático #12'),(13,25,'entrada',12.099,'2025-11-17 22:32:06',11,3,'Movimento automático #13'),(14,28,'saida',11.750,'2025-11-13 21:32:06',14,26,'Movimento automático #14'),(15,37,'entrada',4.850,'2025-11-15 16:32:06',7,19,'Movimento automático #15'),(16,2,'ajuste',9.889,'2025-11-14 03:32:06',2,29,'Movimento automático #16'),(17,9,'saida',18.688,'2025-11-14 16:32:06',10,17,'Movimento automático #17'),(18,5,'entrada',3.788,'2025-11-07 15:32:06',15,35,'Movimento automático #18'),(19,25,'ajuste',16.122,'2025-11-16 13:32:06',8,35,'Movimento automático #19'),(20,75,'entrada',5.121,'2025-11-15 12:32:06',7,20,'Movimento automático #20'),(21,13,'entrada',0.805,'2025-11-15 00:32:06',4,16,'Movimento automático #21'),(22,16,'ajuste',12.516,'2025-11-09 21:32:06',1,14,'Movimento automático #22'),(23,55,'saida',15.693,'2025-11-06 00:32:06',11,4,'Movimento automático #23'),(24,23,'entrada',2.093,'2025-11-04 01:32:06',6,36,'Movimento automático #24'),(25,39,'ajuste',2.178,'2025-11-12 22:32:06',10,4,'Movimento automático #25'),(26,36,'ajuste',13.147,'2025-11-15 02:32:06',6,1,'Movimento automático #26'),(27,78,'ajuste',1.358,'2025-11-03 18:32:06',8,33,'Movimento automático #27'),(28,35,'ajuste',9.054,'2025-11-02 22:32:06',10,7,'Movimento automático #28'),(29,76,'entrada',7.005,'2025-11-19 07:32:06',1,4,'Movimento automático #29'),(30,29,'saida',10.861,'2025-11-17 09:32:06',1,30,'Movimento automático #30'),(31,47,'ajuste',15.237,'2025-11-07 23:32:06',3,36,'Movimento automático #31'),(32,66,'saida',16.938,'2025-11-05 15:32:06',10,26,'Movimento automático #32'),(33,24,'saida',17.182,'2025-11-08 20:32:06',10,11,'Movimento automático #33'),(34,31,'entrada',8.461,'2025-11-06 18:32:06',9,22,'Movimento automático #34'),(35,78,'entrada',4.852,'2025-11-11 00:32:06',13,27,'Movimento automático #35'),(36,62,'ajuste',1.335,'2025-11-08 00:32:06',4,10,'Movimento automático #36'),(37,30,'entrada',15.846,'2025-11-13 00:32:06',9,31,'Movimento automático #37'),(38,2,'ajuste',1.006,'2025-11-06 15:32:06',11,11,'Movimento automático #38'),(39,18,'entrada',12.670,'2025-11-13 04:32:06',1,37,'Movimento automático #39'),(40,40,'ajuste',6.299,'2025-11-14 21:32:06',7,17,'Movimento automático #40'),(41,55,'entrada',17.687,'2025-11-05 08:32:06',10,19,'Movimento automático #41'),(42,42,'entrada',7.908,'2025-11-13 00:32:06',12,28,'Movimento automático #42'),(43,15,'ajuste',8.478,'2025-11-07 10:32:06',6,26,'Movimento automático #43'),(44,5,'saida',14.508,'2025-11-11 12:32:06',4,30,'Movimento automático #44'),(45,2,'ajuste',5.987,'2025-11-05 06:32:06',6,16,'Movimento automático #45'),(46,60,'saida',14.313,'2025-11-06 11:32:06',12,21,'Movimento automático #46'),(47,18,'saida',3.543,'2025-11-16 16:32:06',5,7,'Movimento automático #47'),(48,61,'saida',10.014,'2025-11-12 16:32:06',9,23,'Movimento automático #48'),(49,10,'ajuste',4.519,'2025-11-13 11:32:06',3,25,'Movimento automático #49'),(50,55,'saida',12.975,'2025-11-09 08:32:06',2,31,'Movimento automático #50'),(51,35,'ajuste',1.580,'2025-11-06 21:32:06',9,21,'Movimento automático #51'),(52,73,'ajuste',4.216,'2025-11-18 06:32:06',12,23,'Movimento automático #52'),(53,42,'ajuste',2.908,'2025-11-04 21:32:06',15,6,'Movimento automático #53'),(54,70,'ajuste',18.921,'2025-11-03 06:32:06',1,14,'Movimento automático #54'),(55,39,'saida',13.870,'2025-11-16 18:32:06',12,11,'Movimento automático #55'),(56,9,'ajuste',4.873,'2025-11-18 12:32:06',9,29,'Movimento automático #56'),(57,71,'entrada',10.799,'2025-11-03 09:32:06',4,10,'Movimento automático #57'),(58,38,'saida',16.854,'2025-11-15 09:32:06',11,34,'Movimento automático #58'),(59,6,'ajuste',18.787,'2025-11-16 11:32:06',2,38,'Movimento automático #59'),(60,37,'saida',14.993,'2025-11-11 20:32:06',1,38,'Movimento automático #60'),(61,38,'saida',8.723,'2025-11-12 01:32:06',15,14,'Movimento automático #61'),(62,70,'saida',4.244,'2025-11-03 21:32:06',1,21,'Movimento automático #62'),(63,30,'entrada',9.913,'2025-11-11 08:32:06',15,16,'Movimento automático #63'),(64,2,'ajuste',10.848,'2025-11-03 20:32:06',2,25,'Movimento automático #64'),(65,61,'ajuste',12.451,'2025-11-16 21:32:06',14,7,'Movimento automático #65'),(66,3,'saida',4.677,'2025-11-16 22:32:06',2,39,'Movimento automático #66'),(67,42,'ajuste',0.733,'2025-11-19 06:32:06',15,33,'Movimento automático #67'),(68,12,'entrada',1.144,'2025-11-13 09:32:06',11,11,'Movimento automático #68'),(69,27,'ajuste',6.588,'2025-11-19 03:32:06',3,25,'Movimento automático #69'),(70,54,'saida',10.436,'2025-11-18 09:32:06',12,29,'Movimento automático #70'),(71,18,'ajuste',0.750,'2025-11-13 13:32:06',11,15,'Movimento automático #71'),(72,62,'ajuste',7.258,'2025-11-09 13:32:06',14,31,'Movimento automático #72'),(73,8,'entrada',11.069,'2025-11-15 08:32:06',9,9,'Movimento automático #73'),(74,26,'ajuste',13.991,'2025-11-08 01:32:06',6,27,'Movimento automático #74'),(75,21,'entrada',17.389,'2025-11-13 22:32:06',2,16,'Movimento automático #75'),(76,60,'saida',6.694,'2025-11-17 12:32:06',10,28,'Movimento automático #76'),(77,49,'ajuste',2.305,'2025-11-09 17:32:06',10,11,'Movimento automático #77'),(78,37,'saida',5.678,'2025-11-06 02:32:06',3,20,'Movimento automático #78'),(79,68,'ajuste',9.573,'2025-11-03 11:32:06',6,3,'Movimento automático #79'),(80,13,'saida',9.891,'2025-11-08 08:32:06',14,16,'Movimento automático #80'),(81,23,'entrada',7.444,'2025-11-17 13:32:06',8,3,'Movimento automático #81'),(82,66,'ajuste',4.994,'2025-11-12 19:32:06',5,7,'Movimento automático #82'),(83,3,'ajuste',4.672,'2025-11-17 04:32:06',1,25,'Movimento automático #83'),(84,6,'saida',6.635,'2025-11-17 17:32:06',9,18,'Movimento automático #84'),(85,43,'entrada',1.001,'2025-11-15 07:32:06',2,34,'Movimento automático #85'),(86,67,'saida',15.566,'2025-11-04 11:32:06',3,11,'Movimento automático #86'),(87,56,'ajuste',10.513,'2025-11-12 05:32:06',10,31,'Movimento automático #87'),(88,80,'ajuste',7.365,'2025-11-06 00:32:06',15,14,'Movimento automático #88'),(89,64,'entrada',12.301,'2025-11-18 17:32:06',7,36,'Movimento automático #89'),(90,19,'saida',13.504,'2025-11-03 20:32:06',11,25,'Movimento automático #90'),(91,79,'entrada',8.189,'2025-11-05 19:32:06',14,40,'Movimento automático #91'),(92,22,'saida',3.274,'2025-11-09 08:32:06',9,1,'Movimento automático #92'),(93,27,'saida',5.389,'2025-11-13 11:32:06',1,39,'Movimento automático #93'),(94,67,'entrada',12.289,'2025-11-12 22:32:06',3,21,'Movimento automático #94'),(95,13,'entrada',15.170,'2025-11-18 23:32:06',14,15,'Movimento automático #95'),(96,15,'ajuste',10.194,'2025-11-18 01:32:06',14,13,'Movimento automático #96'),(97,63,'ajuste',12.917,'2025-11-15 22:32:06',3,4,'Movimento automático #97'),(98,77,'saida',18.627,'2025-11-03 15:32:06',15,1,'Movimento automático #98'),(99,10,'saida',10.100,'2025-11-06 08:32:06',7,34,'Movimento automático #99'),(100,66,'saida',13.069,'2025-11-13 05:32:06',15,23,'Movimento automático #100'),(101,76,'entrada',12.423,'2025-11-06 03:32:06',3,17,'Movimento automático #101'),(102,42,'saida',10.509,'2025-11-13 18:32:06',3,32,'Movimento automático #102'),(103,34,'ajuste',11.455,'2025-11-10 13:32:06',15,12,'Movimento automático #103'),(104,40,'saida',11.753,'2025-11-18 06:32:06',10,36,'Movimento automático #104'),(105,43,'entrada',11.816,'2025-11-05 22:32:06',5,6,'Movimento automático #105'),(106,58,'entrada',17.586,'2025-11-07 00:32:06',2,14,'Movimento automático #106'),(107,27,'saida',5.739,'2025-11-12 03:32:06',6,20,'Movimento automático #107'),(108,26,'entrada',15.842,'2025-11-11 07:32:06',2,1,'Movimento automático #108'),(109,60,'ajuste',6.329,'2025-11-12 09:32:06',4,29,'Movimento automático #109'),(110,2,'ajuste',10.951,'2025-11-03 14:32:06',3,34,'Movimento automático #110'),(111,64,'saida',17.248,'2025-11-03 20:32:06',2,33,'Movimento automático #111'),(112,54,'ajuste',10.574,'2025-11-04 09:32:06',15,3,'Movimento automático #112'),(113,38,'entrada',6.982,'2025-11-15 01:32:06',5,28,'Movimento automático #113'),(114,40,'saida',16.044,'2025-11-09 06:32:06',11,21,'Movimento automático #114'),(115,48,'saida',3.205,'2025-11-09 03:32:06',10,15,'Movimento automático #115'),(116,68,'entrada',2.467,'2025-11-15 22:32:06',11,37,'Movimento automático #116'),(117,35,'saida',16.154,'2025-11-06 21:32:06',6,24,'Movimento automático #117'),(118,64,'entrada',13.504,'2025-11-07 08:32:06',10,39,'Movimento automático #118'),(119,79,'ajuste',16.863,'2025-11-13 22:32:06',3,31,'Movimento automático #119'),(120,25,'entrada',8.342,'2025-11-15 01:32:06',2,29,'Movimento automático #120'),(121,17,'ajuste',1.457,'2025-11-10 19:32:06',7,19,'Movimento automático #121'),(122,8,'entrada',4.831,'2025-11-05 03:32:06',9,17,'Movimento automático #122'),(123,21,'entrada',10.469,'2025-11-12 13:32:06',8,15,'Movimento automático #123'),(124,23,'entrada',13.606,'2025-11-11 19:32:06',5,1,'Movimento automático #124'),(125,17,'entrada',8.767,'2025-11-17 06:32:06',6,18,'Movimento automático #125'),(126,10,'entrada',16.873,'2025-11-11 09:32:06',14,4,'Movimento automático #126'),(127,61,'saida',5.327,'2025-11-06 12:32:06',2,10,'Movimento automático #127'),(128,68,'saida',1.545,'2025-11-06 07:32:06',12,13,'Movimento automático #128'),(129,33,'entrada',20.078,'2025-11-05 00:32:06',6,7,'Movimento automático #129'),(130,57,'entrada',5.084,'2025-11-19 01:32:06',6,33,'Movimento automático #130'),(131,75,'entrada',7.615,'2025-11-16 16:32:06',11,4,'Movimento automático #131'),(132,23,'entrada',17.595,'2025-11-03 19:32:06',2,25,'Movimento automático #132'),(133,64,'entrada',5.289,'2025-11-04 05:32:06',13,11,'Movimento automático #133'),(134,72,'ajuste',17.244,'2025-11-16 22:32:06',3,22,'Movimento automático #134'),(135,7,'ajuste',14.548,'2025-11-15 14:32:06',1,13,'Movimento automático #135'),(136,48,'entrada',6.026,'2025-11-12 08:32:06',4,40,'Movimento automático #136'),(137,18,'entrada',15.458,'2025-11-09 15:32:06',10,21,'Movimento automático #137'),(138,46,'saida',19.757,'2025-11-04 15:32:06',8,36,'Movimento automático #138'),(139,73,'ajuste',10.414,'2025-11-18 17:32:06',11,11,'Movimento automático #139'),(140,26,'ajuste',0.326,'2025-11-08 09:32:06',5,21,'Movimento automático #140'),(141,49,'saida',17.853,'2025-11-06 01:32:06',6,18,'Movimento automático #141'),(142,10,'entrada',16.820,'2025-11-11 16:32:06',13,32,'Movimento automático #142'),(143,37,'ajuste',1.209,'2025-11-09 01:32:06',15,39,'Movimento automático #143'),(144,73,'saida',8.567,'2025-11-15 12:32:06',14,37,'Movimento automático #144'),(145,62,'entrada',5.197,'2025-11-03 20:32:06',15,35,'Movimento automático #145'),(146,38,'ajuste',10.718,'2025-11-14 16:32:06',13,16,'Movimento automático #146'),(147,30,'ajuste',9.184,'2025-11-17 09:32:06',4,38,'Movimento automático #147'),(148,75,'ajuste',7.551,'2025-11-13 12:32:06',11,12,'Movimento automático #148'),(149,31,'entrada',3.994,'2025-11-06 15:32:06',5,3,'Movimento automático #149'),(150,40,'entrada',18.077,'2025-11-08 09:32:06',10,7,'Movimento automático #150'),(151,75,'entrada',2.037,'2025-11-03 19:32:06',7,10,'Movimento automático #151'),(152,76,'entrada',6.136,'2025-11-12 11:32:06',4,31,'Movimento automático #152'),(153,15,'saida',12.247,'2025-11-17 01:32:06',14,4,'Movimento automático #153'),(154,57,'entrada',3.989,'2025-11-16 06:32:06',6,14,'Movimento automático #154'),(155,41,'saida',4.167,'2025-11-13 03:32:06',5,14,'Movimento automático #155'),(156,65,'ajuste',11.312,'2025-11-05 18:32:06',7,29,'Movimento automático #156'),(157,23,'entrada',9.542,'2025-11-10 02:32:06',7,14,'Movimento automático #157'),(158,34,'entrada',6.474,'2025-11-15 08:32:06',5,28,'Movimento automático #158'),(159,51,'entrada',6.624,'2025-11-11 01:32:06',9,9,'Movimento automático #159'),(160,37,'saida',14.386,'2025-11-07 10:32:06',8,10,'Movimento automático #160');
/*!40000 ALTER TABLE `movimentosestoque` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_evitar_estoque_negativo` BEFORE INSERT ON `movimentosestoque` FOR EACH ROW BEGIN
    IF NEW.tipo = 'saida' THEN
        IF (
            SELECT COALESCE(SUM(
                CASE tipo WHEN 'entrada' THEN quantidade
                WHEN 'saida' THEN -quantidade ELSE 0 END
            ),0)
            FROM MovimentosEstoque
            WHERE id_ingrediente = NEW.id_ingrediente
        ) - NEW.quantidade < 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Saída maior que saldo disponível no estoque!';
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

-- Dump completed on 2025-11-19 11:59:12
