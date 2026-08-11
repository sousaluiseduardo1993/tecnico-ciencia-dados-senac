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
-- Table structure for table `compraitens`
--

DROP TABLE IF EXISTS `compraitens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `compraitens` (
  `id_compra_item` int NOT NULL AUTO_INCREMENT,
  `id_compra` int NOT NULL,
  `id_ingrediente` int NOT NULL,
  `quantidade` decimal(10,3) NOT NULL,
  `valor_unitario` decimal(10,4) NOT NULL,
  `valor_total` decimal(12,4) GENERATED ALWAYS AS ((`quantidade` * `valor_unitario`)) STORED,
  PRIMARY KEY (`id_compra_item`),
  KEY `id_compra` (`id_compra`),
  KEY `id_ingrediente` (`id_ingrediente`),
  CONSTRAINT `compraitens_ibfk_1` FOREIGN KEY (`id_compra`) REFERENCES `compras` (`id_compra`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `compraitens_ibfk_2` FOREIGN KEY (`id_ingrediente`) REFERENCES `ingredientes` (`id_ingrediente`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compraitens`
--

LOCK TABLES `compraitens` WRITE;
/*!40000 ALTER TABLE `compraitens` DISABLE KEYS */;
/*!40000 ALTER TABLE `compraitens` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_insert_compra_item` AFTER INSERT ON `compraitens` FOR EACH ROW BEGIN
  -- 1) Inserir movimento de estoque do tipo 'entrada'
  INSERT INTO MovimentosEstoque (id_ingrediente, tipo, quantidade, data_hora, id_fornecedor, observacao, id_funcionario_responsavel)
  VALUES (
      NEW.id_ingrediente,
      'entrada',
      NEW.quantidade,
      NOW(),
      (SELECT c.id_fornecedor FROM Compras c WHERE c.id_compra = NEW.id_compra LIMIT 1),
      CONCAT('Entrada via compra id=', NEW.id_compra),
      NULL
  );

  -- 2) Atualizar valor atual do ingrediente para o preço unitário da compra
  UPDATE Ingredientes
    SET valor = NEW.valor_unitario
    WHERE id_ingrediente = NEW.id_ingrediente;

  -- 3) Inserir entrada no histórico de custo
  INSERT INTO CustoIngredienteHistorico (id_ingrediente, data, valor)
  VALUES (NEW.id_ingrediente, CURDATE(), NEW.valor_unitario)
  ON DUPLICATE KEY UPDATE valor = NEW.valor_unitario;

  -- 4) Registrar no audit
  INSERT INTO Audit_MovimentoEstoque (id_movimento, id_ingrediente, tipo, quantidade, data_hora, origem, usuario)
  VALUES (LAST_INSERT_ID(), NEW.id_ingrediente, 'entrada', NEW.quantidade, NOW(), CONCAT('compra#', NEW.id_compra), NULL);
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

-- Dump completed on 2025-11-30 20:55:22
