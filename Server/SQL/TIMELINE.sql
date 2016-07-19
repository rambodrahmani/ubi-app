-- phpMyAdmin SQL Dump
-- version 3.5.5
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Nov 25, 2014 at 08:20 AM
-- Server version: 5.5.40-36.1
-- PHP Version: 5.4.23

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `rrahmani_Ubi`
--

-- --------------------------------------------------------

--
-- Table structure for table `TIMELINE`
--

CREATE TABLE IF NOT EXISTS `TIMELINE` (
  `Email` varchar(255) NOT NULL,
  `PostText` longtext NOT NULL,
  `DataPost` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `MediaURL` varchar(255) DEFAULT NULL,
  `TaggedPeople` longtext,
  `Address` longtext,
  PRIMARY KEY (`Email`,`DataPost`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `TIMELINE`
--

INSERT INTO `TIMELINE` (`Email`, `PostText`, `DataPost`, `MediaURL`, `TaggedPeople`, `Address`) VALUES
('boot_test2@gmail.com', 'The more wiki keeps leaking, the more I sleep well at night.', '2014-10-24 20:53:15', 'https://s3.amazonaws.com/images.charitybuzz.com/images/135239/detail.jpg', '{[rambodrahmani@yahoo.it]|[rambod@rahmani.com]|[info@rambod.it]|[prova@email.it]}', 'I Praticelli Spa via Berchet, 40 56017 Ghezzano PI|[43.719242;10.426105]'),
('boot_test2@gmail.com', 'The more wiki keeps leaking, the more I sleep well at night.', '2014-11-25 03:53:15', 'https://s3.amazonaws.com/images.charitybuzz.com/images/135239/detail.jpg', '{[rambodrahmani@yahoo.it]|[rambod@rahmani.com]|[info@rambod.it]|[prova@email.it]}', 'I Praticelli Spa via Berchet, 40 56017 Ghezzano PI|[43.719242;10.426105]'),
('boot_test3@gmail.com', 'Stavolta Mark ci hai azzeccato, il blu ci sta bene! ;)', '2014-11-21 21:53:15', 'http://wp-up.s3.amazonaws.com/aw/2013/07/whatsapp1-620x348.jpg', '{[rambodrahmani@yahoo.it]|[rambod@rahmani.com]|[info@rambod.it]|[prova@email.it]}', 'I Praticelli Spa via Berchet, 40 56017 Ghezzano PI|[43.719242;10.426105]'),
('boot_test3@gmail.com', 'Stavolta Mark ci hai azzeccato, il blu ci sta bene! ;)', '2014-11-25 03:53:15', 'http://wp-up.s3.amazonaws.com/aw/2013/07/whatsapp1-620x348.jpg', '{[rambodrahmani@yahoo.it]|[rambod@rahmani.com]|[info@rambod.it]|[prova@email.it]}', 'I Praticelli Spa via Berchet, 40 56017 Ghezzano PI|[43.719242;10.426105]'),
('boot_test4@gmail.com', 'The point is that Kids will take a chance! If they don', '2014-08-24 20:53:15', 'http://cs623928.vk.me/v623928667/9834/wZAEUYYCyN0.jpg', '{[rambodrahmani@yahoo.it]|[rambod@rahmani.com]|[info@rambod.it]|[prova@email.it]}', 'I Praticelli Spa via Berchet, 40 56017 Ghezzano PI|[43.719242;10.426105]'),
('boot_test4@gmail.com', 'The point is that Kids will take a chance! If they don', '2014-11-25 03:53:15', 'http://cs623928.vk.me/v623928667/9834/wZAEUYYCyN0.jpg', '{[rambodrahmani@yahoo.it]|[rambod@rahmani.com]|[info@rambod.it]|[prova@email.it]}', 'I Praticelli Spa via Berchet, 40 56017 Ghezzano PI|[43.719242;10.426105]'),
('boot_test5@gmail.com', 'RT @ESA_Rosetta: Welcome to a comet! First CIVA images confirm @Philae2014 is on surface of #67P! http://t.co/EYSlRFjQBb #CometLanding httpâ€¦', '2013-11-24 21:53:15', 'http://www.esa.int/var/esa/storage/images/esa_multimedia/images/2013/12/rosetta_and_philae_at_comet6/13463574-2-eng-GB/Rosetta_and_Philae_at_comet_node_full_image_2.jpg', '{[rambodrahmani@yahoo.it]|[rambod@rahmani.com]|[info@rambod.it]|[prova@email.it]}', 'I Praticelli Spa via Berchet, 40 56017 Ghezzano PI|[43.719242;10.426105]'),
('boot_test5@gmail.com', 'RT @ESA_Rosetta: Welcome to a comet! First CIVA images confirm @Philae2014 is on surface of #67P! http://t.co/EYSlRFjQBb #CometLanding httpâ€¦', '2014-11-25 03:53:15', 'http://www.esa.int/var/esa/storage/images/esa_multimedia/images/2013/12/rosetta_and_philae_at_comet6/13463574-2-eng-GB/Rosetta_and_Philae_at_comet_node_full_image_2.jpg', '{[rambodrahmani@yahoo.it]|[rambod@rahmani.com]|[info@rambod.it]|[prova@email.it]}', 'I Praticelli Spa via Berchet, 40 56017 Ghezzano PI|[43.719242;10.426105]'),
('boot_test6@gmail.com', 'RT @felarof: Look I finished customising my penny board!! :D @MrBenBrown @chloedonald_ http://t.co/dVlRslDIGO', '2014-11-10 21:53:15', 'http://upload.wikimedia.org/wikipedia/commons/e/ee/Horizontal_Skateboard.jpg', '{[rambodrahmani@yahoo.it]|[rambod@rahmani.com]|[info@rambod.it]|[prova@email.it]}', 'I Praticelli Spa via Berchet, 40 56017 Ghezzano PI|[43.719242;10.426105]'),
('boot_test6@gmail.com', 'RT @felarof: Look I finished customising my penny board!! :D @MrBenBrown @chloedonald_ http://t.co/dVlRslDIGO', '2014-11-25 03:53:15', 'http://upload.wikimedia.org/wikipedia/commons/e/ee/Horizontal_Skateboard.jpg', '{[rambodrahmani@yahoo.it]|[rambod@rahmani.com]|[info@rambod.it]|[prova@email.it]}', 'I Praticelli Spa via Berchet, 40 56017 Ghezzano PI|[43.719242;10.426105]'),
('boot_test7@gmail.com', 'The more wiki keeps leaking, the more I sleep well at night.', '2014-11-04 21:53:15', 'https://s3.amazonaws.com/images.charitybuzz.com/images/135239/detail.jpg', '{[rambodrahmani@yahoo.it]|[rambod@rahmani.com]|[info@rambod.it]|[prova@email.it]}', 'I Praticelli Spa via Berchet, 40 56017 Ghezzano PI|[43.719242;10.426105]'),
('boot_test7@gmail.com', 'The more wiki keeps leaking, the more I sleep well at night.', '2014-11-25 03:53:15', 'https://s3.amazonaws.com/images.charitybuzz.com/images/135239/detail.jpg', '{[rambodrahmani@yahoo.it]|[rambod@rahmani.com]|[info@rambod.it]|[prova@email.it]}', 'I Praticelli Spa via Berchet, 40 56017 Ghezzano PI|[43.719242;10.426105]'),
('boot_test8@gmail.com', 'Stavolta Mark ci hai azzeccato, il blu ci sta bene! ;)', '2004-11-24 21:53:15', 'http://wp-up.s3.amazonaws.com/aw/2013/07/whatsapp1-620x348.jpg', '{[rambodrahmani@yahoo.it]|[rambod@rahmani.com]|[info@rambod.it]|[prova@email.it]}', 'I Praticelli Spa via Berchet, 40 56017 Ghezzano PI|[43.719242;10.426105]'),
('boot_test8@gmail.com', 'Stavolta Mark ci hai azzeccato, il blu ci sta bene! ;)', '2014-11-25 03:53:15', 'http://wp-up.s3.amazonaws.com/aw/2013/07/whatsapp1-620x348.jpg', '{[rambodrahmani@yahoo.it]|[rambod@rahmani.com]|[info@rambod.it]|[prova@email.it]}', 'I Praticelli Spa via Berchet, 40 56017 Ghezzano PI|[43.719242;10.426105]'),
('ram.ram@hotmail.it', 'Ah, nel caso qualcuno se lo fosse perso, Mark Zuckerberg studiava psicologia.', '2014-11-25 03:37:48', 'http://lifenews.wpengine.netdna-cdn.com/wp-content/uploads/2014/02/markzuckerberg.jpg', '{[rambodrahmani@yahoo.it]|[rambod@rahmani.com]|[info@rambod.it]|[prova@email.it]}', 'I Praticelli Spa via Berchet, 40 56017 Ghezzano PI|[43.719242;10.426105]');

--
-- Constraints for dumped tables
--

--
-- Constraints for table `TIMELINE`
--
ALTER TABLE `TIMELINE`
  ADD CONSTRAINT `TIMELINE_ibfk_1` FOREIGN KEY (`Email`) REFERENCES `UTENTI` (`Email`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
