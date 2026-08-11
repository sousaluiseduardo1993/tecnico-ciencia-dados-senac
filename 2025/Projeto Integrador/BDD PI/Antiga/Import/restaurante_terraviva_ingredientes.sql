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
-- Table structure for table `ingredientes`
--

DROP TABLE IF EXISTS `ingredientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ingredientes` (
  `id_ingrediente` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(120) NOT NULL,
  `unidade_medida` varchar(20) NOT NULL,
  `tipo` varchar(50) DEFAULT NULL,
  `origem` varchar(50) DEFAULT NULL,
  `valor` decimal(10,4) NOT NULL DEFAULT '0.0000',
  `contem_ovo` tinyint(1) NOT NULL DEFAULT '0',
  `contem_leite` tinyint(1) NOT NULL DEFAULT '0',
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_ingrediente`),
  KEY `idx_ing_nome` (`nome`)
) ENGINE=InnoDB AUTO_INCREMENT=81 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ingredientes`
--

LOCK TABLES `ingredientes` WRITE;
/*!40000 ALTER TABLE `ingredientes` DISABLE KEYS */;
INSERT INTO `ingredientes` VALUES (1,'Ingred_001','l','verdura','vegetal',19.6797,0,0,1),(2,'Ingred_002','un','grãos','vegetal',7.5401,0,0,1),(3,'Ingred_003','l','ovo','animal',5.8562,1,0,1),(4,'Ingred_004','l','laticinio','animal',18.9129,0,1,1),(5,'Ingred_005','un','temperos','vegetal',8.9148,0,0,1),(6,'Ingred_006','kg','grãos','vegetal',16.5395,0,0,1),(7,'Ingred_007','un','ovo','animal',16.4617,1,0,1),(8,'Ingred_008','un','ovo','animal',4.3650,1,0,1),(9,'Ingred_009','un','laticinio','animal',18.7350,0,1,1),(10,'Ingred_010','g','ovo','animal',14.9437,1,0,1),(11,'Ingred_011','kg','ovo','animal',3.6520,1,0,1),(12,'Ingred_012','l','verdura','vegetal',2.6827,0,0,1),(13,'Ingred_013','g','temperos','vegetal',10.0148,0,0,1),(14,'Ingred_014','g','temperos','vegetal',2.7460,0,0,1),(15,'Ingred_015','g','grãos','vegetal',3.2838,0,0,1),(16,'Ingred_016','g','grãos','vegetal',2.5602,0,0,1),(17,'Ingred_017','un','verdura','vegetal',10.1574,0,0,1),(18,'Ingred_018','un','laticinio','animal',17.4660,0,1,1),(19,'Ingred_019','l','ovo','animal',17.0317,1,0,1),(20,'Ingred_020','l','temperos','vegetal',4.9564,0,0,1),(21,'Ingred_021','un','temperos','vegetal',10.6582,0,0,1),(22,'Ingred_022','l','ovo','animal',12.8320,1,0,1),(23,'Ingred_023','g','grãos','vegetal',12.7891,0,0,1),(24,'Ingred_024','g','ovo','animal',10.6651,1,0,1),(25,'Ingred_025','kg','ovo','animal',1.8988,1,0,1),(26,'Ingred_026','l','grãos','vegetal',17.9464,0,0,1),(27,'Ingred_027','un','ovo','animal',18.4483,1,0,1),(28,'Ingred_028','g','temperos','vegetal',5.3072,0,0,1),(29,'Ingred_029','g','grãos','vegetal',20.4767,0,0,1),(30,'Ingred_030','kg','verdura','vegetal',8.8419,0,0,1),(31,'Ingred_031','l','temperos','vegetal',8.4841,0,0,1),(32,'Ingred_032','g','ovo','animal',13.9987,1,0,1),(33,'Ingred_033','g','grãos','vegetal',4.8279,0,0,1),(34,'Ingred_034','un','temperos','vegetal',2.2641,0,0,1),(35,'Ingred_035','kg','temperos','vegetal',4.7751,0,0,1),(36,'Ingred_036','kg','laticinio','animal',14.8766,0,1,1),(37,'Ingred_037','l','grãos','vegetal',15.2041,0,0,1),(38,'Ingred_038','g','grãos','vegetal',8.6551,0,0,1),(39,'Ingred_039','un','laticinio','animal',15.8973,0,1,1),(40,'Ingred_040','g','ovo','animal',12.0953,1,0,1),(41,'Ingred_041','g','temperos','vegetal',12.4003,0,0,1),(42,'Ingred_042','l','ovo','animal',19.4462,1,0,1),(43,'Ingred_043','un','grãos','vegetal',14.8912,0,0,1),(44,'Ingred_044','kg','verdura','vegetal',20.2512,0,0,1),(45,'Ingred_045','kg','verdura','vegetal',12.0319,0,0,1),(46,'Ingred_046','kg','ovo','animal',9.7685,1,0,1),(47,'Ingred_047','l','temperos','vegetal',10.6181,0,0,1),(48,'Ingred_048','kg','verdura','vegetal',19.7000,0,0,1),(49,'Ingred_049','kg','ovo','animal',3.3092,1,0,1),(50,'Ingred_050','kg','verdura','vegetal',6.8379,0,0,1),(51,'Ingred_051','kg','verdura','vegetal',11.6823,0,0,1),(52,'Ingred_052','l','ovo','animal',3.9620,1,0,1),(53,'Ingred_053','l','grãos','vegetal',15.5379,0,0,1),(54,'Ingred_054','un','temperos','vegetal',10.0613,0,0,1),(55,'Ingred_055','kg','grãos','vegetal',19.3757,0,0,1),(56,'Ingred_056','kg','verdura','vegetal',12.4042,0,0,1),(57,'Ingred_057','l','temperos','vegetal',3.1903,0,0,1),(58,'Ingred_058','g','grãos','vegetal',14.3082,0,0,1),(59,'Ingred_059','l','laticinio','animal',12.5171,0,1,1),(60,'Ingred_060','l','verdura','vegetal',9.0508,0,0,1),(61,'Ingred_061','kg','temperos','vegetal',20.0988,0,0,1),(62,'Ingred_062','un','laticinio','animal',17.5299,0,1,1),(63,'Ingred_063','g','grãos','vegetal',13.7255,0,0,1),(64,'Ingred_064','l','temperos','vegetal',18.7322,0,0,1),(65,'Ingred_065','l','grãos','vegetal',1.9845,0,0,1),(66,'Ingred_066','un','temperos','vegetal',6.9900,0,0,1),(67,'Ingred_067','g','ovo','animal',19.6156,1,0,1),(68,'Ingred_068','kg','laticinio','animal',14.5202,0,1,1),(69,'Ingred_069','l','grãos','vegetal',5.9918,0,0,1),(70,'Ingred_070','g','laticinio','animal',1.3019,0,1,1),(71,'Ingred_071','kg','laticinio','animal',16.3736,0,1,1),(72,'Ingred_072','kg','temperos','vegetal',8.7379,0,0,1),(73,'Ingred_073','un','grãos','vegetal',10.9474,0,0,1),(74,'Ingred_074','l','verdura','vegetal',13.8695,0,0,1),(75,'Ingred_075','kg','verdura','vegetal',7.9819,0,0,1),(76,'Ingred_076','l','ovo','animal',18.0714,1,0,1),(77,'Ingred_077','kg','laticinio','animal',4.1984,0,1,1),(78,'Ingred_078','g','laticinio','animal',1.9419,0,1,1),(79,'Ingred_079','l','temperos','vegetal',15.9969,0,0,1),(80,'Ingred_080','l','ovo','animal',1.3239,1,0,1);
/*!40000 ALTER TABLE `ingredientes` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_historico_custo` AFTER UPDATE ON `ingredientes` FOR EACH ROW BEGIN
    INSERT INTO CustoIngredienteHistorico (id_ingrediente, data, valor)
    VALUES (NEW.id_ingrediente, CURDATE(), NEW.valor)
    ON DUPLICATE KEY UPDATE valor = NEW.valor;
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

-- Dump completed on 2025-11-19 11:59:17
