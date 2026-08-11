CREATE DATABASE  IF NOT EXISTS `restaurante_terraviva` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `restaurante_terraviva`;
-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: restaurante_terraviva
-- ------------------------------------------------------
-- Server version	9.4.0

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
  KEY `idx_ing_nome` (`nome`),
  KEY `idx_ing_ativo` (`ativo`)
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ingredientes`
--

LOCK TABLES `ingredientes` WRITE;
/*!40000 ALTER TABLE `ingredientes` DISABLE KEYS */;
INSERT INTO `ingredientes` VALUES (1,'Caju','kg','fruta','vegetal',18.0000,0,0,1),(2,'Banana da Terra','kg','fruta','vegetal',9.0000,0,0,1),(3,'Leite de Coco','l','líquido','vegetal',10.0000,0,0,1),(4,'Azeite de Dendê','l','óleo','vegetal',22.0000,0,0,1),(5,'Arroz Integral','kg','grão','vegetal',12.0000,0,0,1),(6,'Farofa de Dendê','kg','mistura','vegetal',16.0000,0,0,1),(7,'Quinoa','kg','grão','vegetal',28.0000,0,0,1),(8,'Arroz Selvagem','kg','grão','vegetal',40.0000,0,0,1),(9,'Tofu','kg','proteína vegetal','vegetal',24.0000,0,0,1),(10,'Brócolis','kg','verdura','vegetal',12.0000,0,0,1),(11,'Edamame','kg','leguminosa','vegetal',25.0000,0,0,1),(12,'Cenoura','kg','raiz','vegetal',5.0000,0,0,1),(13,'Molho Tahine','kg','pasta','vegetal',35.0000,0,0,1),(14,'Abobrinha','kg','legume','vegetal',8.0000,0,0,1),(15,'Lentilha','kg','grão','vegetal',14.0000,0,0,1),(16,'Molho de Tomate','kg','molho','vegetal',9.0000,0,0,1),(17,'Queijo de Castanha','kg','vegano','vegetal',60.0000,0,0,1),(18,'Grão-de-bico','kg','grão','vegetal',12.0000,0,0,1),(19,'Cebola Caramelizada','kg','vegetal','vegetal',15.0000,0,0,1),(20,'Batata Rústica','kg','legume','vegetal',7.0000,0,0,1),(21,'Castanhas','kg','oleaginosa','vegetal',60.0000,0,0,1),(22,'Cacau 70%','kg','cacau','vegetal',80.0000,0,0,1),(23,'Sorbet de Morango','kg','sobremesa','vegetal',35.0000,0,0,1),(24,'Couve','kg','verdura','vegetal',6.0000,0,0,1),(25,'Gengibre','kg','raiz','vegetal',20.0000,0,0,1),(26,'Maçã','kg','fruta','vegetal',8.0000,0,0,1),(27,'Kombucha Base','l','bebida','vegetal',12.0000,0,0,1),(28,'Água','l','líquido','mineral',1.0000,0,0,1),(29,'Hortelã','kg','erva','vegetal',18.0000,0,0,1),(30,'Linguiça Vegana','kg','proteína vegetal','vegetal',38.0000,0,0,1),(31,'Carne de Legumes','kg','mistura vegetal','vegetal',30.0000,0,0,1),(32,'Néctar de Coco','l','líquido','vegetal',22.0000,0,0,1),(33,'Caldo Base','l','líquido','vegetal',8.0000,0,0,1),(34,'Proteína Plant-Based','kg','proteína vegetal','vegetal',34.0000,0,0,1),(35,'Feijão','kg','grão','vegetal',10.0000,0,0,1),(36,'Caju','un',NULL,NULL,20.0000,0,0,1),(37,'Banana da Terra','un',NULL,NULL,25.0000,0,0,1),(38,'Leite de Coco','un',NULL,NULL,15.0000,0,0,1),(39,'Azeite de Dendê','un',NULL,NULL,10.0000,0,0,1),(40,'Arroz Integral','un',NULL,NULL,50.0000,0,0,1),(41,'Farofa de Dendê','un',NULL,NULL,20.0000,0,0,1),(42,'Quinoa','un',NULL,NULL,15.0000,0,0,1),(43,'Arroz Selvagem','un',NULL,NULL,8.0000,0,0,1),(44,'Tofu','un',NULL,NULL,12.0000,0,0,1),(45,'Brócolis','un',NULL,NULL,18.0000,0,0,1),(46,'Edamame','un',NULL,NULL,10.0000,0,0,1),(47,'Cenoura','un',NULL,NULL,25.0000,0,0,1),(48,'Molho Tahine','un',NULL,NULL,5.0000,0,0,1),(49,'Abobrinha','un',NULL,NULL,20.0000,0,0,1),(50,'Lentilha','un',NULL,NULL,25.0000,0,0,1),(51,'Molho de Tomate','un',NULL,NULL,30.0000,0,0,1),(52,'Queijo de Castanha','un',NULL,NULL,5.0000,0,0,1),(53,'Grão-de-bico','un',NULL,NULL,40.0000,0,0,1),(54,'Cebola Caramelizada','un',NULL,NULL,10.0000,0,0,1),(55,'Batata Rústica','un',NULL,NULL,30.0000,0,0,1),(56,'Castanhas','un',NULL,NULL,8.0000,0,0,1),(57,'Cacau 70%','un',NULL,NULL,6.0000,0,0,1),(58,'Sorbet de Morango','un',NULL,NULL,15.0000,0,0,1),(59,'Couve','un',NULL,NULL,25.0000,0,0,1),(60,'Gengibre','un',NULL,NULL,5.0000,0,0,1),(61,'Maçã','un',NULL,NULL,20.0000,0,0,1),(62,'Kombucha Base','un',NULL,NULL,30.0000,0,0,1),(63,'Água','un',NULL,NULL,500.0000,0,0,1),(64,'Hortelã','un',NULL,NULL,3.0000,0,0,1),(65,'Linguiça Vegana','un',NULL,NULL,10.0000,0,0,1),(66,'Carne de Legumes','un',NULL,NULL,12.0000,0,0,1),(67,'Néctar de Coco','un',NULL,NULL,10.0000,0,0,1),(68,'Caldo Base','un',NULL,NULL,20.0000,0,0,1),(69,'Proteína Plant-Based','un',NULL,NULL,20.0000,0,0,1),(70,'Feijão','un',NULL,NULL,40.0000,0,0,1);
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
    IF NEW.valor <> OLD.valor THEN
        INSERT INTO CustoIngredienteHistorico (id_ingrediente, data, valor)
        VALUES (NEW.id_ingrediente, CURDATE(), NEW.valor)
        ON DUPLICATE KEY UPDATE valor = NEW.valor;
        -- Auditoria simples
        INSERT INTO Audit_Log (tabela_nome, acao, registro_id, dados_antes, dados_depois, comentario)
        VALUES ('Ingredientes','UPDATE', NEW.id_ingrediente, JSON_OBJECT('valor', OLD.valor), JSON_OBJECT('valor', NEW.valor), 'Atualização automática do histórico de custo');
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

-- Dump completed on 2025-11-30 20:55:23
