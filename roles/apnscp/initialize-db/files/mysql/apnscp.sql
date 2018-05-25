-- MySQL dump 10.16  Distrib 10.1.25-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: apnscp_esprit
-- ------------------------------------------------------
-- Server version	10.1.25-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `api_keys`
--

DROP TABLE IF EXISTS `api_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_keys` (
  `api_key` char(64) NOT NULL,
  `username` varchar(32) NOT NULL DEFAULT '',
  `domain` varchar(52) DEFAULT NULL,
  `site_id` int(3) NULL DEFAULT NULL,
  `last_used` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`api_key`),
  KEY `soap_keys_index1731` (`username`,`domain`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dav_locks`
--

DROP TABLE IF EXISTS `dav_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dav_locks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `owner` varchar(100) DEFAULT NULL,
  `timeout` int(10) unsigned DEFAULT NULL,
  `created` int(11) DEFAULT NULL,
  `token` varbinary(100) DEFAULT NULL,
  `scope` tinyint(4) DEFAULT NULL,
  `depth` tinyint(4) DEFAULT NULL,
  `uri` varbinary(1000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `token` (`token`),
  KEY `uri` (`uri`(100))
) ENGINE=InnoDB AUTO_INCREMENT=127 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dav_propertystorage`
--

DROP TABLE IF EXISTS `dav_propertystorage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dav_propertystorage` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `path` varbinary(1024) NOT NULL,
  `name` varbinary(100) NOT NULL,
  `valuetype` int(10) unsigned DEFAULT NULL,
  `value` mediumblob,
  PRIMARY KEY (`id`),
  UNIQUE KEY `path_property` (`path`(600),`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3410 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `info_requests`
--

DROP TABLE IF EXISTS `info_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `info_requests` (
  `ip` int(10) unsigned NOT NULL,
  `class` enum('password','username','email') NOT NULL,
  `challenge` char(40) DEFAULT NULL,
  `site_id` int(3) NOT NULL,
  `domain` varchar(52) NOT NULL,
  `username` varchar(32) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `timestamp` (`timestamp`),
  KEY `timestamp_2` (`timestamp`),
  KEY `challenge` (`challenge`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `login_log`
--

DROP TABLE IF EXISTS `login_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `login_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ip` int(10) unsigned NOT NULL DEFAULT '0',
  `login_date` timestamp NULL DEFAULT NULL,
  `domain` varchar(52) DEFAULT NULL,
  `username` varchar(32) NOT NULL DEFAULT '',
  `invoice` char(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `login_log_index1740` (`login_date`),
  KEY `login_log_index1739` (`domain`,`username`),
  KEY `username` (`username`,`domain`),
  KEY `invoice` (`invoice`)
) ENGINE=MyISAM AUTO_INCREMENT=275083 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `page_behavior`
--

DROP TABLE IF EXISTS `page_behavior`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_behavior` (
  `behavior_id` int(10) NOT NULL AUTO_INCREMENT,
  `page_id` int(5) NOT NULL,
  `func_id` int(10) DEFAULT NULL,
  `session_id` varchar(32) DEFAULT NULL,
  `postback` tinyint(1) NOT NULL DEFAULT '0',
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`behavior_id`),
  KEY `session_id` (`session_id`)
) ENGINE=MyISAM AUTO_INCREMENT=48652 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `page_functions`
--

DROP TABLE IF EXISTS `page_functions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_functions` (
  `behavior_id` int(10) NOT NULL,
  `func_order` int(5) NOT NULL,
  `function` varchar(32) NOT NULL,
  KEY `behavior_id` (`behavior_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pages`
--

DROP TABLE IF EXISTS `pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pages` (
  `page_id` int(10) NOT NULL AUTO_INCREMENT,
  `page_name` varchar(24) NOT NULL,
  PRIMARY KEY (`page_id`),
  UNIQUE KEY `page_name` (`page_name`)
) ENGINE=MyISAM AUTO_INCREMENT=112 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quota_tracker`
--

DROP TABLE IF EXISTS `quota_tracker`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quota_tracker` (
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `uid` char(8) NOT NULL DEFAULT '',
  `quota` int(8) unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY `qt_idx` (`uid`,`ts`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 PACK_KEYS=1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `session_information`
--

DROP TABLE IF EXISTS `session_information`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `session_information` (
  `session_id` char(32) NOT NULL DEFAULT '',
  `domain` varchar(52) DEFAULT NULL,
  `username` char(32) DEFAULT NULL,
  `password` varchar(32) DEFAULT '',
  `level` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `login_ts` datetime DEFAULT NULL,
  `last_action` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `session_data` longblob,
  `user_id` int(5) DEFAULT NULL,
  `group_id` int(5) DEFAULT NULL,
  `site_number` int(3) DEFAULT NULL,
  `login_method` enum('http','soap','dav','cli') NOT NULL DEFAULT 'http',
  `auto_logout` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`session_id`),
  KEY `la_idx` (`last_action`),
  KEY `lookup_by_site` (`site_number`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sql_dumps`
--

DROP TABLE IF EXISTS `sql_dumps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sql_dumps` (
  `site_id` int(3) NOT NULL DEFAULT '0',
  `db_type` enum('mysql','pgsql') NOT NULL,
  `db_name` varchar(50) NOT NULL,
  `day_span` int(3) unsigned NOT NULL,
  `extension` enum('gz','bz','zip','none') NOT NULL,
  `next_date` date DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `preserve` tinyint(3) DEFAULT '0',
  PRIMARY KEY (`site_id`,`db_type`,`db_name`),
  KEY `date` (`next_date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

-- Dump completed on 2017-08-07  2:10:11
