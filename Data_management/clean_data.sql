CREATE TABLE `name_basics1` (
  `nconst` varchar(45) NOT NULL,
  `primaryName` varchar(300) NOT NULL,
  `birthYear` varchar(45) NOT NULL,
  `deathYear` varchar(45) DEFAULT NULL,
  `primaryProfession` longtext,
  `knownForTitles` longtext,
  PRIMARY KEY (`primaryName`,`birthYear`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `title_akas1` (
  `titleId` varchar(80) NOT NULL,
  `ordering` varchar(45) NOT NULL,
  `title` varchar(300) NOT NULL,
  `region` varchar(45) DEFAULT NULL,
  `language` varchar(45) NOT NULL,
  `types` longtext,
  `attributes` longtext,
  `isOriginal` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`title`,`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `title_basics1` (
  `tconst` varchar(80) NOT NULL,
  `title-type` varchar(80) DEFAULT NULL,
  `pTitle` longtext,
  `oTitle` varchar(600) DEFAULT NULL,
  `isAdult` varchar(45) DEFAULT NULL,
  `startYear` varchar(45) DEFAULT NULL,
  `endYear` varchar(45) DEFAULT NULL,
  `runtimeMinutes` varchar(45) DEFAULT NULL,
  `genres` varchar(180) DEFAULT NULL,
  PRIMARY KEY (`tconst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `title_episodes1` (
  `tconst` varchar(80) NOT NULL,
  `parentTconst` varchar(80) DEFAULT NULL,
  `seasonNumber` varchar(45) DEFAULT NULL,
  `episodeNumber` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`tconst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- CREATE TABLE `title_principals1` (
--   `tconst` varchar(80) NOT NULL,
--   `ordering` varchar(45) NOT NULL,
--   `nconst` varchar(45) NOT NULL,
--   `category` varchar(80) DEFAULT NULL,
--   `job` longtext,
--   `characters` longtext,
--   PRIMARY KEY (`tconst`,`ordering`,`nconst`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `title_principals2` (
  `tconst` varchar(80) NOT NULL,
  `nconst` varchar(45) NOT NULL,
  `category` varchar(128) DEFAULT NULL,
  `job` varchar(128) DEFAULT NULL,
  `characters` longtext,
  PRIMARY KEY (`tconst`,`nconst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO `title_akas1`
SELECT *
FROM `title_akas` old
WHERE old.language IS NOT NULL
AND old.title IS NOT NULL
AND old.region IS NOT NULL
AND old.language IS NOT NULL;


INSERT IGNORE INTO `title_basics1`
SELECT *
FROM `title_basics` old
WHERE (old.startYear IS NOT NULL
AND old.`title-type` IS NOT NULL
AND old.oTitle IS NOT NULL
AND old.runtimeMinutes IS NOT NULL);

INSERT IGNORE INTO `title_episodes1`
SELECT *
FROM `title_episodes` old
WHERE old.seasonNumber IS NOT NULL
AND old.episodeNumber IS NOT NULL;

-- after create table
-- create table title_principals1 as
-- SELECT distinct *
-- FROM `title_principals` old
-- WHERE old.category = 'actor' AND old.characters IS NOT NULL
-- OR old.category = 'actress' AND old.characters IS NOT NULL
-- and exists (
-- select * from surrogate_person s where s.nconst = old.nconst)
-- and exists (
-- select * from general_movies g where g.tconst = old.tconst);

-- INSERT IGNORE INTO `title_principals1`
-- SELECT *
-- FROM `title_principals` old
-- WHERE old.category = 'actress' AND old.characters IS NOT NULL;
-- 1209s
create table `title_principals2` as
SELECT old.tconst,old.nconst,old.category,old.job
FROM `title_principals` old
WHERE old.category IS NOT NULL and not old.category = 'actress' and not old.category = 'actor'
and exists (
select * from surrogate_person s where s.nconst = old.nconst)
and exists (
select * from general_movies g where g.tconst = old.tconst);

INSERT IGNORE INTO `name_basics1`
SELECT * 
FROM `name_basics` old
WHERE old.primaryName IS NOT NULL
AND old.birthYear IS NOT NULL;