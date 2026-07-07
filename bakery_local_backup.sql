-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: bakery
-- ------------------------------------------------------
-- Server version	8.0.46

SET FOREIGN_KEY_CHECKS = 0;
DROP DATABASE IF EXISTS bakery;
CREATE DATABASE bakery;
USE bakery;

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
-- Table structure for table `accessory`
--

DROP TABLE IF EXISTS `accessory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accessory` (
  `Accessory_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Accessory_Name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Price` decimal(10,2) NOT NULL,
  `Image_URL` varchar(2083) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`Accessory_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accessory`
--

LOCK TABLES `accessory` WRITE;
/*!40000 ALTER TABLE `accessory` DISABLE KEYS */;
/*!40000 ALTER TABLE `accessory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cake_layer_detail`
--

DROP TABLE IF EXISTS `cake_layer_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cake_layer_detail` (
  `Layer_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Custom_Cake_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Layer_Position` int NOT NULL,
  `Sponge_Ingredient_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`Layer_ID`),
  KEY `FK_Layer_CustomCake` (`Custom_Cake_ID`),
  KEY `FK_Layer_Sponge` (`Sponge_Ingredient_ID`),
  CONSTRAINT `FK_Layer_CustomCake` FOREIGN KEY (`Custom_Cake_ID`) REFERENCES `custom_cake` (`Custom_Cake_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_Layer_Sponge` FOREIGN KEY (`Sponge_Ingredient_ID`) REFERENCES `ingredients` (`Ingredient_ID`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cake_layer_detail`
--

LOCK TABLES `cake_layer_detail` WRITE;
/*!40000 ALTER TABLE `cake_layer_detail` DISABLE KEYS */;
/*!40000 ALTER TABLE `cake_layer_detail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cake_recipe`
--

DROP TABLE IF EXISTS `cake_recipe`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cake_recipe` (
  `Recipe_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Template_ID` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Recipe_Name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Instruction_Steps` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`Recipe_ID`),
  UNIQUE KEY `UK_Recipe_Template` (`Template_ID`),
  CONSTRAINT `FK_Recipe_Template` FOREIGN KEY (`Template_ID`) REFERENCES `cake_template` (`Template_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cake_recipe`
--

LOCK TABLES `cake_recipe` WRITE;
/*!40000 ALTER TABLE `cake_recipe` DISABLE KEYS */;
/*!40000 ALTER TABLE `cake_recipe` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cake_template`
--

DROP TABLE IF EXISTS `cake_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cake_template` (
  `Template_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Category_ID` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Template_Name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Base_Price` decimal(10,2) DEFAULT NULL,
  `Estimated_Labor_Hours` decimal(4,2) NOT NULL,
  `Allows_Greeting` tinyint(1) NOT NULL DEFAULT '1',
  `Image_URL` varchar(2083) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  `Is_Featured` tinyint(1) NOT NULL DEFAULT '0',
  `Full_Description` text COLLATE utf8mb4_unicode_ci,
  `Default_Margin_Percent` decimal(5,2) NOT NULL DEFAULT '10.00',
  `Default_Service_Percent` decimal(5,2) NOT NULL DEFAULT '5.00',
  `Instruction_Steps` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`Template_ID`),
  KEY `FK_CakeTemplate_ProductCategory` (`Category_ID`),
  CONSTRAINT `FK_CakeTemplate_ProductCategory` FOREIGN KEY (`Category_ID`) REFERENCES `product_category` (`Category_ID`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cake_template`
--

LOCK TABLES `cake_template` WRITE;
/*!40000 ALTER TABLE `cake_template` DISABLE KEYS */;
/*!40000 ALTER TABLE `cake_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart_item`
--

DROP TABLE IF EXISTS `cart_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart_item` (
  `Cart_Item_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `User_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Custom_Cake_ID` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Accessory_ID` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Quantity` int NOT NULL DEFAULT '1',
  `Added_At` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Cart_Item_ID`),
  KEY `FK_CartItem_User` (`User_ID`),
  KEY `FK_CartItem_CustomCake` (`Custom_Cake_ID`),
  KEY `FK_CartItem_Accessory` (`Accessory_ID`),
  CONSTRAINT `FK_CartItem_Accessory` FOREIGN KEY (`Accessory_ID`) REFERENCES `accessory` (`Accessory_ID`) ON DELETE CASCADE,
  CONSTRAINT `FK_CartItem_CustomCake` FOREIGN KEY (`Custom_Cake_ID`) REFERENCES `custom_cake` (`Custom_Cake_ID`) ON DELETE CASCADE,
  CONSTRAINT `FK_CartItem_User` FOREIGN KEY (`User_ID`) REFERENCES `user` (`User_ID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_item`
--

LOCK TABLES `cart_item` WRITE;
/*!40000 ALTER TABLE `cart_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `cart_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category_accessory`
--

DROP TABLE IF EXISTS `category_accessory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category_accessory` (
  `Category_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Accessory_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `enable` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`Category_ID`,`Accessory_ID`),
  KEY `FK_CatAcc_Accessory` (`Accessory_ID`),
  CONSTRAINT `FK_CatAcc_Accessory` FOREIGN KEY (`Accessory_ID`) REFERENCES `accessory` (`Accessory_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_CatAcc_Category` FOREIGN KEY (`Category_ID`) REFERENCES `product_category` (`Category_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category_accessory`
--

LOCK TABLES `category_accessory` WRITE;
/*!40000 ALTER TABLE `category_accessory` DISABLE KEYS */;
/*!40000 ALTER TABLE `category_accessory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custom_cake`
--

DROP TABLE IF EXISTS `custom_cake`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `custom_cake` (
  `Custom_Cake_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Template_ID` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Canvas_Image_URL` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `Greeting_Text` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Frosting_Ingredient_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Topping_Ingredient_ID` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Cake_Hash_Structure` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Calculated_Price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`Custom_Cake_ID`),
  KEY `FK_CustomCake_Template` (`Template_ID`),
  KEY `FK_CustomCake_Frosting` (`Frosting_Ingredient_ID`),
  KEY `FK_CustomCake_Topping` (`Topping_Ingredient_ID`),
  CONSTRAINT `FK_CustomCake_Frosting` FOREIGN KEY (`Frosting_Ingredient_ID`) REFERENCES `ingredients` (`Ingredient_ID`) ON UPDATE CASCADE,
  CONSTRAINT `FK_CustomCake_Template` FOREIGN KEY (`Template_ID`) REFERENCES `cake_template` (`Template_ID`) ON UPDATE CASCADE,
  CONSTRAINT `FK_CustomCake_Topping` FOREIGN KEY (`Topping_Ingredient_ID`) REFERENCES `ingredients` (`Ingredient_ID`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custom_cake`
--

LOCK TABLES `custom_cake` WRITE;
/*!40000 ALTER TABLE `custom_cake` DISABLE KEYS */;
/*!40000 ALTER TABLE `custom_cake` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer` (
  `Customer_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `User_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Full_Name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Phone` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Default_Address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Created_At` datetime DEFAULT CURRENT_TIMESTAMP,
  `Is_Active_Customer` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`Customer_ID`),
  UNIQUE KEY `UK_Customer_User` (`User_ID`),
  CONSTRAINT `FK_Customer_User` FOREIGN KEY (`User_ID`) REFERENCES `user` (`User_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_evidence`
--

DROP TABLE IF EXISTS `delivery_evidence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_evidence` (
  `Evidence_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Trip_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Pickup_Photo_URL` varchar(2083) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Delivery_Photo_URL` varchar(2083) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`Evidence_ID`),
  UNIQUE KEY `UK_Evidence_Trip` (`Trip_ID`),
  CONSTRAINT `FK_Evidence_Trip` FOREIGN KEY (`Trip_ID`) REFERENCES `delivery_trip` (`Trip_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_evidence`
--

LOCK TABLES `delivery_evidence` WRITE;
/*!40000 ALTER TABLE `delivery_evidence` DISABLE KEYS */;
/*!40000 ALTER TABLE `delivery_evidence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_trip`
--

DROP TABLE IF EXISTS `delivery_trip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_trip` (
  `Trip_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Shipper_ID` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `OSRM_Distance_Km` decimal(5,2) NOT NULL,
  `OSRM_Duration_Min` int NOT NULL,
  `Calculated_Shipping_Fee` decimal(10,2) NOT NULL,
  PRIMARY KEY (`Trip_ID`),
  KEY `FK_Trip_Shipper` (`Shipper_ID`),
  CONSTRAINT `FK_Trip_Shipper` FOREIGN KEY (`Shipper_ID`) REFERENCES `staff` (`Staff_ID`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_trip`
--

LOCK TABLES `delivery_trip` WRITE;
/*!40000 ALTER TABLE `delivery_trip` DISABLE KEYS */;
/*!40000 ALTER TABLE `delivery_trip` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ingredient_category`
--

DROP TABLE IF EXISTS `ingredient_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ingredient_category` (
  `Category_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Category_Name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enable` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`Category_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ingredient_category`
--

LOCK TABLES `ingredient_category` WRITE;
/*!40000 ALTER TABLE `ingredient_category` DISABLE KEYS */;
/*!40000 ALTER TABLE `ingredient_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ingredients`
--

DROP TABLE IF EXISTS `ingredients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ingredients` (
  `Ingredient_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Ingredient_Name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Category_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Price_Per_Unit` decimal(10,2) NOT NULL,
  PRIMARY KEY (`Ingredient_ID`),
  KEY `FK_Ingredients_Category` (`Category_ID`),
  CONSTRAINT `FK_Ingredients_Category` FOREIGN KEY (`Category_ID`) REFERENCES `ingredient_category` (`Category_ID`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ingredients`
--

LOCK TABLES `ingredients` WRITE;
/*!40000 ALTER TABLE `ingredients` DISABLE KEYS */;
/*!40000 ALTER TABLE `ingredients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_item`
--

DROP TABLE IF EXISTS `order_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_item` (
  `Order_Item_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Order_No` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Custom_Cake_ID` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Accessory_ID` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Quantity` int NOT NULL,
  `Price_At_Purchase` decimal(10,2) NOT NULL,
  PRIMARY KEY (`Order_Item_ID`),
  KEY `FK_OrderItem_Accessory` (`Accessory_ID`),
  KEY `FK_OrderItem_CustomCake` (`Custom_Cake_ID`),
  KEY `FK_OrderItem_Order` (`Order_No`),
  CONSTRAINT `FK_OrderItem_Accessory` FOREIGN KEY (`Accessory_ID`) REFERENCES `accessory` (`Accessory_ID`) ON UPDATE CASCADE,
  CONSTRAINT `FK_OrderItem_CustomCake` FOREIGN KEY (`Custom_Cake_ID`) REFERENCES `custom_cake` (`Custom_Cake_ID`) ON UPDATE CASCADE,
  CONSTRAINT `FK_OrderItem_Order` FOREIGN KEY (`Order_No`) REFERENCES `orders` (`Order_No`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_item`
--

LOCK TABLES `order_item` WRITE;
/*!40000 ALTER TABLE `order_item` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `Order_No` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Customer_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Trip_ID` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Order_Time` datetime NOT NULL,
  `Delivery_Window_Start` datetime NOT NULL,
  `Delivery_Window_End` datetime NOT NULL,
  `Delivery_Address` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Deposit_Amount` decimal(10,2) NOT NULL,
  `Total_Cost` decimal(10,2) NOT NULL,
  `OrderStatus` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`Order_No`),
  KEY `FK_Order_Customer` (`Customer_ID`),
  KEY `FK_Order_Trip` (`Trip_ID`),
  CONSTRAINT `FK_Order_Customer` FOREIGN KEY (`Customer_ID`) REFERENCES `customer` (`Customer_ID`) ON UPDATE CASCADE,
  CONSTRAINT `FK_Order_Trip` FOREIGN KEY (`Trip_ID`) REFERENCES `delivery_trip` (`Trip_ID`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_category`
--

DROP TABLE IF EXISTS `product_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_category` (
  `Category_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Category_Name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Sort_Order` int DEFAULT NULL,
  `Icon_URL` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `enable` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`Category_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_category`
--

LOCK TABLES `product_category` WRITE;
/*!40000 ALTER TABLE `product_category` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_image`
--

DROP TABLE IF EXISTS `product_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_image` (
  `Image_ID` int NOT NULL AUTO_INCREMENT,
  `Product_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Image_URL` varchar(2083) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Is_Cover` tinyint(1) DEFAULT '0',
  `Sort_Order` int DEFAULT '1',
  PRIMARY KEY (`Image_ID`),
  KEY `FK_ProductImage_Template` (`Product_ID`),
  CONSTRAINT `FK_ProductImage_Template` FOREIGN KEY (`Product_ID`) REFERENCES `cake_template` (`Template_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_image`
--

LOCK TABLES `product_image` WRITE;
/*!40000 ALTER TABLE `product_image` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_image` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_review`
--

DROP TABLE IF EXISTS `product_review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_review` (
  `Review_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Custom_Cake_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Customer_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Rating_Stars` int NOT NULL,
  `Comment` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Moderation_Status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`Review_ID`),
  KEY `FK_Review_CustomCake` (`Custom_Cake_ID`),
  KEY `FK_Review_Customer` (`Customer_ID`),
  CONSTRAINT `FK_Review_CustomCake` FOREIGN KEY (`Custom_Cake_ID`) REFERENCES `custom_cake` (`Custom_Cake_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_Review_Customer` FOREIGN KEY (`Customer_ID`) REFERENCES `customer` (`Customer_ID`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_review`
--

LOCK TABLES `product_review` WRITE;
/*!40000 ALTER TABLE `product_review` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_review` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `production_schedule`
--

DROP TABLE IF EXISTS `production_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `production_schedule` (
  `Schedule_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Order_Item_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Staff_ID` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Production_Start_Time` datetime DEFAULT NULL,
  `Estimated_Completion_Time` datetime DEFAULT NULL,
  `Actual_Completion_Time` datetime DEFAULT NULL,
  `Production_Status` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`Schedule_ID`),
  KEY `FK_Schedule_OrderItem` (`Order_Item_ID`),
  KEY `FK_Schedule_Staff` (`Staff_ID`),
  CONSTRAINT `FK_Schedule_OrderItem` FOREIGN KEY (`Order_Item_ID`) REFERENCES `order_item` (`Order_Item_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_Schedule_Staff` FOREIGN KEY (`Staff_ID`) REFERENCES `staff` (`Staff_ID`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `production_schedule`
--

LOCK TABLES `production_schedule` WRITE;
/*!40000 ALTER TABLE `production_schedule` DISABLE KEYS */;
/*!40000 ALTER TABLE `production_schedule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role` (
  `Role_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Role_Name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`Role_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permission`
--

DROP TABLE IF EXISTS `role_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permission` (
  `Role_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Screen_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`Role_ID`,`Screen_ID`),
  KEY `FK_RolePerm_Screen` (`Screen_ID`),
  CONSTRAINT `FK_RolePerm_Role` FOREIGN KEY (`Role_ID`) REFERENCES `role` (`Role_ID`) ON DELETE CASCADE,
  CONSTRAINT `FK_RolePerm_Screen` FOREIGN KEY (`Screen_ID`) REFERENCES `screen_permission` (`Screen_ID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permission`
--

LOCK TABLES `role_permission` WRITE;
/*!40000 ALTER TABLE `role_permission` DISABLE KEYS */;
/*!40000 ALTER TABLE `role_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `screen_permission`
--

DROP TABLE IF EXISTS `screen_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `screen_permission` (
  `Screen_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Screen_Name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Endpoint_URL` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`Screen_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `screen_permission`
--

LOCK TABLES `screen_permission` WRITE;
/*!40000 ALTER TABLE `screen_permission` DISABLE KEYS */;
/*!40000 ALTER TABLE `screen_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `staff`
--

DROP TABLE IF EXISTS `staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff` (
  `Staff_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `User_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Full_Name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Phone` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Position` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Is_Active_Staff` tinyint(1) NOT NULL DEFAULT '1',
  `Created_At` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Staff_ID`),
  UNIQUE KEY `UK_Staff_User` (`User_ID`),
  CONSTRAINT `FK_Staff_User` FOREIGN KEY (`User_ID`) REFERENCES `user` (`User_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `staff`
--

LOCK TABLES `staff` WRITE;
/*!40000 ALTER TABLE `staff` DISABLE KEYS */;
/*!40000 ALTER TABLE `staff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `template_ingredient_detail`
--

DROP TABLE IF EXISTS `template_ingredient_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `template_ingredient_detail` (
  `Detail_ID` int NOT NULL AUTO_INCREMENT,
  `Template_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Ingredient_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Standard_Gram` decimal(6,2) NOT NULL DEFAULT '100.00',
  PRIMARY KEY (`Detail_ID`),
  KEY `FK_TemplateDetail_Template` (`Template_ID`),
  KEY `FK_TemplateDetail_Ingredient` (`Ingredient_ID`),
  CONSTRAINT `FK_TemplateDetail_Ingredient` FOREIGN KEY (`Ingredient_ID`) REFERENCES `ingredients` (`Ingredient_ID`) ON UPDATE CASCADE,
  CONSTRAINT `FK_TemplateDetail_Template` FOREIGN KEY (`Template_ID`) REFERENCES `cake_template` (`Template_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `template_ingredient_detail`
--

LOCK TABLES `template_ingredient_detail` WRITE;
/*!40000 ALTER TABLE `template_ingredient_detail` DISABLE KEYS */;
/*!40000 ALTER TABLE `template_ingredient_detail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `User_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Password` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Role_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Is_Verified` tinyint(1) NOT NULL DEFAULT '0',
  `OTP_Code` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `OTP_Expiry` datetime DEFAULT NULL,
  `Provider` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'LOCAL',
  `Provider_ID` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Created_At` datetime DEFAULT CURRENT_TIMESTAMP,
  `Account_Status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`User_ID`),
  UNIQUE KEY `UK_User_Email` (`Email`),
  KEY `IDX_User_Provider` (`Provider`,`Provider_ID`),
  KEY `FK_User_Role` (`Role_ID`),
  CONSTRAINT `FK_User_Role` FOREIGN KEY (`Role_ID`) REFERENCES `role` (`Role_ID`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-18 13:29:05
-- ===========================================================================
-- DATA INTEGRATION SCRIPT FOR BAKERY MANAGEMENT SYSTEM (SEPARATED PROFILE SCHEMA)
-- Aligned with the 'bakery' database where Full_Name and Phone are in customer/staff
-- ===========================================================================

USE `bakery`;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE `product_review`;
TRUNCATE TABLE `delivery_evidence`;
TRUNCATE TABLE `production_schedule`;
TRUNCATE TABLE `order_item`;
TRUNCATE TABLE `orders`;
TRUNCATE TABLE `delivery_trip`;
TRUNCATE TABLE `cake_layer_detail`;
TRUNCATE TABLE `custom_cake`;
TRUNCATE TABLE `template_ingredient_detail`;
TRUNCATE TABLE `cake_recipe`;
TRUNCATE TABLE `category_accessory`;
TRUNCATE TABLE `accessory`;
TRUNCATE TABLE `product_image`;
TRUNCATE TABLE `cake_template`;
TRUNCATE TABLE `ingredients`;
TRUNCATE TABLE `ingredient_category`;
TRUNCATE TABLE `product_category`;
TRUNCATE TABLE `customer`;
TRUNCATE TABLE `staff`;
TRUNCATE TABLE `user`;
TRUNCATE TABLE `role_permission`;
TRUNCATE TABLE `screen_permission`;
TRUNCATE TABLE `role`;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================
-- IAM & SECURITY
-- =========================================================

INSERT INTO `role` (`Role_ID`, `Role_Name`) VALUES
('ADMIN', 'Quản trị viên'),
('CUSTOMER', 'Khách hàng'),
('STAFF', 'Nhân viên làm bánh'),
('SHIPPER', 'Nhân viên giao hàng');

INSERT INTO `screen_permission` (`Screen_ID`, `Screen_Name`, `Endpoint_URL`) VALUES
('SCR_HOME', 'Trang chủ', '/home'),
('SCR_PRODUCT', 'Quản lý sản phẩm', '/admin/products'),
('SCR_CATEGORY', 'Quản lý danh mục', '/admin/categories'),
('SCR_ORDER', 'Quản lý đơn hàng', '/admin/orders'),
('SCR_DELIVERY', 'Quản lý giao hàng', '/shipper/orders'),
('SCR_USER', 'Quản lý người dùng', '/admin/users'),
('SCR_CUSTOMER', 'Quản lý khách hàng', '/admin/customers'),
('SCR_REVIEW', 'Quản lý đánh giá', '/admin/reviews'),
('SCR_DASHBOARD', 'Thống kê', '/admin/dashboard');

INSERT INTO `role_permission` (`Role_ID`, `Screen_ID`) VALUES
('ADMIN', 'SCR_HOME'), ('ADMIN', 'SCR_PRODUCT'), ('ADMIN', 'SCR_CATEGORY'),
('ADMIN', 'SCR_ORDER'), ('ADMIN', 'SCR_DELIVERY'), ('ADMIN', 'SCR_USER'),
('ADMIN', 'SCR_CUSTOMER'), ('ADMIN', 'SCR_REVIEW'), ('ADMIN', 'SCR_DASHBOARD'),
('STAFF', 'SCR_HOME'), ('STAFF', 'SCR_PRODUCT'), ('STAFF', 'SCR_CATEGORY'), ('STAFF', 'SCR_ORDER'),
('SHIPPER', 'SCR_HOME'), ('SHIPPER', 'SCR_DELIVERY'),
('CUSTOMER', 'SCR_HOME');

-- =========================================================
-- USERS, CUSTOMERS & STAFF
-- =========================================================

INSERT INTO `user` (`User_ID`, `Email`, `Password`, `Role_ID`, `Is_Verified`, `Account_Status`, `Created_At`) VALUES
('ADMIN_0001', 'admin@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'ADMIN', 1, 'Active', NOW()),
('ADMIN_0002', 'admin2@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'ADMIN', 1, 'Active', NOW()),
('STAFF_0001', 'staff1@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'STAFF', 1, 'Active', NOW()),
('STAFF_0002', 'staff2@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'STAFF', 1, 'Active', NOW()),
('STAFF_0003', 'staff3@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'STAFF', 1, 'Active', NOW()),
('SHIP_0001', 'shipper1@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'SHIPPER', 1, 'Active', NOW()),
('SHIP_0002', 'shipper2@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'SHIPPER', 1, 'Active', NOW()),
('CUS_0001', 'customer1@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0002', 'customer2@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0003', 'customer3@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0004', 'customer4@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0005', 'customer5@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0006', 'customer6@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0007', 'customer7@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0008', 'customer8@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 0, 'Active', NOW());

INSERT INTO `customer` (`Customer_ID`, `User_ID`, `Full_Name`, `Phone`, `Default_Address`, `Created_At`) VALUES
('CUS_0001', 'CUS_0001', 'Nguyễn Minh Anh', '0901000001', '12 Nguyễn Trãi, Hà Nội', NOW()),
('CUS_0002', 'CUS_0002', 'Trần Hoàng Nam', '0901000002', '25 Lê Lợi, Hà Nội', NOW()),
('CUS_0003', 'CUS_0003', 'Phạm Thu Hà', '0901000003', '48 Kim Mã, Hà Nội', NOW()),
('CUS_0004', 'CUS_0004', 'Lê Bảo Ngọc', '0901000004', '88 Cầu Giấy, Hà Nội', NOW()),
('CUS_0005', 'CUS_0005', 'Đỗ Quang Huy', '0901000005', '19 Hai Bà Trưng, Hà Nội', NOW()),
('CUS_0006', 'CUS_0006', 'Vũ Lan Anh', '0901000006', '36 Đội Cấn, Hà Nội', NOW()),
('CUS_0007', 'CUS_0007', 'Ngô Đức Trí', '0901000007', '72 Trần Duy Hưng, Hà Nội', NOW()),
('CUS_0008', 'CUS_0008', 'Khách Chưa Xác Thực', '0901000008', '10 Phạm Văn Đồng, Hà Nội', NOW());

INSERT INTO `staff` (`Staff_ID`, `User_ID`, `Full_Name`, `Phone`, `Position`, `Is_Active_Staff`, `Created_At`) VALUES
('ADMIN_0001', 'ADMIN_0001', 'Admin', '0910000001', 'Quản trị viên', 1, NOW()),
('ADMIN_0002', 'ADMIN_0002', 'Admin Phụ', '0910000002', 'Quản trị viên', 1, NOW()),
('STAFF_0001', 'STAFF_0001', 'Nguyễn Nhân Viên Một', '0910000003', 'Nhân viên làm bánh', 1, NOW()),
('STAFF_0002', 'STAFF_0002', 'Trần Nhân Viên Hai', '0910000004', 'Nhân viên làm bánh', 1, NOW()),
('STAFF_0003', 'STAFF_0003', 'Phạm Nhân Viên Ba', '0910000005', 'Nhân viên đóng gói', 1, NOW()),
('SHIP_0001', 'SHIP_0001', 'Lê Shipper Một', '0910000006', 'Nhân viên giao hàng', 1, NOW()),
('SHIP_0002', 'SHIP_0002', 'Đỗ Shipper Hai', '0910000007', 'Nhân viên giao hàng', 1, NOW());

-- =========================================================
-- PRODUCTS & INGREDIENTS
-- =========================================================

INSERT INTO `product_category` (`Category_ID`, `Category_Name`, `Description`, `Sort_Order`, `Icon_URL`) VALUES
('CAT_FLAN', 'Bánh Flan Gato', 'Bánh flan gato mềm mịn, béo nhẹ, phù hợp sinh nhật và tiệc gia đình.', 1, 'assets/images/categories/icons/flan-gato.png'),
('CAT_MOUSSE', 'Bánh Mousse', 'Bánh mousse mát lạnh, vị trái cây hoặc chocolate.', 2, 'assets/images/categories/icons/banh-mousse.png'),
('CAT_CREAM', 'Bánh Kem', 'Bánh kem sinh nhật, bánh kem bắp, bánh kem trang trí.', 3, 'assets/images/categories/icons/kem-bap.png'),
('CAT_BAKED', 'Bánh Nướng', 'Croissant, pain au chocolat và các loại bánh nướng bơ.', 4, 'assets/images/categories/icons/banh-my.png'),
('CAT_PREMIUM', 'Sweetbox Premium', 'Hộp bánh cao cấp dùng làm quà tặng hoặc tiệc sang trọng.', 5, 'assets/images/categories/icons/sweetbox-premium.png'),
('CAT_SWEETIN', 'Sweetin Tiramisu', 'Các dòng tiramisu mềm mịn, vị cà phê hoặc matcha.', 6, 'assets/images/categories/icons/sweetin.png'),
('CAT_ENTREMET', 'Entremet', 'Bánh entremet nhiều lớp, thiết kế hiện đại.', 7, 'assets/images/categories/icons/entremet.png'),
('CAT_HEALTHY', 'Bánh Healthy', 'Bánh ít ngọt, nhẹ vị, phù hợp khách thích lựa chọn cân bằng.', 8, 'assets/images/categories/icons/healthy.png'),
('CAT_COMBO', 'Combo Mini Cake', 'Combo bánh mini nhiều vị, phù hợp dùng thử và tiệc nhỏ.', 9, 'assets/images/categories/icons/combo.png'),
('CAT_SIGNATURE', 'Signature Cake', 'Các mẫu bánh đặc trưng của Bakery Zone.', 10, 'assets/images/categories/icons/signature-cake.png');

INSERT INTO `ingredient_category` (`Category_ID`, `Category_Name`) VALUES
('ICAT_FLOUR', 'Bột'), ('ICAT_SUGAR', 'Đường'), ('ICAT_DAIRY', 'Sữa và kem'), ('ICAT_FRUIT', 'Trái cây'),
('ICAT_TOPPING', 'Topping'), ('ICAT_CHOCOLATE', 'Socola'), ('ICAT_TEA', 'Trà và cà phê'), ('ICAT_NUT', 'Hạt và ngũ cốc');

INSERT INTO `ingredients` (`Ingredient_ID`, `Ingredient_Name`, `Category_ID`, `Price_Per_Unit`) VALUES
('ING_FLOUR', 'Bột mì', 'ICAT_FLOUR', 250), ('ING_CAKE_FLOUR', 'Bột bánh bông lan', 'ICAT_FLOUR', 320),
('ING_SUGAR', 'Đường', 'ICAT_SUGAR', 150), ('ING_CARAMEL', 'Caramel', 'ICAT_SUGAR', 500),
('ING_CREAM', 'Whipping cream', 'ICAT_DAIRY', 1200), ('ING_MASCARPONE', 'Mascarpone', 'ICAT_DAIRY', 2600),
('ING_MILK', 'Sữa tươi', 'ICAT_DAIRY', 450), ('ING_BUTTER', 'Bơ lạt', 'ICAT_DAIRY', 2200),
('ING_STRAWBERRY', 'Dâu tây', 'ICAT_FRUIT', 1800), ('ING_BLUEBERRY', 'Việt quất', 'ICAT_FRUIT', 2400),
('ING_PASSION', 'Chanh dây', 'ICAT_FRUIT', 1500), ('ING_CORN', 'Bắp ngọt', 'ICAT_FRUIT', 700),
('ING_CHOCOLATE', 'Socola', 'ICAT_CHOCOLATE', 1600), ('ING_COCOA', 'Bột cacao', 'ICAT_CHOCOLATE', 900),
('ING_MATCHA', 'Bột matcha', 'ICAT_TEA', 1900), ('ING_COFFEE', 'Cà phê', 'ICAT_TEA', 800),
('ING_OAT', 'Yến mạch', 'ICAT_NUT', 650), ('ING_ALMOND', 'Hạnh nhân', 'ICAT_NUT', 2100);

INSERT INTO `cake_template` (`Template_ID`, `Category_ID`, `Template_Name`, `Base_Price`, `Estimated_Labor_Hours`, `Allows_Greeting`, `Image_URL`, `Status`, `Is_Featured`, `Full_Description`) VALUES
('TPL_0001', 'CAT_FLAN', 'Flan Gato Dâu', 350000, 2.00, 1, 'assets/images/cakeproducts/flan1.png', 'Active', 1, 'Bánh flan gato dâu mềm mịn, vị dâu thơm nhẹ, phù hợp sinh nhật.'),
('TPL_0002', 'CAT_FLAN', 'Flan Gato Truyền Thống', 330000, 2.00, 1, 'assets/images/cakeproducts/flan2.jpg', 'Active', 0, 'Bánh flan gato truyền thống với lớp caramel thơm và cốt bánh mềm.'),
('TPL_0003', 'CAT_FLAN', 'Flan Gato Socola', 360000, 2.10, 1, 'assets/images/cakeproducts/flan3.jpg', 'Active', 0, 'Bánh flan gato socola đậm vị, mềm mịn và dễ ăn.'),
('TPL_0004', 'CAT_FLAN', 'Flan Gato Matcha', 370000, 2.20, 1, 'assets/images/cakeproducts/flan4.jpg', 'Active', 1, 'Bánh flan gato matcha thanh nhẹ, hợp khách thích trà xanh.'),
('TPL_0005', 'CAT_MOUSSE', 'Mousse Dâu Tây', 380000, 1.50, 1, 'assets/images/cakeproducts/mousse1.jpg', 'Active', 1, 'Bánh mousse dâu tươi mát lạnh, vị chua ngọt cân bằng.'),
('TPL_0006', 'CAT_MOUSSE', 'Mousse Chanh Dây', 390000, 1.70, 1, 'assets/images/cakeproducts/mousse2.jpg', 'Active', 0, 'Bánh mousse chanh dây mát lạnh, phù hợp tiệc nhẹ.'),
('TPL_0007', 'CAT_MOUSSE', 'Mousse Việt Quất', 410000, 1.80, 1, 'assets/images/cakeproducts/mousse3.jpg', 'Active', 0, 'Bánh mousse việt quất mềm mịn, hương trái cây nổi bật.'),
('TPL_0008', 'CAT_MOUSSE', 'Mousse Chocolate', 430000, 1.80, 1, 'assets/images/cakeproducts/mousse4.jpg', 'Active', 1, 'Bánh mousse chocolate thơm béo, phù hợp khách thích socola.'),
('TPL_0009', 'CAT_CREAM', 'Bánh Kem Bắp', 420000, 2.50, 1, 'assets/images/cakeproducts/bap1.jpg', 'Active', 1, 'Bánh kem bắp truyền thống, kem mềm và bắp ngọt.'),
('TPL_0010', 'CAT_CREAM', 'Bánh Kem Bắp Đặc Biệt', 450000, 2.50, 1, 'assets/images/cakeproducts/bap2.jpg', 'Active', 0, 'Bánh kem bắp đặc biệt, trang trí đẹp và vị ngọt nhẹ.'),
('TPL_0011', 'CAT_BAKED', 'Croissant Bơ', 45000, 1.00, 0, 'assets/images/cakeproducts/plain-croissant.jpg', 'Active', 0, 'Croissant bơ kiểu Pháp, vỏ giòn thơm bơ.'),
('TPL_0012', 'CAT_BAKED', 'Pain Au Chocolat', 55000, 1.00, 0, 'assets/images/cakeproducts/pain-au-choco.jpg', 'Active', 0, 'Bánh nướng kiểu Pháp nhân socola, vỏ giòn thơm.'),
('TPL_0013', 'CAT_PREMIUM', 'Sweetbox Garden', 650000, 2.00, 1, 'assets/images/cakeproducts/sweetbox1.jpg', 'Active', 1, 'Hộp bánh cao cấp nhiều vị, phù hợp làm quà tặng.'),
('TPL_0014', 'CAT_PREMIUM', 'Sweetbox Premium Mix', 720000, 2.30, 1, 'assets/images/cakeproducts/sweetbox2.jpg', 'Active', 0, 'Hộp bánh premium nhiều vị, trình bày tinh tế.'),
('TPL_0015', 'CAT_PREMIUM', 'Sweetbox Signature 16 Vị', 790000, 2.50, 1, 'assets/images/cakeproducts/sweetbox-signature-hong-16.jpg', 'Active', 1, 'Hộp bánh signature tone hồng gồm 16 vị nhỏ.'),
('TPL_0016', 'CAT_PREMIUM', 'Sweetbox Signature 12 Vị', 690000, 2.20, 1, 'assets/images/cakeproducts/sweetbox-signature-xanh-12.jpg', 'Active', 0, 'Hộp bánh signature tone xanh gồm 12 vị nhỏ.'),
('TPL_0017', 'CAT_SWEETIN', 'Sweetin Matcha Tiramisu', 460000, 1.80, 1, 'assets/images/cakeproducts/sweetin-matcha-tiramisu.jpg', 'Active', 1, 'Tiramisu matcha vị trà xanh dịu nhẹ, lớp kem mềm.'),
('TPL_0018', 'CAT_SWEETIN', 'Sweetin Tiramisu Classic', 440000, 1.80, 1, 'assets/images/cakeproducts/sweetin-tiramisu-classic.jpg', 'Active', 0, 'Tiramisu truyền thống vị cà phê nhẹ, kem béo và cốt mềm.'),
('TPL_0019', 'CAT_ENTREMET', 'Entremet Sakura', 520000, 2.80, 1, 'assets/images/cakeproducts/entremet-sakura.png', 'Active', 1, 'Entremet sakura nhiều lớp, thiết kế tinh tế.'),
('TPL_0020', 'CAT_ENTREMET', 'Entremet Letter Cake', 540000, 3.00, 1, 'assets/images/cakeproducts/entremet-letter.jpg', 'Active', 0, 'Entremet dạng chữ, phù hợp sinh nhật và kỷ niệm.'),
('TPL_0021', 'CAT_HEALTHY', 'Healthy Cake Yến Mạch', 320000, 1.50, 1, 'assets/images/cakeproducts/healthy1.jpg', 'Active', 0, 'Bánh healthy yến mạch, ít ngọt và vị nhẹ.'),
('TPL_0022', 'CAT_HEALTHY', 'Healthy Cake Trái Cây', 350000, 1.60, 1, 'assets/images/cakeproducts/healthy2.jpg', 'Active', 0, 'Bánh healthy kết hợp trái cây, vị thanh nhẹ.'),
('TPL_0023', 'CAT_COMBO', 'Combo Mini Cake 6 Vị', 520000, 2.00, 1, 'assets/images/cakeproducts/combo1.jpg', 'Active', 1, 'Combo bánh mini gồm 6 vị khác nhau, phù hợp tiệc nhỏ.'),
('TPL_0024', 'CAT_COMBO', 'Combo Mini Cake 9 Vị', 640000, 2.30, 1, 'assets/images/cakeproducts/combo2.jpg', 'Active', 0, 'Combo bánh mini gồm 9 vị, trình bày đẹp mắt.');

INSERT INTO `product_image` (`Product_ID`, `Image_URL`, `Is_Cover`, `Sort_Order`) VALUES
('TPL_0001', 'assets/images/cakeproducts/flan1.png', 1, 1), ('TPL_0002', 'assets/images/cakeproducts/flan2.jpg', 1, 1),
('TPL_0003', 'assets/images/cakeproducts/flan3.jpg', 1, 1), ('TPL_0004', 'assets/images/cakeproducts/flan4.jpg', 1, 1),
('TPL_0005', 'assets/images/cakeproducts/mousse1.jpg', 1, 1), ('TPL_0006', 'assets/images/cakeproducts/mousse2.jpg', 1, 1),
('TPL_0007', 'assets/images/cakeproducts/mousse3.jpg', 1, 1), ('TPL_0008', 'assets/images/cakeproducts/mousse4.jpg', 1, 1),
('TPL_0009', 'assets/images/cakeproducts/bap1.jpg', 1, 1), ('TPL_0010', 'assets/images/cakeproducts/bap2.jpg', 1, 1),
('TPL_0011', 'assets/images/cakeproducts/plain-croissant.jpg', 1, 1), ('TPL_0012', 'assets/images/cakeproducts/pain-au-choco.jpg', 1, 1),
('TPL_0013', 'assets/images/cakeproducts/sweetbox1.jpg', 1, 1), ('TPL_0014', 'assets/images/cakeproducts/sweetbox2.jpg', 1, 1),
('TPL_0015', 'assets/images/cakeproducts/sweetbox-signature-hong-16.jpg', 1, 1), ('TPL_0016', 'assets/images/cakeproducts/sweetbox-signature-xanh-12.jpg', 1, 1),
('TPL_0017', 'assets/images/cakeproducts/sweetin-matcha-tiramisu.jpg', 1, 1), ('TPL_0018', 'assets/images/cakeproducts/sweetin-tiramisu-classic.jpg', 1, 1),
('TPL_0019', 'assets/images/cakeproducts/entremet-sakura.png', 1, 1), ('TPL_0020', 'assets/images/cakeproducts/entremet-letter.jpg', 1, 1),
('TPL_0021', 'assets/images/cakeproducts/healthy1.jpg', 1, 1), ('TPL_0022', 'assets/images/cakeproducts/healthy2.jpg', 1, 1),
('TPL_0023', 'assets/images/cakeproducts/combo1.jpg', 1, 1), ('TPL_0024', 'assets/images/cakeproducts/combo2.jpg', 1, 1);

INSERT INTO `accessory` (`Accessory_ID`, `Accessory_Name`, `Price`, `Image_URL`, `Status`) VALUES
('ACC_0001', 'Nến sinh nhật', 10000, 'assets/images/accessories/candle.jpg', 'Active'),
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-18 13:29:05
-- ===========================================================================
-- DATA INTEGRATION SCRIPT FOR BAKERY MANAGEMENT SYSTEM (SEPARATED PROFILE SCHEMA)
-- Aligned with the 'bakery' database where Full_Name and Phone are in customer/staff
-- ===========================================================================

USE `bakery`;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE `product_review`;
TRUNCATE TABLE `delivery_evidence`;
TRUNCATE TABLE `production_schedule`;
TRUNCATE TABLE `order_item`;
TRUNCATE TABLE `orders`;
TRUNCATE TABLE `delivery_trip`;
TRUNCATE TABLE `cake_layer_detail`;
TRUNCATE TABLE `custom_cake`;
TRUNCATE TABLE `template_ingredient_detail`;
TRUNCATE TABLE `cake_recipe`;
TRUNCATE TABLE `category_accessory`;
TRUNCATE TABLE `accessory`;
TRUNCATE TABLE `product_image`;
TRUNCATE TABLE `cake_template`;
TRUNCATE TABLE `ingredients`;
TRUNCATE TABLE `ingredient_category`;
TRUNCATE TABLE `product_category`;
TRUNCATE TABLE `customer`;
TRUNCATE TABLE `staff`;
TRUNCATE TABLE `user`;
TRUNCATE TABLE `role_permission`;
TRUNCATE TABLE `screen_permission`;
TRUNCATE TABLE `role`;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================
-- IAM & SECURITY
-- =========================================================

INSERT INTO `role` (`Role_ID`, `Role_Name`) VALUES
('ADMIN', 'Quản trị viên'),
('CUSTOMER', 'Khách hàng'),
('STAFF', 'Nhân viên làm bánh'),
('SHIPPER', 'Nhân viên giao hàng');

INSERT INTO `screen_permission` (`Screen_ID`, `Screen_Name`, `Endpoint_URL`) VALUES
('SCR_HOME', 'Trang chủ', '/home'),
('SCR_PRODUCT', 'Quản lý sản phẩm', '/admin/products'),
('SCR_CATEGORY', 'Quản lý danh mục', '/admin/categories'),
('SCR_ORDER', 'Quản lý đơn hàng', '/admin/orders'),
('SCR_DELIVERY', 'Quản lý giao hàng', '/shipper/orders'),
('SCR_USER', 'Quản lý người dùng', '/admin/users'),
('SCR_CUSTOMER', 'Quản lý khách hàng', '/admin/customers'),
('SCR_REVIEW', 'Quản lý đánh giá', '/admin/reviews'),
('SCR_DASHBOARD', 'Thống kê', '/admin/dashboard');

INSERT INTO `role_permission` (`Role_ID`, `Screen_ID`) VALUES
('ADMIN', 'SCR_HOME'), ('ADMIN', 'SCR_PRODUCT'), ('ADMIN', 'SCR_CATEGORY'),
('ADMIN', 'SCR_ORDER'), ('ADMIN', 'SCR_DELIVERY'), ('ADMIN', 'SCR_USER'),
('ADMIN', 'SCR_CUSTOMER'), ('ADMIN', 'SCR_REVIEW'), ('ADMIN', 'SCR_DASHBOARD'),
('STAFF', 'SCR_HOME'), ('STAFF', 'SCR_PRODUCT'), ('STAFF', 'SCR_CATEGORY'), ('STAFF', 'SCR_ORDER'),
('SHIPPER', 'SCR_HOME'), ('SHIPPER', 'SCR_DELIVERY'),
('CUSTOMER', 'SCR_HOME');

-- =========================================================
-- USERS, CUSTOMERS & STAFF
-- =========================================================

INSERT INTO `user` (`User_ID`, `Email`, `Password`, `Role_ID`, `Is_Verified`, `Account_Status`, `Created_At`) VALUES
('ADMIN_0001', 'admin@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'ADMIN', 1, 'Active', NOW()),
('ADMIN_0002', 'admin2@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'ADMIN', 1, 'Active', NOW()),
('STAFF_0001', 'staff1@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'STAFF', 1, 'Active', NOW()),
('STAFF_0002', 'staff2@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'STAFF', 1, 'Active', NOW()),
('STAFF_0003', 'staff3@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'STAFF', 1, 'Active', NOW()),
('SHIP_0001', 'shipper1@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'SHIPPER', 1, 'Active', NOW()),
('SHIP_0002', 'shipper2@bakery.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'SHIPPER', 1, 'Active', NOW()),
('CUS_0001', 'customer1@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0002', 'customer2@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0003', 'customer3@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0004', 'customer4@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0005', 'customer5@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0006', 'customer6@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0007', 'customer7@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 1, 'Active', NOW()),
('CUS_0008', 'customer8@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'CUSTOMER', 0, 'Active', NOW());

INSERT INTO `customer` (`Customer_ID`, `User_ID`, `Full_Name`, `Phone`, `Default_Address`, `Created_At`) VALUES
('CUS_0001', 'CUS_0001', 'Nguyễn Minh Anh', '0901000001', '12 Nguyễn Trãi, Hà Nội', NOW()),
('CUS_0002', 'CUS_0002', 'Trần Hoàng Nam', '0901000002', '25 Lê Lợi, Hà Nội', NOW()),
('CUS_0003', 'CUS_0003', 'Phạm Thu Hà', '0901000003', '48 Kim Mã, Hà Nội', NOW()),
('CUS_0004', 'CUS_0004', 'Lê Bảo Ngọc', '0901000004', '88 Cầu Giấy, Hà Nội', NOW()),
('CUS_0005', 'CUS_0005', 'Đỗ Quang Huy', '0901000005', '19 Hai Bà Trưng, Hà Nội', NOW()),
('CUS_0006', 'CUS_0006', 'Vũ Lan Anh', '0901000006', '36 Đội Cấn, Hà Nội', NOW()),
('CUS_0007', 'CUS_0007', 'Ngô Đức Trí', '0901000007', '72 Trần Duy Hưng, Hà Nội', NOW()),
('CUS_0008', 'CUS_0008', 'Khách Chưa Xác Thực', '0901000008', '10 Phạm Văn Đồng, Hà Nội', NOW());

INSERT INTO `staff` (`Staff_ID`, `User_ID`, `Full_Name`, `Phone`, `Position`, `Is_Active_Staff`, `Created_At`) VALUES
('ADMIN_0001', 'ADMIN_0001', 'Admin', '0910000001', 'Quản trị viên', 1, NOW()),
('ADMIN_0002', 'ADMIN_0002', 'Admin Phụ', '0910000002', 'Quản trị viên', 1, NOW()),
('STAFF_0001', 'STAFF_0001', 'Nguyễn Nhân Viên Một', '0910000003', 'Nhân viên làm bánh', 1, NOW()),
('STAFF_0002', 'STAFF_0002', 'Trần Nhân Viên Hai', '0910000004', 'Nhân viên làm bánh', 1, NOW()),
('STAFF_0003', 'STAFF_0003', 'Phạm Nhân Viên Ba', '0910000005', 'Nhân viên đóng gói', 1, NOW()),
('SHIP_0001', 'SHIP_0001', 'Lê Shipper Một', '0910000006', 'Nhân viên giao hàng', 1, NOW()),
('SHIP_0002', 'SHIP_0002', 'Đỗ Shipper Hai', '0910000007', 'Nhân viên giao hàng', 1, NOW());

-- =========================================================
-- PRODUCTS & INGREDIENTS
-- =========================================================

INSERT INTO `product_category` (`Category_ID`, `Category_Name`, `Description`, `Sort_Order`, `Icon_URL`) VALUES
('CAT_FLAN', 'Bánh Flan Gato', 'Bánh flan gato mềm mịn, béo nhẹ, phù hợp sinh nhật và tiệc gia đình.', 1, 'assets/images/categories/icons/flan-gato.png'),
('CAT_MOUSSE', 'Bánh Mousse', 'Bánh mousse mát lạnh, vị trái cây hoặc chocolate.', 2, 'assets/images/categories/icons/banh-mousse.png'),
('CAT_CREAM', 'Bánh Kem', 'Bánh kem sinh nhật, bánh kem bắp, bánh kem trang trí.', 3, 'assets/images/categories/icons/kem-bap.png'),
('CAT_BAKED', 'Bánh Nướng', 'Croissant, pain au chocolat và các loại bánh nướng bơ.', 4, 'assets/images/categories/icons/banh-my.png'),
('CAT_PREMIUM', 'Sweetbox Premium', 'Hộp bánh cao cấp dùng làm quà tặng hoặc tiệc sang trọng.', 5, 'assets/images/categories/icons/sweetbox-premium.png'),
('CAT_SWEETIN', 'Sweetin Tiramisu', 'Các dòng tiramisu mềm mịn, vị cà phê hoặc matcha.', 6, 'assets/images/categories/icons/sweetin.png'),
('CAT_ENTREMET', 'Entremet', 'Bánh entremet nhiều lớp, thiết kế hiện đại.', 7, 'assets/images/categories/icons/entremet.png'),
('CAT_HEALTHY', 'Bánh Healthy', 'Bánh ít ngọt, nhẹ vị, phù hợp khách thích lựa chọn cân bằng.', 8, 'assets/images/categories/icons/healthy.png'),
('CAT_COMBO', 'Combo Mini Cake', 'Combo bánh mini nhiều vị, phù hợp dùng thử và tiệc nhỏ.', 9, 'assets/images/categories/icons/combo.png'),
('CAT_SIGNATURE', 'Signature Cake', 'Các mẫu bánh đặc trưng của Bakery Zone.', 10, 'assets/images/categories/icons/signature-cake.png');

INSERT INTO `ingredient_category` (`Category_ID`, `Category_Name`) VALUES
('ICAT_FLOUR', 'Bột'), ('ICAT_SUGAR', 'Đường'), ('ICAT_DAIRY', 'Sữa và kem'), ('ICAT_FRUIT', 'Trái cây'),
('ICAT_TOPPING', 'Topping'), ('ICAT_CHOCOLATE', 'Socola'), ('ICAT_TEA', 'Trà và cà phê'), ('ICAT_NUT', 'Hạt và ngũ cốc');

INSERT INTO `ingredients` (`Ingredient_ID`, `Ingredient_Name`, `Category_ID`, `Price_Per_Unit`) VALUES
('ING_FLOUR', 'Bột mì', 'ICAT_FLOUR', 250), ('ING_CAKE_FLOUR', 'Bột bánh bông lan', 'ICAT_FLOUR', 320),
('ING_SUGAR', 'Đường', 'ICAT_SUGAR', 150), ('ING_CARAMEL', 'Caramel', 'ICAT_SUGAR', 500),
('ING_CREAM', 'Whipping cream', 'ICAT_DAIRY', 1200), ('ING_MASCARPONE', 'Mascarpone', 'ICAT_DAIRY', 2600),
('ING_MILK', 'Sữa tươi', 'ICAT_DAIRY', 450), ('ING_BUTTER', 'Bơ lạt', 'ICAT_DAIRY', 2200),
('ING_STRAWBERRY', 'Dâu tây', 'ICAT_FRUIT', 1800), ('ING_BLUEBERRY', 'Việt quất', 'ICAT_FRUIT', 2400),
('ING_PASSION', 'Chanh dây', 'ICAT_FRUIT', 1500), ('ING_CORN', 'Bắp ngọt', 'ICAT_FRUIT', 700),
('ING_CHOCOLATE', 'Socola', 'ICAT_CHOCOLATE', 1600), ('ING_COCOA', 'Bột cacao', 'ICAT_CHOCOLATE', 900),
('ING_MATCHA', 'Bột matcha', 'ICAT_TEA', 1900), ('ING_COFFEE', 'Cà phê', 'ICAT_TEA', 800),
('ING_OAT', 'Yến mạch', 'ICAT_NUT', 650), ('ING_ALMOND', 'Hạnh nhân', 'ICAT_NUT', 2100);

INSERT INTO `cake_template` (`Template_ID`, `Category_ID`, `Template_Name`, `Base_Price`, `Estimated_Labor_Hours`, `Allows_Greeting`, `Image_URL`, `Status`, `Is_Featured`, `Full_Description`) VALUES
('TPL_0001', 'CAT_FLAN', 'Flan Gato Dâu', 350000, 2.00, 1, 'assets/images/cakeproducts/flan1.png', 'Active', 1, 'Bánh flan gato dâu mềm mịn, vị dâu thơm nhẹ, phù hợp sinh nhật.'),
('TPL_0002', 'CAT_FLAN', 'Flan Gato Truyền Thống', 330000, 2.00, 1, 'assets/images/cakeproducts/flan2.jpg', 'Active', 0, 'Bánh flan gato truyền thống với lớp caramel thơm và cốt bánh mềm.'),
('TPL_0003', 'CAT_FLAN', 'Flan Gato Socola', 360000, 2.10, 1, 'assets/images/cakeproducts/flan3.jpg', 'Active', 0, 'Bánh flan gato socola đậm vị, mềm mịn và dễ ăn.'),
('TPL_0004', 'CAT_FLAN', 'Flan Gato Matcha', 370000, 2.20, 1, 'assets/images/cakeproducts/flan4.jpg', 'Active', 1, 'Bánh flan gato matcha thanh nhẹ, hợp khách thích trà xanh.'),
('TPL_0005', 'CAT_MOUSSE', 'Mousse Dâu Tây', 380000, 1.50, 1, 'assets/images/cakeproducts/mousse1.jpg', 'Active', 1, 'Bánh mousse dâu tươi mát lạnh, vị chua ngọt cân bằng.'),
('TPL_0006', 'CAT_MOUSSE', 'Mousse Chanh Dây', 390000, 1.70, 1, 'assets/images/cakeproducts/mousse2.jpg', 'Active', 0, 'Bánh mousse chanh dây mát lạnh, phù hợp tiệc nhẹ.'),
('TPL_0007', 'CAT_MOUSSE', 'Mousse Việt Quất', 410000, 1.80, 1, 'assets/images/cakeproducts/mousse3.jpg', 'Active', 0, 'Bánh mousse việt quất mềm mịn, hương trái cây nổi bật.'),
('TPL_0008', 'CAT_MOUSSE', 'Mousse Chocolate', 430000, 1.80, 1, 'assets/images/cakeproducts/mousse4.jpg', 'Active', 1, 'Bánh mousse chocolate thơm béo, phù hợp khách thích socola.'),
('TPL_0009', 'CAT_CREAM', 'Bánh Kem Bắp', 420000, 2.50, 1, 'assets/images/cakeproducts/bap1.jpg', 'Active', 1, 'Bánh kem bắp truyền thống, kem mềm và bắp ngọt.'),
('TPL_0010', 'CAT_CREAM', 'Bánh Kem Bắp Đặc Biệt', 450000, 2.50, 1, 'assets/images/cakeproducts/bap2.jpg', 'Active', 0, 'Bánh kem bắp đặc biệt, trang trí đẹp và vị ngọt nhẹ.'),
('TPL_0011', 'CAT_BAKED', 'Croissant Bơ', 45000, 1.00, 0, 'assets/images/cakeproducts/plain-croissant.jpg', 'Active', 0, 'Croissant bơ kiểu Pháp, vỏ giòn thơm bơ.'),
('TPL_0012', 'CAT_BAKED', 'Pain Au Chocolat', 55000, 1.00, 0, 'assets/images/cakeproducts/pain-au-choco.jpg', 'Active', 0, 'Bánh nướng kiểu Pháp nhân socola, vỏ giòn thơm.'),
('TPL_0013', 'CAT_PREMIUM', 'Sweetbox Garden', 650000, 2.00, 1, 'assets/images/cakeproducts/sweetbox1.jpg', 'Active', 1, 'Hộp bánh cao cấp nhiều vị, phù hợp làm quà tặng.'),
('TPL_0014', 'CAT_PREMIUM', 'Sweetbox Premium Mix', 720000, 2.30, 1, 'assets/images/cakeproducts/sweetbox2.jpg', 'Active', 0, 'Hộp bánh premium nhiều vị, trình bày tinh tế.'),
('TPL_0015', 'CAT_PREMIUM', 'Sweetbox Signature 16 Vị', 790000, 2.50, 1, 'assets/images/cakeproducts/sweetbox-signature-hong-16.jpg', 'Active', 1, 'Hộp bánh signature tone hồng gồm 16 vị nhỏ.'),
('TPL_0016', 'CAT_PREMIUM', 'Sweetbox Signature 12 Vị', 690000, 2.20, 1, 'assets/images/cakeproducts/sweetbox-signature-xanh-12.jpg', 'Active', 0, 'Hộp bánh signature tone xanh gồm 12 vị nhỏ.'),
('TPL_0017', 'CAT_SWEETIN', 'Sweetin Matcha Tiramisu', 460000, 1.80, 1, 'assets/images/cakeproducts/sweetin-matcha-tiramisu.jpg', 'Active', 1, 'Tiramisu matcha vị trà xanh dịu nhẹ, lớp kem mềm.'),
('TPL_0018', 'CAT_SWEETIN', 'Sweetin Tiramisu Classic', 440000, 1.80, 1, 'assets/images/cakeproducts/sweetin-tiramisu-classic.jpg', 'Active', 0, 'Tiramisu truyền thống vị cà phê nhẹ, kem béo và cốt mềm.'),
('TPL_0019', 'CAT_ENTREMET', 'Entremet Sakura', 520000, 2.80, 1, 'assets/images/cakeproducts/entremet-sakura.png', 'Active', 1, 'Entremet sakura nhiều lớp, thiết kế tinh tế.'),
('TPL_0020', 'CAT_ENTREMET', 'Entremet Letter Cake', 540000, 3.00, 1, 'assets/images/cakeproducts/entremet-letter.jpg', 'Active', 0, 'Entremet dạng chữ, phù hợp sinh nhật và kỷ niệm.'),
('TPL_0021', 'CAT_HEALTHY', 'Healthy Cake Yến Mạch', 320000, 1.50, 1, 'assets/images/cakeproducts/healthy1.jpg', 'Active', 0, 'Bánh healthy yến mạch, ít ngọt và vị nhẹ.'),
('TPL_0022', 'CAT_HEALTHY', 'Healthy Cake Trái Cây', 350000, 1.60, 1, 'assets/images/cakeproducts/healthy2.jpg', 'Active', 0, 'Bánh healthy kết hợp trái cây, vị thanh nhẹ.'),
('TPL_0023', 'CAT_COMBO', 'Combo Mini Cake 6 Vị', 520000, 2.00, 1, 'assets/images/cakeproducts/combo1.jpg', 'Active', 1, 'Combo bánh mini gồm 6 vị khác nhau, phù hợp tiệc nhỏ.'),
('TPL_0024', 'CAT_COMBO', 'Combo Mini Cake 9 Vị', 640000, 2.30, 1, 'assets/images/cakeproducts/combo2.jpg', 'Active', 0, 'Combo bánh mini gồm 9 vị, trình bày đẹp mắt.');

INSERT INTO `product_image` (`Product_ID`, `Image_URL`, `Is_Cover`, `Sort_Order`) VALUES
('TPL_0001', 'assets/images/cakeproducts/flan1.png', 1, 1), ('TPL_0002', 'assets/images/cakeproducts/flan2.jpg', 1, 1),
('TPL_0003', 'assets/images/cakeproducts/flan3.jpg', 1, 1), ('TPL_0004', 'assets/images/cakeproducts/flan4.jpg', 1, 1),
('TPL_0005', 'assets/images/cakeproducts/mousse1.jpg', 1, 1), ('TPL_0006', 'assets/images/cakeproducts/mousse2.jpg', 1, 1),
('TPL_0007', 'assets/images/cakeproducts/mousse3.jpg', 1, 1), ('TPL_0008', 'assets/images/cakeproducts/mousse4.jpg', 1, 1),
('TPL_0009', 'assets/images/cakeproducts/bap1.jpg', 1, 1), ('TPL_0010', 'assets/images/cakeproducts/bap2.jpg', 1, 1),
('TPL_0011', 'assets/images/cakeproducts/plain-croissant.jpg', 1, 1), ('TPL_0012', 'assets/images/cakeproducts/pain-au-choco.jpg', 1, 1),
('TPL_0013', 'assets/images/cakeproducts/sweetbox1.jpg', 1, 1), ('TPL_0014', 'assets/images/cakeproducts/sweetbox2.jpg', 1, 1),
('TPL_0015', 'assets/images/cakeproducts/sweetbox-signature-hong-16.jpg', 1, 1), ('TPL_0016', 'assets/images/cakeproducts/sweetbox-signature-xanh-12.jpg', 1, 1),
('TPL_0017', 'assets/images/cakeproducts/sweetin-matcha-tiramisu.jpg', 1, 1), ('TPL_0018', 'assets/images/cakeproducts/sweetin-tiramisu-classic.jpg', 1, 1),
('TPL_0019', 'assets/images/cakeproducts/entremet-sakura.png', 1, 1), ('TPL_0020', 'assets/images/cakeproducts/entremet-letter.jpg', 1, 1),
('TPL_0021', 'assets/images/cakeproducts/healthy1.jpg', 1, 1), ('TPL_0022', 'assets/images/cakeproducts/healthy2.jpg', 1, 1),
('TPL_0023', 'assets/images/cakeproducts/combo1.jpg', 1, 1), ('TPL_0024', 'assets/images/cakeproducts/combo2.jpg', 1, 1);

INSERT INTO `accessory` (`Accessory_ID`, `Accessory_Name`, `Price`, `Image_URL`, `Status`) VALUES
('ACC_0001', 'Nến sinh nhật', 10000, 'assets/images/accessories/candle.jpg', 'Active'),
('ACC_0002', 'Dao cắt bánh', 5000, 'assets/images/accessories/knife.jpg', 'Active'),
('ACC_0003', 'Mũ sinh nhật', 20000, 'assets/images/accessories/hat.jpg', 'Active'),
('ACC_0004', 'Thiệp chúc mừng', 15000, 'assets/images/accessories/card.jpg', 'Active'),
('ACC_0005', 'Pháo bông nhỏ', 30000, 'assets/images/accessories/sparkler.jpg', 'Active'),
('ACC_0006', 'Bảng tên mica', 25000, 'assets/images/accessories/nameplate.jpg', 'Active'),
('ACC_0007', 'Hoa trang trí bánh', 35000, 'assets/images/accessories/flower.jpg', 'Active'),
('ACC_0008', 'Hộp quà cao cấp', 45000, 'assets/images/accessories/giftbox.jpg', 'Active');

INSERT INTO `category_accessory` (`Category_ID`, `Accessory_ID`) VALUES
('CAT_FLAN', 'ACC_0001'), ('CAT_FLAN', 'ACC_0002'), ('CAT_MOUSSE', 'ACC_0001'), ('CAT_MOUSSE', 'ACC_0004'),
('CAT_CREAM', 'ACC_0001'), ('CAT_CREAM', 'ACC_0003'), ('CAT_CREAM', 'ACC_0006'),
('CAT_BAKED', 'ACC_0002'), ('CAT_BAKED', 'ACC_0004'), ('CAT_PREMIUM', 'ACC_0004'), ('CAT_PREMIUM', 'ACC_0008'),
('CAT_SWEETIN', 'ACC_0001'), ('CAT_SWEETIN', 'ACC_0004'), ('CAT_ENTREMET', 'ACC_0006'), ('CAT_ENTREMET', 'ACC_0007'),
('CAT_HEALTHY', 'ACC_0004'), ('CAT_COMBO', 'ACC_0004'), ('CAT_COMBO', 'ACC_0008'), ('CAT_SIGNATURE', 'ACC_0001'), ('CAT_SIGNATURE', 'ACC_0007');

INSERT INTO `cake_recipe` (`Recipe_ID`, `Template_ID`, `Recipe_Name`, `Instruction_Steps`) VALUES
('REC_0001', 'TPL_0001', 'Công thức Flan Gato Dâu', 'Chuẩn bị flan, nướng cốt bánh, thêm dâu và làm lạnh.'),
('REC_0002', 'TPL_0002', 'Công thức Flan Gato Truyền Thống', 'Chuẩn bị caramel, flan, cốt bánh và làm lạnh.'),
('REC_0003', 'TPL_0003', 'Công thức Flan Gato Socola', 'Chuẩn bị flan socola, nướng cốt bánh và hoàn thiện.'),
('REC_0004', 'TPL_0004', 'Công thức Flan Gato Matcha', 'Pha matcha, chuẩn bị flan, ráp bánh và làm lạnh.'),
('REC_0005', 'TPL_0005', 'Công thức Mousse Dâu Tây', 'Làm mousse dâu, đổ khuôn và làm lạnh.'),
('REC_0006', 'TPL_0006', 'Công thức Mousse Chanh Dây', 'Làm sốt chanh dây, trộn mousse, đổ khuôn và làm lạnh.'),
('REC_0007', 'TPL_0007', 'Công thức Mousse Việt Quất', 'Chuẩn bị sốt việt quất, làm mousse và trang trí.'),
('REC_0008', 'TPL_0008', 'Công thức Mousse Chocolate', 'Đun chảy socola, trộn mousse, đổ khuôn và làm lạnh.'),
('REC_0009', 'TPL_0009', 'Công thức Bánh Kem Bắp', 'Nướng cốt bánh, đánh kem, phủ bắp và trang trí.'),
('REC_0010', 'TPL_0010', 'Công thức Bánh Kem Bắp Đặc Biệt', 'Nướng cốt bánh, thêm kem bắp, trang trí và làm lạnh.'),
('REC_0011', 'TPL_0011', 'Công thức Croissant Bơ', 'Cán bột, gấp bơ, ủ và nướng.'),
('REC_0012', 'TPL_0012', 'Công thức Pain Au Chocolat', 'Cán bột, thêm nhân socola, ủ và nướng.'),
('REC_0013', 'TPL_0013', 'Công thức Sweetbox Garden', 'Chuẩn bị nhiều loại bánh nhỏ và đóng hộp.'),
('REC_0014', 'TPL_0014', 'Công thức Sweetbox Premium Mix', 'Chuẩn bị các loại bánh premium và sắp xếp vào hộp.'),
('REC_0015', 'TPL_0015', 'Công thức Sweetbox Signature Hồng', 'Chuẩn bị 16 vị bánh nhỏ và đóng hộp tone hồng.'),
('REC_0016', 'TPL_0016', 'Công thức Sweetbox Signature Xanh', 'Chuẩn bị 12 vị bánh nhỏ và đóng hộp tone xanh.');

USE bakery;

DROP TABLE IF EXISTS `delivery_address`;
CREATE TABLE `delivery_address` (
  `Address_ID` int NOT NULL AUTO_INCREMENT,
  `User_ID` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Receiver_Name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Receiver_Phone` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Address_Detail` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Latitude` double DEFAULT '0',
  `Longitude` double DEFAULT '0',
  `Is_Default` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Address_ID`),
  KEY `FK_DeliveryAddress_User` (`User_ID`),
  CONSTRAINT `FK_DeliveryAddress_User` FOREIGN KEY (`User_ID`) REFERENCES `user` (`User_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
