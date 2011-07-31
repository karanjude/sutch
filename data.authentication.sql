-- MySQL dump 10.13  Distrib 5.1.41, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: data
-- ------------------------------------------------------
-- Server version	5.1.41-3ubuntu12.10

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
-- Table structure for table `authentication`
--

DROP TABLE IF EXISTS `authentication`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `authentication` (
  `access_token` varchar(250) NOT NULL,
  `company` varchar(32) DEFAULT NULL,
  `used` tinyint(1) DEFAULT NULL,
  `user_id` varchar(50) DEFAULT NULL,
  `posted` tinyint(1) DEFAULT NULL,
  `user_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`access_token`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `authentication`
--

LOCK TABLES `authentication` WRITE;
/*!40000 ALTER TABLE `authentication` DISABLE KEYS */;
INSERT INTO `authentication` VALUES ('136358823108222|88459397e6ddbd00c161ef5e.1-502244521|2yTIOvbM3nUCtY_zVrV7HbJ4bLw','facebook',1,'502244521',1,'apoorvjn'),('136358823108222|0a52bd3e54d9d804abcfe0ec.1-635875436|4hcvMm9j2Wbal387YGwc1eQabVs','facebook',1,'635875436',1,'karan.jude'),('http://api.twitter.com/1/?consumer_key=3BEPD0jb9zEAMMJi8guGw&consumer_secret=8ptfNmTYsyJdkUerzV5uFlevs74y4Qq55WUL50boTe4&oauth_key=16862925-VKQi4rgtG2aRUvBa8ulyNIG3WAEsAJ13khOTowJLK&oauth_secret=pnDXndtfGwM5THtrK7BQNlLcRWcVwkKQDlxQfwwjM','twitter',1,'16862925',1,'brightonvino'),('136358823108222|7549983fb5b80e81ba214bf5.1-602046146|eikmEkf8RP93efiZamxIw6MLztE','facebook',1,'602046146',1,'sumitgahlawat'),('136358823108222|bf4d3f846805fe596ddafa7b.1-508625268|r8TGaGv5Y2LV8_jkjKU35k1Z9MI','facebook',1,'508625268',1,'anilkarat'),('136358823108222|f2c70592a9ef28b59af37456.1-563741745|pQs8HlNmv5pC2H3uUkEgrE8vcUU','facebook',1,'563741745',1,'Anil Karat Dev'),('136358823108222|0f6f6b6c28db9b8ff92726c1.1-540445722|1eLUEvBNSp4qzSN7aMCOo5AEkCU','facebook',1,'540445722',1,'avishek.chandra'),('http://api.twitter.com/1/?consumer_key=3BEPD0jb9zEAMMJi8guGw&consumer_secret=8ptfNmTYsyJdkUerzV5uFlevs74y4Qq55WUL50boTe4&oauth_key=15235792-dA49Y9zNgudGIvxMtqeev1u229twFFjjMPHdWlqjj&oauth_secret=Bv7sciiFbmt91JNylR55oxAfoHVXEnze7y9rqO8mTs','twitter',1,'15235792',1,'karanjude'),('136358823108222|535bc307a61e68fcbc0581c7.1-521422735|NsZlk_bCPf8T5Ao4FyV1E22MTSQ','facebook',1,'521422735',1,'shamirajoshua'),('136358823108222|d9ac2ebc2a1f4bb94f5f3efd.1-100000685026940|xPe--_g-r0wQznn7eCsYhxaq2N0','facebook',1,'100000685026940',1,'Jeff Ye'),('http://api.twitter.com/1/?consumer_key=3BEPD0jb9zEAMMJi8guGw&consumer_secret=8ptfNmTYsyJdkUerzV5uFlevs74y4Qq55WUL50boTe4&oauth_key=107751183-Sa5lVeVE140uZpvTPYmLPMHUPRXp64vQzDowN6Pl&oauth_secret=OQLPM4yc1HuHpKYVcObmeOB9CjRx9ZJ4k25c0aeP1L4','twitter',1,'107751183',1,'jeffye613'),('http://api.twitter.com/1/?consumer_key=3BEPD0jb9zEAMMJi8guGw&consumer_secret=8ptfNmTYsyJdkUerzV5uFlevs74y4Qq55WUL50boTe4&oauth_key=140302105-42RbMsPhfmYFv4eyhtK1Zj9IKrZghbNjIPgjgBU9&oauth_secret=eXgS7bV879opfVAXCtKicrnpEW3iwBJhYvgn6wX9x0','twitter',1,'140302105',1,'montygshah'),('http://api.twitter.com/1/?consumer_key=3BEPD0jb9zEAMMJi8guGw&consumer_secret=8ptfNmTYsyJdkUerzV5uFlevs74y4Qq55WUL50boTe4&oauth_key=71156816-WTZaLevt89K3M3ERWX8mXWqvkOJrE5X0qZHdJE5cP&oauth_secret=3r76fhjuf778gZltMgMcdg93IIm3EPzldD99xpoVO8','twitter',1,'71156816',1,'chrismattmann'),('http://api.twitter.com/1/?consumer_key=3BEPD0jb9zEAMMJi8guGw&consumer_secret=8ptfNmTYsyJdkUerzV5uFlevs74y4Qq55WUL50boTe4&oauth_key=341460167-AiMd2eudS5U4mKvYoSvfWlegHSlRHTzZGkpYCbnc&oauth_secret=lfwnETe3MPvlraov2dQTCc8KsH1rY2poBxahnKpTYs','twitter',1,'341460167',1,'dummyjude'),('http://api.twitter.com/1/?consumer_key=3BEPD0jb9zEAMMJi8guGw&consumer_secret=8ptfNmTYsyJdkUerzV5uFlevs74y4Qq55WUL50boTe4&oauth_key=15618484-AWDCS4VBW5HmeER6wdbl2ktlny2jPHEPUMl366pKk&oauth_secret=334UO4rEejIzTpNy2NQARI3IjcJ5nMFsBQkjPGUojNg','twitter',1,'15618484',1,'simplypavi'),('136358823108222|7cd724af10b60cb145b8028b.1-1233090206|J2HKf1JHlbO9pC3ppCut62chJpk','facebook',1,'1233090206',1,'philoscyrus'),('136358823108222|1a351bdcdec34a85e3fae69a.1-100000265677740|3Dp4IyOWmrsKroLwBw3tU3M_4s0','facebook',1,'100000265677740',1,'Abhinav Sarna'),('136358823108222|4203bb66ad2b4d20ecf17d42.1-1144382010|mDmBKTtAhLBG2gaLeAUkH2VS6rc','facebook',1,'1144382010',1,'rohit.alexander'),('136358823108222|42aa2707a9f5938d579c7d32.1-1322889847|7eykTdxBYHZxibFIz6l0gIvOlAc','facebook',1,'1322889847',1,'praneshvittal'),('136358823108222|036ff9c1a898637d197c32f2.1-100002462620719|HRTuWBKme-FiAe4-YkrARDdontY','facebook',1,'100002462620719',1,'Col Satwant Singh'),('136358823108222|a1023450607c988e1413490e.1-555264176|2IxJG29wMcmRG8j6mD17Skb8k-c','facebook',1,'555264176',1,'Parveen Ahlawat'),('136358823108222|bc41a1fc49e6619d1deea166.1-100001939772945|rbgmLkRDAyGjlIzxwufl7pUP_kc','facebook',1,'100001939772945',1,'Jude Karan'),('http://api.twitter.com/1/?consumer_key=3BEPD0jb9zEAMMJi8guGw&consumer_secret=8ptfNmTYsyJdkUerzV5uFlevs74y4Qq55WUL50boTe4&oauth_key=341460167-iwhxtkGnuYbB5nqO0TaTxzeNpPe3poaYAxftQJwR&oauth_secret=tR6kAdz81CYSalWZA1zXCIPrl482n1fTBL4O1GfQ','twitter',1,'341460167',1,'dummyjude'),('http://api.twitter.com/1/?consumer_key=3BEPD0jb9zEAMMJi8guGw&consumer_secret=8ptfNmTYsyJdkUerzV5uFlevs74y4Qq55WUL50boTe4&oauth_key=10408812-1weoM7997xkGwXAdOeyTwwg5DGSULcoRQ8VUzjj3M&oauth_secret=mE8Gtx9XZWbIscJD8m4adGj4PTvbfMxrct7iUThs','twitter',1,'10408812',1,'rohitnair'),('136358823108222|f8d3af502378a0839bb5cb6b.1-500988401|zp7M6V-TzMdXgy4uDf_NkT1x_Hw','facebook',1,'500988401',1,'rohitnair'),('136358823108222|49982c4954da4d7e8416d724.1-704739020|3M05qrsp7umSf4Z_K6gbCHYcgSE','facebook',1,'704739020',1,'Depak Viswanathan');
/*!40000 ALTER TABLE `authentication` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2011-07-31  0:21:54
