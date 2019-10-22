-- general movie 
INSERT INTO `general_movies`
SELECT old.tconst, old.oTitle, CAST(old.isAdult AS signed), old.`title-type`, CAST(old.runtimeMinutes AS signed)
FROM `title_basics1` old;

-- persons
INSERT INTO `persons`
SELECT old.primaryName, CAST(old.birthYear AS signed), CAST(old.deathYear AS signed)
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

-- acts
INSERT ignore INTO acts1
SELECT tconst, nconst, characters
FROM `title_principals1`;

INSERT ignore INTO act2
SELECT a.tconst, b.primaryName, CAST(b.birthYear AS signed), substring(a.characters,3,LENGTH(a.characters)-4)
FROM acts1 a 
left join 
`name_basics1` b
on a.nconst = b.nconst
LIMIT 0, 1000;

INSERT ignore INTO acts
select a.`name`,a.`birthYear`,a.`tconst`,substring_index(substring_index(a.characters,'","',b.`help_topic_id`+1),'","',-1) 
from `act2` a
join
mysql.`help_topic` b
on b.`help_topic_id` < (length(a.characters) - length(replace(a.characters,'","',''))+1)
order by a.`name`,a.`birthYear`,a.`tconst`;

-- participates
INSERT IGNORE INTO `participates`
SELECT b.primaryName, CAST(b.birthYear AS signed), a.tconst, a.category, a.job
FROM `title_principals2` a, `name_basics1` b
where a.nconst = b.nconst
LIMIT 0, 1000;

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

-- users
INSERT INTO users(uid)
SELECT substring(tconst,3)
FROM `title_ratings`;

-- ratings
INSERT ignore INTO `previous_rating`
SELECT tconst, convert(aveRating, decimal(2,1)), cast(numVote as signed)
FROM `title_ratings`;
