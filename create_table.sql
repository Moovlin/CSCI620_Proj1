-- general movie 
INSERT INTO `general_movies`
SELECT old.tconst, old.oTitle, CAST(old.isAdult AS signed), old.`title-type`, CAST(old.runtimeMinutes AS signed)
FROM `title_basics1` old;

-- persons
INSERT INTO `persons`
SELECT old.primaryName, CAST(old.birthYear AS signed), CAST(old.deathYear AS signed)
FROM `name_basics1` old;

-- surrogate
CREATE TABLE `surrogate_person` AS
SELECT old.nconst as nconst, old.primaryName as `primary_name`, old.birthYear as `birth_year`
FROM `name_basics1` old;

-- professions
CREATE TABLE `old_professions` (
  `primary_name` varchar(256) NOT NULL,
  `birth_year` int(11) NOT NULL,
  `profession` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`primary_name`,`birth_year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `old_professions`
SELECT old.primaryName,  CAST(old.birthYear AS signed), old.primaryProfession
FROM `name_basics1` old;

INSERT INTO professions
select a.`primary_name`,a.`birth_year`,substring_index(substring_index(a.profession,',',b.`help_topic_id`+1),',',-1) 
from `old_professions` a
join
mysql.`help_topic` b
on b.`help_topic_id` < (length(a.profession) - length(replace(a.profession,',',''))+1)
order by a.`primary_name`,a.`birth_year`;

DROP TABLE `old_professions`;

-- acts
CREATE TABLE `acts1` (
  `tconst` varchar(256) NOT NULL,
  `nconst` varchar(256) NOT NULL,
  `characters` longtext,
  PRIMARY KEY (`tconst`,`nconst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 360 sec
INSERT ignore INTO acts1
SELECT tconst, nconst, substring(a.characters,3,LENGTH(a.characters)-4)
FROM `title_principals1` a;

-- INSERT ignore INTO acts 2486sec
create table test_acts as
select a.`nconst` as nconst,a.`tconst` as tconst,substring_index(substring_index(a.characters,'","',b.`help_topic_id`+1),'","',-1) as characters
from acts1 a
join
mysql.`help_topic` b
on b.`help_topic_id` < (length(a.characters) - length(replace(a.characters,'","',''))+1)
order by a.`nconst`, a.`tconst`;
-- 2197sec
create table acts as 
SELECT DISTINCT cast(nconst as char(30)) as nconst, cast(tconst as char(30)) as tconst, cast(characters as char(512)) as characters FROM test_acts WHERE characters is not null;
ALTER TABLE `acts` 
CHANGE COLUMN `nconst` `nconst` VARCHAR(30) CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_0900_ai_ci' NOT NULL ,
CHANGE COLUMN `tconst` `tconst` VARCHAR(30) CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_0900_ai_ci' NOT NULL ,
CHANGE COLUMN `characters` `characters` VARCHAR(512) CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_0900_ai_ci' NOT NULL ,
ADD PRIMARY KEY (`nconst`, `tconst`, `characters`);

DROP TABLE acts1;
DROP TABLE `test_acts`;
-- participates
ALTER TABLE `proj1`.`title_principals2` 
RENAME TO  `proj1`.`participates` ;

-- localize
INSERT ignore INTO localize
SELECT a.titleId, a.title, a.language, CAST(a.isOriginal AS signed)
FROM title_akas1 a;

-- movie
INSERT ignore INTO movie
SELECT tconst, CAST(startYear AS signed)
FROM `title_basics1`
WHERE `title-type` = 'movie';

-- videogame
INSERT ignore INTO videogame
SELECT tconst, CAST(startYear AS signed)
FROM `title_basics1`
WHERE `title-type` = 'videoGame';

-- tvseries
INSERT ignore INTO tvseries
SELECT tconst, if(isnull(endYear),0,1)
FROM `title_basics1`
WHERE `title-type` = 'tvseries';

-- tvepisode
INSERT ignore INTO tvepisode
SELECT tconst, CAST(episodeNumber AS signed)
FROM `title_episodes1`;

-- has
INSERT ignore INTO has
SELECT a.parentTconst, a.tconst, CAST(a.seasonNumber AS signed), CAST(b.startYear AS signed)
FROM `title_episodes1` a
JOIN
`title_basics1` b
ON a.tconst = b.tconst;

-- genres
CREATE TABLE `old_genres` (
  `tconst` varchar(256) NOT NULL,
  `genres` longtext,
  PRIMARY KEY (`tconst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `old_genres`
SELECT old.tconst, old.genres
FROM `title_basics1` old;

INSERT INTO generes
select a.`tconst`,substring_index(substring_index(a.genres,',',b.`help_topic_id`+1),',',-1) 
from `old_genres` a
join
mysql.`help_topic` b
on b.`help_topic_id` < (length(a.genres) - length(replace(a.genres,',',''))+1)
order by a.`tconst`;

DROP TABLE `old_genres`;

-- users
INSERT INTO users(uid)
SELECT substring(tconst,3)
FROM `title_ratings`;

-- ratings
INSERT ignore INTO `previous_rating`
SELECT tconst, convert(aveRating, decimal(2,1)), cast(numVote as signed)
FROM `title_ratings`;

-- news
INSERT ignore INTO new
SELECT tconst
FROM generes 
where genre = 'news';

-- INSERT ignore INTO hosts
INSERT ignore INTO hosts 
SELECT distinct a.`news_tconst` as news_tconst, b.nconst as host_nconst, b.characters as role
FROM new a, `title_principals` b
WHERE a.`news_tconst` = b.tconst;

-- talk show
CREATE TABLE `talkshow` (
  `tconst` VARCHAR(30) NOT NULL,
  `show_year` INT(11) NULL,
  PRIMARY KEY (`tconst`));

INSERT ignore INTO `talkshow`
SELECT gen.tconst, t.startYear
FROM generes gen, title_basics t
WHERE gen.genre = 'Talk-Show'
AND gen.tconst = t.tconst;

-- DROP 
DROP TABLE `name_basics`;
DROP TABLE `name_basics1`;
DROP TABLE `title_akas`;
DROP TABLE `title_akas1`;
DROP TABLE `title_basics`;
DROP TABLE `title_basics1`;
DROP TABLE `title_episodes`;
DROP TABLE `title_episodes1`;
DROP TABLE `title_principals`;
DROP TABLE `title_principals1`;
DROP TABLE `title_ratings`;
