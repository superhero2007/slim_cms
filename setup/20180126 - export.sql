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
-- Dumping data for table `plugin`
--

INSERT INTO `plugin` (`plugin_id`, `plugin`) VALUES
(35, 'export');

INSERT INTO `plugin_method` (`plugin_method_id`, `plugin_id`, `method`) VALUES
(131, 35, 'excel');

INSERT INTO `plugin_method_call` (`plugin_method_call_id`, `plugin_method_id`, `navigation_id`, `inherit`, `sequence`, `position`) VALUES
(745, 131, 1007, 0, 0, 0);

INSERT INTO `navigation` (`navigation_id`, `parent_id`, `domain_id`, `template_id`, `sequence`, `secure`, `path`, `label`, `title`, `sitemap_priority`, `sitemap_lastmod`, `sitemap_changefreq`, `meta-title`, `meta-description`, `meta-keywords`, `scope_id`) VALUES
(1007, 943, 97, NULL, 0, 0, 'export', '', 'Export Excel', 0, '0000-00-00', '', '', '', '', 1);


/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
