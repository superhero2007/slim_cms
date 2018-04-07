CREATE DATABASE  IF NOT EXISTS `greenbiz_core` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;
USE `greenbiz_core`;
-- MySQL dump 10.13  Distrib 5.6.17, for osx10.6 (i386)
--
-- Host: 127.0.0.1    Database: greenbiz_core
-- ------------------------------------------------------
-- Server version	5.6.35

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
-- Table structure for table `message_2_message_type`
--

DROP TABLE IF EXISTS `message_2_message_type`;

--
-- Table structure for table `message_2_client_contact`
--

DROP TABLE IF EXISTS `message_2_client_contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `message_2_client_contact` (
  `message_2_client_contact_id` int(11) NOT NULL AUTO_INCREMENT,
  `message_id` int(11) NOT NULL,
  `client_contact_id` int(11) NOT NULL,
  `delivered` BOOL NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_2_client_contact_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `message`
--

DROP TABLE IF EXISTS `message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `message` (
  `message_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `message_type_id` int(11) NOT NULL,
  `message_subject` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `message_content` TEXT COLLATE utf8_unicode_ci NOT NULL,
  `message_sql_query` TEXT COLLATE utf8_unicode_ci,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `message_active` BOOL COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`message_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `message_type`
--

DROP TABLE IF EXISTS `message_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `message_type` (
  `message_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `message_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`message_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_type`
--

INSERT INTO `message_type` (`message_type_id`, `message_type`) VALUES
(1, 'Email'),
(2, 'Triggered Email'),
(3, 'Triggered Notification');


--
-- Dumping data for table `plugin`
--

INSERT INTO `plugin` (`plugin_id`, `plugin`) VALUES
(34, 'messages');

INSERT INTO `plugin_method` (`plugin_method_id`, `plugin_id`, `method`) VALUES
(128, 34, 'index');

INSERT INTO `plugin_method_call` (`plugin_method_call_id`, `plugin_method_id`, `navigation_id`, `inherit`, `sequence`, `position`) VALUES
(742, 128, 1004, 0, 0, 0);

INSERT INTO `navigation` (`navigation_id`, `parent_id`, `domain_id`, `template_id`, `sequence`, `secure`, `path`, `label`, `title`, `sitemap_priority`, `sitemap_lastmod`, `sitemap_changefreq`, `meta-title`, `meta-description`, `meta-keywords`, `scope_id`) VALUES
(942, NULL, 97, 63, 0, 0, '', '', 'David Jones Supplier Portal', 0, '0000-00-00', '', '', '', '', 1),
(943, 942, 97, NULL, 0, 0, 'members', '', 'My Account', 0, '0000-00-00', '', '', '', '', 1),
(1004, 943, 97, NULL, 0, 0, 'messages', '', 'Messages', 0, '0000-00-00', '', '', '', '', 1);


/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
