CREATE DATABASE `drillApp`;

CREATE TABLE `ActiveAthletes` (
 `id` int(11) NOT NULL AUTO_INCREMENT,
 `VenueId` int(11) NOT NULL,
 `EventsId` int(11) NOT NULL,
 `StartNo` int(11) NOT NULL,
 `AthletesId` int(11) NOT NULL,
 `Lane` int(11) NOT NULL,
 PRIMARY KEY (`id`)
);

CREATE TABLE `ActiveList` (
 `ActiveId` int(11) NOT NULL AUTO_INCREMENT,
 `ActiveVenueId` int(11) NOT NULL,
 `ActiveEventId` int(11) NOT NULL,
 `State` enum('NotStarted','Active','Completed','') NOT NULL,
 PRIMARY KEY (`ActiveId`)
);


CREATE TABLE `Athletes` (
 `AthletesId` int(11) NOT NULL AUTO_INCREMENT,
 `AthletesExtId` int(11) NOT NULL,
 `AthletesName` char(100) NOT NULL,
 `OriginId` int(11) NOT NULL,
 `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (`AthletesId`)
);

CREATE TABLE `Events` (
 `EventsId` int(11) NOT NULL AUTO_INCREMENT,
 `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 `VenueId` int(11) NOT NULL,
 `Category` char(30) NOT NULL,
 `Division` char(30) NOT NULL,
 `Level` char(30) DEFAULT NULL,
 `EvHeat` char(30) NOT NULL,
 `Lane` int(11) DEFAULT NULL,
 PRIMARY KEY (`EventsId`)
);

CREATE TABLE `EventsJudges` (
 `EventJudgeId` int(11) NOT NULL AUTO_INCREMENT,
 `EventsId` int(11) NOT NULL,
 `VenueId` int(11) NOT NULL,
 `JudgesId` int(11) NOT NULL,
 `JudgesExtId` int(11) NOT NULL,
 `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (`EventJudgeId`)
);

CREATE TABLE `Judges` (
 `JudgesId` int(11) NOT NULL AUTO_INCREMENT,
 `JudgeExtId` int(11) NOT NULL,
 `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 `JudgesName` char(100) NOT NULL,
 `OriginId` int(11) DEFAULT NULL,
 PRIMARY KEY (`JudgesId`)
);

CREATE TABLE `Origin` (
 `OriginId` int(11) NOT NULL AUTO_INCREMENT,
 `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 `OriginName` char(100) NOT NULL,
 `iso` varchar(8) NOT NULL,
 PRIMARY KEY (`OriginId`)
);

CREATE TABLE `PreScores` (
 `ScoreId` int(11) NOT NULL AUTO_INCREMENT,
 `JudgesId` int(11) NOT NULL,
 `EventsId` int(11) NOT NULL,
 `StartNo` int(11) NOT NULL,
 `Section_1` decimal(11,2) DEFAULT NULL,
 `Section_2` decimal(11,2) DEFAULT NULL,
 `Section_3` decimal(11,2) DEFAULT NULL,
 `Section_4` decimal(11,2) DEFAULT NULL,
 `Section_5` decimal(11,2) DEFAULT NULL,
 `Deduction` decimal(11,2) DEFAULT NULL,
 `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (`ScoreId`)
);

CREATE TABLE `Scores` (
 `ScoreId` int(11) NOT NULL AUTO_INCREMENT,
 `JudgesId` int(11) DEFAULT NULL,
 `EventsId` int(11) DEFAULT NULL,
 `StartNo` int(11) DEFAULT NULL,
 `Section_1` decimal(11,2) DEFAULT NULL,
 `Section_2` decimal(11,2) DEFAULT NULL,
 `Section_3` decimal(11,2) DEFAULT NULL,
 `Section_4` decimal(11,2) DEFAULT NULL,
 `Section_5` decimal(11,2) DEFAULT NULL,
 `Deduction` decimal(11,2) DEFAULT NULL,
 `Completed` tinyint(1) NOT NULL DEFAULT '0',
 `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (`ScoreId`)
);

CREATE TABLE `StartNo` (
 `StartNoId` int(11) NOT NULL AUTO_INCREMENT,
 `VenueId` int(11) NOT NULL,
 `StartNo` int(11) DEFAULT NULL,
 `IntStartNo` int(11) NOT NULL,
 `EventsId` int(11) DEFAULT NULL,
 `AthletesId` int(11) DEFAULT NULL,
 `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (`StartNoId`)
);

CREATE TABLE `StartNoCompleted` (
 `id` int(11) NOT NULL AUTO_INCREMENT,
 `VenueId` int(11) NOT NULL,
 `EventsId` int(11) NOT NULL,
 `StartNo` int(11) NOT NULL,
 `IntStartNo` int(11) NOT NULL,
 `Status` enum('Withdrawn','NoShow','Scored','') NOT NULL,
 `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 PRIMARY KEY (`id`)
);

CREATE TABLE `Users` (
 `UserId` int(11) NOT NULL AUTO_INCREMENT,
 `UserStr` char(16) NOT NULL,
 `UserName` char(100) NOT NULL,
 `UserPassword` char(100) NOT NULL,
 `OriginId` int(11) DEFAULT NULL,
 `Roles` set('User','HeadJudge','Judge','Admin','Presenter') NOT NULL DEFAULT 'User',
 PRIMARY KEY (`UserId`)
);

CREATE TABLE `Venues` (
 `VenueId` int(11) NOT NULL AUTO_INCREMENT,
 `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 `Venue` char(100) NOT NULL,
 PRIMARY KEY (`VenueId`)
);