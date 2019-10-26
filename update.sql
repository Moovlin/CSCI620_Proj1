-- DROP 
DROP TABLE acts;
DROP TABLE participates;

CREATE TABLE `title_principals` (
  `tconst` varchar(80) NOT NULL,
  `ordering` varchar(45) NOT NULL,
  `nconst` varchar(45) NOT NULL,
  `category` varchar(80) DEFAULT NULL,
  `job` longtext,
  `characters` longtext,
  PRIMARY KEY (`tconst`,`ordering`,`nconst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOAD DATA INFILE 'principals.tsv' INTO TABLE `title_principals`
FIELDS TERMINATED BY '\t' 
LINES TERMINATED BY '\n' IGNORE 1 LINES
(@col1,@col2,@col3,@col4,@col5,@col6) 
set tconst=nullif(@col1,''), 
	ordering=nullif(@col2,''), 
    nconst=nullif(@col3,''),
    category=nullif(@col4,''),
    job=nullif(@col5,''), 
    characters=nullif(@col6,''); 
    
-- acts
-- 237s
create table title_principals1 as
SELECT distinct *
FROM `title_principals` old
WHERE old.category = 'actor' AND old.characters IS NOT NULL
OR old.category = 'actress' AND old.characters IS NOT NULL
and exists (
select * from surrogate_person s where s.nconst = old.nconst)
and exists (
select * from general_movies g where g.tconst = old.tconst);

CREATE TABLE `acts1` (
  `tconst` varchar(256) NOT NULL,
  `nconst` varchar(256) NOT NULL,
  `characters` longtext,
  PRIMARY KEY (`tconst`,`nconst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 139 sec
INSERT ignore INTO acts1
SELECT tconst, nconst, substring(a.characters,3,LENGTH(a.characters)-4)
FROM `title_principals1` a;

-- INSERT ignore INTO acts 1459sec
create table test_acts as
select a.`nconst` as nconst,a.`tconst` as tconst,substring_index(substring_index(a.characters,'","',b.`help_topic_id`+1),'","',-1) as characters
from acts1 a
join
mysql.`help_topic` b
on b.`help_topic_id` < (length(a.characters) - length(replace(a.characters,'","',''))+1)
order by a.`nconst`, a.`tconst`;

-- 92sec
create table acts as 
SELECT DISTINCT cast(nconst as char(30)) as nconst, cast(tconst as char(30)) as tconst, cast(characters as char(512)) as characters FROM test_acts WHERE characters is not null;
-- 89sec
ALTER TABLE `acts` 
CHANGE COLUMN `nconst` `nconst` VARCHAR(30) CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_0900_ai_ci' NOT NULL ,
CHANGE COLUMN `tconst` `tconst` VARCHAR(30) CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_0900_ai_ci' NOT NULL ,
CHANGE COLUMN `characters` `characters` VARCHAR(512) CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_0900_ai_ci' NOT NULL ,
ADD PRIMARY KEY (`nconst`, `tconst`, `characters`);

DROP TABLE acts1;
DROP TABLE `test_acts`;

-- participates
create table `title_principals2` as
SELECT old.tconst,old.nconst,old.category,old.job
FROM `title_principals` old
WHERE old.category IS NOT NULL and not old.category = 'actress' and not old.category = 'actor'
and exists (
select * from surrogate_person s where s.nconst = old.nconst)
and exists (
select * from general_movies g where g.tconst = old.tconst);

ALTER TABLE `title_principals2` 
RENAME TO  `participates` ;

-- producers
CREATE TABLE producers as
SELECT distinct p.tconst, p.nconst, p.job
FROM participates p
WHERE p.category = 'producer'
and exists(select * from surrogate_person sur where p.nconst = sur.nconst)
and exists(select * from general_movies gen where p.tconst = gen.tconst);

ALTER TABLE `producers` 
ADD PRIMARY KEY (`nconst`, `tconst`);

-- director
CREATE TABLE directors as
SELECT distinct p.tconst, p.nconst, p.job
FROM participates p
WHERE p.category = 'director'
and exists(select * from surrogate_person sur where p.nconst = sur.nconst)
and exists(select * from general_movies gen where p.tconst = gen.tconst);

ALTER TABLE `directors` 
ADD PRIMARY KEY (`nconst`, `tconst`);

-- writer
CREATE TABLE writers as
SELECT distinct p.tconst, p.nconst, p.job
FROM participates p
WHERE p.category = 'writer'
and exists(select * from surrogate_person sur where p.nconst = sur.nconst)
and exists(select * from general_movies gen where p.tconst = gen.tconst);

ALTER TABLE `writers` 
ADD PRIMARY KEY (`nconst`, `tconst`);

-- talk show
INSERT ignore INTO `talkshow`
SELECT gen.tconst, t.startYear
FROM generes gen, title_basics t
WHERE gen.genre = 'Talk-Show'
AND gen.tconst = t.tconst;

DROP TABLE `title_principals`;
DROP TABLE `title_principals1`;