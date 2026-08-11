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
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes` (
  `id_cliente` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `data_cadastro` date NOT NULL DEFAULT (curdate()),
  PRIMARY KEY (`id_cliente`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_cli_nome` (`nome`),
  KEY `idx_cli_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
INSERT INTO `clientes` VALUES (1,'Cliente 0001','cliente1@mail.com','2138923486','2025-10-18'),(2,'Cliente 0002','cliente2@mail.com','2102747488','2025-07-26'),(3,'Cliente 0003','cliente3@mail.com','2189586854','2025-05-17'),(4,'Cliente 0004','cliente4@mail.com','2190457903','2025-07-02'),(5,'Cliente 0005','cliente5@mail.com','2159727968','2025-04-10'),(6,'Cliente 0006','cliente6@mail.com','2102526656','2025-07-07'),(7,'Cliente 0007','cliente7@mail.com','2112926267','2025-08-08'),(8,'Cliente 0008','cliente8@mail.com','2152270399','2025-01-08'),(9,'Cliente 0009','cliente9@mail.com','2142105549','2025-04-02'),(10,'Cliente 0010','cliente10@mail.com','2124051712','2024-11-03'),(11,'Cliente 0011','cliente11@mail.com','2171120424','2025-05-25'),(12,'Cliente 0012','cliente12@mail.com','2146117968','2024-12-13'),(13,'Cliente 0013','cliente13@mail.com','2135448933','2025-11-03'),(14,'Cliente 0014','cliente14@mail.com','2151394232','2025-01-01'),(15,'Cliente 0015','cliente15@mail.com','2156859055','2024-12-22'),(16,'Cliente 0016','cliente16@mail.com','2139724164','2025-01-27'),(17,'Cliente 0017','cliente17@mail.com','2194557601','2025-09-27'),(18,'Cliente 0018','cliente18@mail.com','2119494923','2025-10-13'),(19,'Cliente 0019','cliente19@mail.com','2177519154','2025-01-18'),(20,'Cliente 0020','cliente20@mail.com','2129855073','2025-11-06'),(21,'Cliente 0021','cliente21@mail.com','2161239580','2025-09-04'),(22,'Cliente 0022','cliente22@mail.com','2186915987','2025-09-01'),(23,'Cliente 0023','cliente23@mail.com','2151778617','2025-03-31'),(24,'Cliente 0024','cliente24@mail.com','2119871792','2024-12-25'),(25,'Cliente 0025','cliente25@mail.com','2161801119','2025-05-31'),(26,'Cliente 0026','cliente26@mail.com','2118698906','2025-07-31'),(27,'Cliente 0027','cliente27@mail.com','2145157810','2025-11-10'),(28,'Cliente 0028','cliente28@mail.com','2163940024','2025-10-10'),(29,'Cliente 0029','cliente29@mail.com','2138192668','2025-04-27'),(30,'Cliente 0030','cliente30@mail.com','2176005347','2024-10-28'),(31,'Cliente 0031','cliente31@mail.com','2114960834','2025-05-19'),(32,'Cliente 0032','cliente32@mail.com','2197935418','2025-10-16'),(33,'Cliente 0033','cliente33@mail.com','2156388552','2025-09-03'),(34,'Cliente 0034','cliente34@mail.com','2108505628','2025-10-16'),(35,'Cliente 0035','cliente35@mail.com','2149958696','2025-02-17'),(36,'Cliente 0036','cliente36@mail.com','2136068139','2025-06-14'),(37,'Cliente 0037','cliente37@mail.com','2160546824','2025-07-31'),(38,'Cliente 0038','cliente38@mail.com','2142013526','2025-04-09'),(39,'Cliente 0039','cliente39@mail.com','2157077525','2025-08-10'),(40,'Cliente 0040','cliente40@mail.com','2180067126','2024-11-18'),(41,'Cliente 0041','cliente41@mail.com','2113831960','2025-07-26'),(42,'Cliente 0042','cliente42@mail.com','2158926107','2024-11-19'),(43,'Cliente 0043','cliente43@mail.com','2177423066','2025-09-27'),(44,'Cliente 0044','cliente44@mail.com','2154938046','2025-01-04'),(45,'Cliente 0045','cliente45@mail.com','2172482658','2025-04-11'),(46,'Cliente 0046','cliente46@mail.com','2140646893','2025-02-18'),(47,'Cliente 0047','cliente47@mail.com','2126837553','2025-06-09'),(48,'Cliente 0048','cliente48@mail.com','2112883443','2025-01-29'),(49,'Cliente 0049','cliente49@mail.com','2145180137','2025-05-21'),(50,'Cliente 0050','cliente50@mail.com','2187485719','2025-01-13'),(51,'Cliente 0051','cliente51@mail.com','2111344126','2025-03-14'),(52,'Cliente 0052','cliente52@mail.com','2197900668','2025-01-22'),(53,'Cliente 0053','cliente53@mail.com','2146868400','2025-08-21'),(54,'Cliente 0054','cliente54@mail.com','2141032811','2025-10-28'),(55,'Cliente 0055','cliente55@mail.com','2132737677','2025-07-05'),(56,'Cliente 0056','cliente56@mail.com','2130980898','2025-06-17'),(57,'Cliente 0057','cliente57@mail.com','2141709123','2025-06-06'),(58,'Cliente 0058','cliente58@mail.com','2116878786','2024-11-08'),(59,'Cliente 0059','cliente59@mail.com','2121888598','2025-03-21'),(60,'Cliente 0060','cliente60@mail.com','2140608331','2025-02-17'),(61,'Cliente 0061','cliente61@mail.com','2155682193','2025-03-04'),(62,'Cliente 0062','cliente62@mail.com','2157522154','2025-03-31'),(63,'Cliente 0063','cliente63@mail.com','2156792476','2025-09-23'),(64,'Cliente 0064','cliente64@mail.com','2120525986','2025-10-21'),(65,'Cliente 0065','cliente65@mail.com','2141987267','2024-11-27'),(66,'Cliente 0066','cliente66@mail.com','2109107308','2025-05-30'),(67,'Cliente 0067','cliente67@mail.com','2158983146','2025-08-06'),(68,'Cliente 0068','cliente68@mail.com','2187069965','2024-11-24'),(69,'Cliente 0069','cliente69@mail.com','2195299520','2024-10-29'),(70,'Cliente 0070','cliente70@mail.com','2108795948','2025-10-09'),(71,'Cliente 0071','cliente71@mail.com','2100380538','2025-09-16'),(72,'Cliente 0072','cliente72@mail.com','2135296178','2025-08-22'),(73,'Cliente 0073','cliente73@mail.com','2190835393','2025-02-15'),(74,'Cliente 0074','cliente74@mail.com','2195163343','2024-12-22'),(75,'Cliente 0075','cliente75@mail.com','2119895221','2024-11-13'),(76,'Cliente 0076','cliente76@mail.com','2115830975','2025-06-10'),(77,'Cliente 0077','cliente77@mail.com','2120939359','2025-05-07'),(78,'Cliente 0078','cliente78@mail.com','2138632831','2025-07-28'),(79,'Cliente 0079','cliente79@mail.com','2169120066','2024-11-04'),(80,'Cliente 0080','cliente80@mail.com','2124014356','2024-12-21'),(81,'Cliente 0081','cliente81@mail.com','2128412009','2025-08-11'),(82,'Cliente 0082','cliente82@mail.com','2100157139','2025-07-26'),(83,'Cliente 0083','cliente83@mail.com','2152526837','2025-05-03'),(84,'Cliente 0084','cliente84@mail.com','2169182060','2025-07-07'),(85,'Cliente 0085','cliente85@mail.com','2179522697','2025-10-01'),(86,'Cliente 0086','cliente86@mail.com','2124185616','2024-12-16'),(87,'Cliente 0087','cliente87@mail.com','2166962330','2025-02-05'),(88,'Cliente 0088','cliente88@mail.com','2192337768','2025-05-04'),(89,'Cliente 0089','cliente89@mail.com','2126366775','2025-02-13'),(90,'Cliente 0090','cliente90@mail.com','2152920572','2025-01-08'),(91,'Cliente 0091','cliente91@mail.com','2194144648','2025-05-01'),(92,'Cliente 0092','cliente92@mail.com','2114098707','2025-04-12'),(93,'Cliente 0093','cliente93@mail.com','2127370416','2025-09-07'),(94,'Cliente 0094','cliente94@mail.com','2146058453','2025-05-26'),(95,'Cliente 0095','cliente95@mail.com','2145446431','2024-12-18'),(96,'Cliente 0096','cliente96@mail.com','2141286980','2025-06-18'),(97,'Cliente 0097','cliente97@mail.com','2154817936','2025-08-15'),(98,'Cliente 0098','cliente98@mail.com','2123724841','2025-10-06'),(99,'Cliente 0099','cliente99@mail.com','2173387113','2025-11-02'),(100,'Cliente 0100','cliente100@mail.com','2173657980','2024-12-31'),(101,'Cliente 0101','cliente101@mail.com','2179468900','2025-06-27'),(102,'Cliente 0102','cliente102@mail.com','2108123788','2025-09-10'),(103,'Cliente 0103','cliente103@mail.com','2141884000','2025-03-21'),(104,'Cliente 0104','cliente104@mail.com','2104824685','2025-06-24'),(105,'Cliente 0105','cliente105@mail.com','2138602781','2025-05-15'),(106,'Cliente 0106','cliente106@mail.com','2127785125','2025-02-26'),(107,'Cliente 0107','cliente107@mail.com','2164948988','2025-09-23'),(108,'Cliente 0108','cliente108@mail.com','2147976994','2025-09-11'),(109,'Cliente 0109','cliente109@mail.com','2195881444','2024-12-21'),(110,'Cliente 0110','cliente110@mail.com','2101199857','2025-10-03'),(111,'Cliente 0111','cliente111@mail.com','2198643503','2025-04-02'),(112,'Cliente 0112','cliente112@mail.com','2107607933','2025-10-11'),(113,'Cliente 0113','cliente113@mail.com','2131523269','2025-04-28'),(114,'Cliente 0114','cliente114@mail.com','2111669810','2025-02-14'),(115,'Cliente 0115','cliente115@mail.com','2144653097','2025-04-22'),(116,'Cliente 0116','cliente116@mail.com','2170758820','2025-01-15'),(117,'Cliente 0117','cliente117@mail.com','2163149008','2025-04-11'),(118,'Cliente 0118','cliente118@mail.com','2150398805','2025-11-02'),(119,'Cliente 0119','cliente119@mail.com','2193032794','2025-08-31'),(120,'Cliente 0120','cliente120@mail.com','2162347411','2025-01-18');
/*!40000 ALTER TABLE `clientes` ENABLE KEYS */;
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
