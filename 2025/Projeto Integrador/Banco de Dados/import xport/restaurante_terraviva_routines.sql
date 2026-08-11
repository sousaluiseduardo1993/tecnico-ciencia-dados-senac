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
-- Temporary view structure for view `vw_vendas_plataforma`
--

DROP TABLE IF EXISTS `vw_vendas_plataforma`;
/*!50001 DROP VIEW IF EXISTS `vw_vendas_plataforma`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_vendas_plataforma` AS SELECT 
 1 AS `plataforma`,
 1 AS `total_pedidos`,
 1 AS `receita_total`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_vendas_por_prato`
--

DROP TABLE IF EXISTS `vw_vendas_por_prato`;
/*!50001 DROP VIEW IF EXISTS `vw_vendas_por_prato`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_vendas_por_prato` AS SELECT 
 1 AS `id_prato`,
 1 AS `prato`,
 1 AS `total_quantidade`,
 1 AS `receita_total`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_custo_prato`
--

DROP TABLE IF EXISTS `vw_custo_prato`;
/*!50001 DROP VIEW IF EXISTS `vw_custo_prato`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_custo_prato` AS SELECT 
 1 AS `id_prato`,
 1 AS `nome`,
 1 AS `custo_total`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_margem_lucro`
--

DROP TABLE IF EXISTS `vw_margem_lucro`;
/*!50001 DROP VIEW IF EXISTS `vw_margem_lucro`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_margem_lucro` AS SELECT 
 1 AS `id_prato`,
 1 AS `prato`,
 1 AS `receita_total`,
 1 AS `custo_total`,
 1 AS `lucro_bruto`,
 1 AS `margem_percentual`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_vendas_plataforma`
--

/*!50001 DROP VIEW IF EXISTS `vw_vendas_plataforma`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_vendas_plataforma` AS select coalesce(`pl`.`nome`,'Interno') AS `plataforma`,count(distinct `ped`.`id_pedido`) AS `total_pedidos`,coalesce(sum(`pg`.`valor`),0.00) AS `receita_total` from ((`pagamentos` `pg` join `pedidos` `ped` on((`ped`.`id_pedido` = `pg`.`id_pedido`))) left join `plataformas` `pl` on((`pl`.`id_plataforma` = `ped`.`id_plataforma`))) group by `plataforma` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_vendas_por_prato`
--

/*!50001 DROP VIEW IF EXISTS `vw_vendas_por_prato`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_vendas_por_prato` AS select `p`.`id_prato` AS `id_prato`,`p`.`nome` AS `prato`,coalesce(sum(`i`.`quantidade`),0) AS `total_quantidade`,coalesce(sum((`i`.`quantidade` * `i`.`preco_unitario`)),0.00) AS `receita_total` from (`itenspedido` `i` join `pratos` `p` on((`p`.`id_prato` = `i`.`id_prato`))) group by `p`.`id_prato`,`p`.`nome` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_custo_prato`
--

/*!50001 DROP VIEW IF EXISTS `vw_custo_prato`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_custo_prato` AS select `p`.`id_prato` AS `id_prato`,`p`.`nome` AS `nome`,coalesce(sum((`pi`.`quantidade` * coalesce((select `c`.`valor` from `custoingredientehistorico` `c` where (`c`.`id_ingrediente` = `pi`.`id_ingrediente`) order by `c`.`data` desc limit 1),0.0000))),0.00) AS `custo_total` from (`pratoingrediente` `pi` join `pratos` `p` on((`p`.`id_prato` = `pi`.`id_prato`))) group by `p`.`id_prato`,`p`.`nome` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_margem_lucro`
--

/*!50001 DROP VIEW IF EXISTS `vw_margem_lucro`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_margem_lucro` AS select `v`.`id_prato` AS `id_prato`,`v`.`prato` AS `prato`,`v`.`receita_total` AS `receita_total`,`c`.`custo_total` AS `custo_total`,(`v`.`receita_total` - `c`.`custo_total`) AS `lucro_bruto`,round((case when (`v`.`receita_total` = 0) then 0 else (((`v`.`receita_total` - `c`.`custo_total`) / `v`.`receita_total`) * 100) end),2) AS `margem_percentual` from (`vw_vendas_por_prato` `v` join `vw_custo_prato` `c` on((`c`.`id_prato` = `v`.`id_prato`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Dumping events for database 'restaurante_terraviva'
--

--
-- Dumping routines for database 'restaurante_terraviva'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_custo_ingrediente_atual` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_custo_ingrediente_atual`(id_ing INT) RETURNS decimal(10,4)
    READS SQL DATA
    DETERMINISTIC
BEGIN
    RETURN (
        SELECT COALESCE(c.valor, 0.0000)
        FROM CustoIngredienteHistorico c
        WHERE c.id_ingrediente = id_ing
        ORDER BY c.data DESC
        LIMIT 1
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_custo_prato` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_custo_prato`(idp INT) RETURNS decimal(12,4)
    READS SQL DATA
    DETERMINISTIC
BEGIN
    RETURN (
        SELECT COALESCE(SUM(pi.quantidade * fn_custo_ingrediente_atual(pi.id_ingrediente)),0.0000)
        FROM PratoIngrediente pi
        WHERE pi.id_prato = idp
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_saldo_ingrediente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_saldo_ingrediente`(id_ing INT) RETURNS decimal(12,3)
    READS SQL DATA
    DETERMINISTIC
BEGIN
    RETURN (
        SELECT COALESCE(SUM(
            CASE WHEN tipo = 'entrada' THEN quantidade
                 WHEN tipo = 'saida' THEN -quantidade
                 ELSE 0 END
        ), 0)
        FROM MovimentosEstoque
        WHERE id_ingrediente = id_ing
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_criar_compra_com_itens` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_criar_compra_com_itens`(
    IN p_id_fornecedor INT,
    IN p_numero_nota VARCHAR(80),
    IN p_usuario VARCHAR(120)
)
BEGIN
    DECLARE v_id_compra INT;
    START TRANSACTION;
    INSERT INTO Compras (id_fornecedor, numero_nota, data_hora, valor_total, observacao)
    VALUES (p_id_fornecedor, p_numero_nota, NOW(), 0.00, CONCAT('Criado por ', p_usuario));
    SET v_id_compra = LAST_INSERT_ID();

    -- Observação: itens devem ser inseridos em seguida via INSERT INTO CompraItens (id_compra = v_id_compra, ...)
    -- Exemplo de uso:
    -- CALL sp_criar_compra_com_itens(1,'NF123','sistema');
    -- INSERT INTO CompraItens (id_compra, id_ingrediente, quantidade, valor_unitario) VALUES (v_id_compra, ...);
    COMMIT;
    SELECT v_id_compra AS id_compra;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_recalcula_preco_sugerido` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_recalcula_preco_sugerido`(IN p_margem_percent DECIMAL(5,2))
BEGIN
    UPDATE Pratos p
    SET preco_base = ROUND( fn_custo_prato(p.id_prato) / (1 - (p_margem_percent/100)), 2)
    WHERE fn_custo_prato(p.id_prato) > 0;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_relatorio_financeiro` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_relatorio_financeiro`(IN dt_ini DATE, IN dt_fim DATE)
BEGIN
    SELECT
        ped.id_pedido,
        ped.data_hora,
        COALESCE(SUM(i.preco_unitario * i.quantidade),0) AS receita,
        COALESCE(SUM(COALESCE(i.custo_estimado, fn_custo_prato(i.id_prato)) * i.quantidade),0) AS custo,
        COALESCE(SUM(i.preco_unitario * i.quantidade),0) - COALESCE(SUM(COALESCE(i.custo_estimado, fn_custo_prato(i.id_prato)) * i.quantidade),0) AS lucro
    FROM Pedidos ped
    JOIN ItensPedido i ON i.id_pedido = ped.id_pedido
    WHERE DATE(ped.data_hora) BETWEEN dt_ini AND dt_fim
    GROUP BY ped.id_pedido
    ORDER BY ped.data_hora;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_top_pratos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_top_pratos`(IN limite INT)
BEGIN
    DECLARE v_limite INT;

    -- Garante que o valor fique entre 1 e 100
    SET v_limite = limite;

    IF v_limite IS NULL OR v_limite < 1 THEN
        SET v_limite = 1;
    ELSEIF v_limite > 100 THEN
        SET v_limite = 100;
    END IF;

    SELECT *
    FROM vw_vendas_por_prato
    ORDER BY total_quantidade DESC
    LIMIT v_limite;
END ;;
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

-- Dump completed on 2025-11-30 20:55:25
