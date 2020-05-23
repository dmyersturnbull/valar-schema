
--
-- Table structure for table `dags_to_create`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dags_to_create` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `submission_hash` char(12) COLLATE utf8mb4_unicode_520_ci NOT NULL,
  `dag_created` tinyint(1) NOT NULL DEFAULT 0,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `feature_type` tinyint(3) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_hash_hex_feature` (`submission_hash`,`feature_type`),
  KEY `feature_type` (`feature_type`),
  CONSTRAINT `dags_to_create_ibfk_1` FOREIGN KEY (`feature_type`) REFERENCES `features` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
