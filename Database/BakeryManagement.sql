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
  `Price` decimal(10,0) NOT NULL,
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
  `Base_Price` decimal(10,0) DEFAULT NULL,
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
  `Calculated_Price` decimal(10,0) NOT NULL,
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
  `Calculated_Shipping_Fee` decimal(10,0) NOT NULL,
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
  `Price_Per_Unit` decimal(10,0) NOT NULL,
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
  `Price_At_Purchase` decimal(10,0) NOT NULL,
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
  `Deposit_Amount` decimal(10,0) NOT NULL,
  `Total_Cost` decimal(10,0) NOT NULL,
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
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-18 13:29:05
