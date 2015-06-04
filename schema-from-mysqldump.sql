-- MySQL dump 10.13  Distrib 5.5.43, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: learningsql
-- ------------------------------------------------------
-- Server version	5.5.43-0ubuntu0.14.04.1

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
-- Table structure for table `account`
--

DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account` (
  `account_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `product_cd` varchar(10) NOT NULL,
  `cust_id` int(10) unsigned NOT NULL,
  `open_date` date NOT NULL,
  `close_date` date DEFAULT NULL,
  `last_activity_date` date DEFAULT NULL,
  `status` enum('ACTIVE','CLOSED','FROZEN') DEFAULT NULL,
  `open_branch_id` smallint(5) unsigned DEFAULT NULL,
  `open_emp_id` smallint(5) unsigned DEFAULT NULL,
  `avail_balance` float(10,2) DEFAULT NULL,
  `pending_balance` float(10,2) DEFAULT NULL,
  PRIMARY KEY (`account_id`),
  KEY `fk_product_cd` (`product_cd`),
  KEY `fk_a_cust_id` (`cust_id`),
  KEY `fk_a_branch_id` (`open_branch_id`),
  KEY `fk_a_emp_id` (`open_emp_id`),
  CONSTRAINT `fk_product_cd` FOREIGN KEY (`product_cd`) REFERENCES `product` (`product_cd`),
  CONSTRAINT `fk_a_cust_id` FOREIGN KEY (`cust_id`) REFERENCES `customer` (`cust_id`),
  CONSTRAINT `fk_a_branch_id` FOREIGN KEY (`open_branch_id`) REFERENCES `branch` (`branch_id`),
  CONSTRAINT `fk_a_emp_id` FOREIGN KEY (`open_emp_id`) REFERENCES `employee` (`emp_id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `branch`
--

DROP TABLE IF EXISTS `branch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branch` (
  `branch_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `address` varchar(30) DEFAULT NULL,
  `city` varchar(20) DEFAULT NULL,
  `state` varchar(2) DEFAULT NULL,
  `zip` varchar(12) DEFAULT NULL,
  PRIMARY KEY (`branch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `business`
--

DROP TABLE IF EXISTS `business`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `business` (
  `cust_id` int(10) unsigned NOT NULL,
  `name` varchar(40) NOT NULL,
  `state_id` varchar(10) NOT NULL,
  `incorp_date` date DEFAULT NULL,
  PRIMARY KEY (`cust_id`),
  CONSTRAINT `fk_b_cust_id` FOREIGN KEY (`cust_id`) REFERENCES `customer` (`cust_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customer` (
  `cust_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fed_id` varchar(12) NOT NULL,
  `cust_type_cd` enum('I','B') NOT NULL,
  `address` varchar(30) DEFAULT NULL,
  `city` varchar(20) DEFAULT NULL,
  `state` varchar(20) DEFAULT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`cust_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `department`
--

DROP TABLE IF EXISTS `department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `department` (
  `dept_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  PRIMARY KEY (`dept_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employee`
--

DROP TABLE IF EXISTS `employee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employee` (
  `emp_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `fname` varchar(20) NOT NULL,
  `lname` varchar(20) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `superior_emp_id` smallint(5) unsigned DEFAULT NULL,
  `dept_id` smallint(5) unsigned DEFAULT NULL,
  `title` varchar(20) DEFAULT NULL,
  `assigned_branch_id` smallint(5) unsigned DEFAULT NULL,
  PRIMARY KEY (`emp_id`),
  KEY `fk_e_emp_id` (`superior_emp_id`),
  KEY `fk_dept_id` (`dept_id`),
  KEY `fk_e_branch_id` (`assigned_branch_id`),
  CONSTRAINT `fk_e_emp_id` FOREIGN KEY (`superior_emp_id`) REFERENCES `employee` (`emp_id`),
  CONSTRAINT `fk_dept_id` FOREIGN KEY (`dept_id`) REFERENCES `department` (`dept_id`),
  CONSTRAINT `fk_e_branch_id` FOREIGN KEY (`assigned_branch_id`) REFERENCES `branch` (`branch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `individual`
--

DROP TABLE IF EXISTS `individual`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `individual` (
  `cust_id` int(10) unsigned NOT NULL,
  `fname` varchar(30) NOT NULL,
  `lname` varchar(30) NOT NULL,
  `birth_date` date DEFAULT NULL,
  PRIMARY KEY (`cust_id`),
  CONSTRAINT `fk_i_cust_id` FOREIGN KEY (`cust_id`) REFERENCES `customer` (`cust_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `officer`
--

DROP TABLE IF EXISTS `officer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `officer` (
  `officer_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `cust_id` int(10) unsigned NOT NULL,
  `fname` varchar(30) NOT NULL,
  `lname` varchar(30) NOT NULL,
  `title` varchar(20) DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  PRIMARY KEY (`officer_id`),
  KEY `fk_o_cust_id` (`cust_id`),
  CONSTRAINT `fk_o_cust_id` FOREIGN KEY (`cust_id`) REFERENCES `business` (`cust_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product` (
  `product_cd` varchar(10) NOT NULL,
  `name` varchar(50) NOT NULL,
  `product_type_cd` varchar(10) NOT NULL,
  `date_offered` date DEFAULT NULL,
  `date_retired` date DEFAULT NULL,
  PRIMARY KEY (`product_cd`),
  KEY `fk_product_type_cd` (`product_type_cd`),
  CONSTRAINT `fk_product_type_cd` FOREIGN KEY (`product_type_cd`) REFERENCES `product_type` (`product_type_cd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `product_type`
--

DROP TABLE IF EXISTS `product_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_type` (
  `product_type_cd` varchar(10) NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`product_type_cd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transaction`
--

DROP TABLE IF EXISTS `transaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transaction` (
  `txn_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `txn_date` datetime NOT NULL,
  `account_id` int(10) unsigned NOT NULL,
  `txn_type_cd` enum('DBT','CDT') DEFAULT NULL,
  `amount` double(10,2) NOT NULL,
  `teller_emp_id` smallint(5) unsigned DEFAULT NULL,
  `execution_branch_id` smallint(5) unsigned DEFAULT NULL,
  `funds_avail_date` datetime DEFAULT NULL,
  PRIMARY KEY (`txn_id`),
  KEY `fk_t_account_id` (`account_id`),
  KEY `fk_teller_emp_id` (`teller_emp_id`),
  KEY `fk_exec_branch_id` (`execution_branch_id`),
  CONSTRAINT `fk_t_account_id` FOREIGN KEY (`account_id`) REFERENCES `account` (`account_id`),
  CONSTRAINT `fk_teller_emp_id` FOREIGN KEY (`teller_emp_id`) REFERENCES `employee` (`emp_id`),
  CONSTRAINT `fk_exec_branch_id` FOREIGN KEY (`execution_branch_id`) REFERENCES `branch` (`branch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-06-04  4:57:02
