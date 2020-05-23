
--
-- Table structure for table `mandos_expression`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mandos_expression` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `gene_id` mediumint(8) unsigned NOT NULL,
  `tissue_id` smallint(5) unsigned NOT NULL,
  `developmental_stage` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `level` double NOT NULL,
  `confidence` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `external_id` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ref_id` smallint(5) unsigned NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `gene_tissue_stage_ref_unique` (`gene_id`,`tissue_id`,`developmental_stage`,`ref_id`),
  UNIQUE KEY `external_id_ref_unique` (`external_id`,`ref_id`),
  KEY `expression_to_ref` (`ref_id`),
  KEY `expression_to_tissue` (`tissue_id`),
  KEY `confidence` (`confidence`),
  CONSTRAINT `expression_to_gene` FOREIGN KEY (`gene_id`) REFERENCES `genes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `expression_to_ref` FOREIGN KEY (`ref_id`) REFERENCES `refs` (`id`),
  CONSTRAINT `expression_to_tissue` FOREIGN KEY (`tissue_id`) REFERENCES `tissues` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mandos_info`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mandos_info` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `compound_id` mediumint(8) unsigned NOT NULL,
  `name` varchar(100) NOT NULL,
  `value` varchar(1000) NOT NULL,
  `ref_id` smallint(5) unsigned NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `mandos_chem_info_name_source_compound_unique` (`name`,`ref_id`,`compound_id`),
  KEY `mandos_chem_info_to_data_source` (`ref_id`),
  KEY `name` (`name`),
  KEY `value` (`value`),
  KEY `mandos_info_to_compound` (`compound_id`),
  CONSTRAINT `mandos_chem_info_to_data_source` FOREIGN KEY (`ref_id`) REFERENCES `refs` (`id`),
  CONSTRAINT `mandos_info_to_compound` FOREIGN KEY (`compound_id`) REFERENCES `compounds` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mandos_object_links`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mandos_object_links` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` mediumint(8) unsigned NOT NULL,
  `child_id` mediumint(8) unsigned NOT NULL,
  `ref_id` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `parent_id` (`parent_id`),
  KEY `child_id` (`child_id`),
  KEY `ref_id` (`ref_id`),
  CONSTRAINT `mandos_object_links_ibfk_1` FOREIGN KEY (`child_id`) REFERENCES `mandos_objects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mandos_object_links_ibfk_2` FOREIGN KEY (`parent_id`) REFERENCES `mandos_objects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mandos_object_links_ibfk_3` FOREIGN KEY (`ref_id`) REFERENCES `refs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mandos_object_tags`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mandos_object_tags` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `object` mediumint(8) unsigned NOT NULL,
  `ref` smallint(5) unsigned NOT NULL,
  `name` varchar(150) NOT NULL,
  `value` varchar(250) NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `object_ref_name_value_unique` (`object`,`ref`,`name`,`value`),
  KEY `object` (`object`),
  KEY `ref` (`ref`),
  KEY `label` (`value`),
  CONSTRAINT `mandos_object_tag_to_object` FOREIGN KEY (`object`) REFERENCES `mandos_objects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mandos_object_tag_to_ref` FOREIGN KEY (`ref`) REFERENCES `refs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mandos_objects`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mandos_objects` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `ref_id` smallint(5) unsigned NOT NULL,
  `external_id` varchar(250) NOT NULL,
  `name` varchar(250) DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `data_source_external_id_unique` (`ref_id`,`external_id`),
  KEY `data_source_id` (`ref_id`),
  KEY `external_id` (`external_id`),
  CONSTRAINT `mandos_key_to_data_source` FOREIGN KEY (`ref_id`) REFERENCES `refs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mandos_predicates`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mandos_predicates` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `ref_id` smallint(5) unsigned NOT NULL,
  `external_id` varchar(250) DEFAULT NULL,
  `name` varchar(250) NOT NULL,
  `kind` enum('target','class','indication','other') NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_source_unique` (`name`,`ref_id`),
  UNIQUE KEY `external_id_source_unique` (`external_id`,`ref_id`),
  KEY `mandos_mode_to_source` (`ref_id`),
  KEY `name` (`name`),
  KEY `external_id` (`external_id`),
  CONSTRAINT `mandos_mode_to_source` FOREIGN KEY (`ref_id`) REFERENCES `refs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mandos_rule_tags`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mandos_rule_tags` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rule` int(10) unsigned NOT NULL,
  `ref` smallint(5) unsigned NOT NULL,
  `name` varchar(150) NOT NULL,
  `value` varchar(250) NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `rule_ref_name_value_unique` (`rule`,`ref`,`name`,`value`),
  KEY `rule` (`rule`),
  KEY `label` (`value`),
  KEY `ref` (`ref`),
  CONSTRAINT `mandos_rule_tag_to_object` FOREIGN KEY (`rule`) REFERENCES `mandos_rules` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mandos_rule_tag_to_ref` FOREIGN KEY (`ref`) REFERENCES `refs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mandos_rules`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mandos_rules` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ref_id` smallint(5) unsigned NOT NULL,
  `compound_id` mediumint(8) unsigned NOT NULL,
  `object_id` mediumint(8) unsigned NOT NULL,
  `external_id` varchar(250) DEFAULT NULL,
  `predicate_id` tinyint(3) unsigned NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `data_source_compound_mode_unique` (`ref_id`,`compound_id`,`object_id`,`predicate_id`),
  KEY `data_source_id` (`ref_id`),
  KEY `compound_id` (`compound_id`),
  KEY `external_id` (`external_id`),
  KEY `key_id` (`object_id`),
  KEY `mode_id` (`predicate_id`),
  CONSTRAINT `mandos_association_to_compound` FOREIGN KEY (`compound_id`) REFERENCES `compounds` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mandos_association_to_data_source` FOREIGN KEY (`ref_id`) REFERENCES `refs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mandos_association_to_key` FOREIGN KEY (`object_id`) REFERENCES `mandos_objects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `mandos_association_to_mode` FOREIGN KEY (`predicate_id`) REFERENCES `mandos_predicates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mandos_tissues`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mandos_tissues` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `external_id` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `ref_id` smallint(5) unsigned NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `external_id_ref_unique` (`external_id`,`ref_id`),
  KEY `mandos_tissue_to_ref` (`ref_id`),
  CONSTRAINT `mandos_tissue_to_ref` FOREIGN KEY (`ref_id`) REFERENCES `refs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `tissues`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tissues` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `external_id` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `ref_id` smallint(5) unsigned NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `external_id_ref_unique` (`external_id`,`ref_id`),
  KEY `tissue_to_ref` (`ref_id`),
  KEY `name` (`name`),
  CONSTRAINT `tissue_to_ref` FOREIGN KEY (`ref_id`) REFERENCES `refs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;



--
-- Table structure for table `biomarker_experiments`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `biomarker_experiments` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `tag` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(250) COLLATE utf8_unicode_ci NOT NULL,
  `kind` enum('ms','rna-seq','imaging','other') COLLATE utf8_unicode_ci NOT NULL,
  `experimentalist_id` smallint(5) unsigned NOT NULL,
  `ref_id` smallint(5) unsigned NOT NULL,
  `datetime_prepared` datetime NOT NULL,
  `datetime_collected` datetime NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `tag_unique` (`tag`),
  KEY `biomarker_experiment_to_user` (`experimentalist_id`),
  KEY `biomarker_experiment_to_ref` (`ref_id`),
  CONSTRAINT `biomarker_experiment_to_ref` FOREIGN KEY (`ref_id`) REFERENCES `refs` (`id`),
  CONSTRAINT `biomarker_experiment_to_user` FOREIGN KEY (`experimentalist_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `biomarker_levels`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `biomarker_levels` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `sample_id` smallint(5) unsigned NOT NULL,
  `biomarker_id` int(10) unsigned NOT NULL,
  `tissue_id` smallint(5) unsigned DEFAULT NULL,
  `fold_change` double unsigned DEFAULT NULL,
  `full_value` varchar(250) COLLATE utf8_unicode_ci NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `biomarker_level_to_biomarker` (`biomarker_id`),
  KEY `biomarker_level_to_sample` (`sample_id`),
  CONSTRAINT `biomarker_level_to_biomarker` FOREIGN KEY (`biomarker_id`) REFERENCES `biomarkers` (`id`),
  CONSTRAINT `biomarker_level_to_sample` FOREIGN KEY (`sample_id`) REFERENCES `biomarker_samples` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `biomarker_samples`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `biomarker_samples` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `experiment_id` smallint(5) unsigned NOT NULL,
  `name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `control_type_id` tinyint(3) unsigned NOT NULL,
  `from_well_id` mediumint(8) unsigned DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_experiment_unique` (`name`,`experiment_id`),
  KEY `biomarker_sample_to_biomarker_experiment` (`experiment_id`),
  KEY `biomarker_sample_to_well` (`from_well_id`),
  KEY `biomarker_sample_to_control_type` (`control_type_id`),
  CONSTRAINT `biomarker_sample_to_biomarker_experiment` FOREIGN KEY (`experiment_id`) REFERENCES `biomarker_experiments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `biomarker_sample_to_control_type` FOREIGN KEY (`control_type_id`) REFERENCES `control_types` (`id`),
  CONSTRAINT `biomarker_sample_to_well` FOREIGN KEY (`from_well_id`) REFERENCES `wells` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `biomarker_treatments`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `biomarker_treatments` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `sample_id` smallint(5) unsigned NOT NULL,
  `batch_id` mediumint(8) unsigned NOT NULL,
  `micromolar_dose` double unsigned NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `sample_batch_unique` (`sample_id`,`batch_id`),
  KEY `biomarker_treatment_to_batch` (`batch_id`),
  CONSTRAINT `biomarker_treatment_to_batch` FOREIGN KEY (`batch_id`) REFERENCES `batches` (`id`),
  CONSTRAINT `biomarker_treatment_to_sample` FOREIGN KEY (`sample_id`) REFERENCES `biomarker_samples` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `biomarkers`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `biomarkers` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(250) COLLATE utf8_unicode_ci NOT NULL,
  `is_gene_id` mediumint(8) unsigned DEFAULT NULL,
  `ref_id` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `biomarker_to_gene` (`is_gene_id`),
  KEY `biomarker_to_ref` (`ref_id`),
  CONSTRAINT `biomarker_to_gene` FOREIGN KEY (`is_gene_id`) REFERENCES `genes` (`id`) ON DELETE SET NULL,
  CONSTRAINT `biomarker_to_ref` FOREIGN KEY (`ref_id`) REFERENCES `refs` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
