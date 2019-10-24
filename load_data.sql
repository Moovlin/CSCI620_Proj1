CREATE TABLE name_basics (
  nconst varchar(45) NOT NULL,
  primaryName longtext,
  birthYear varchar(45) DEFAULT NULL,
  deathYear varchar(45) DEFAULT NULL,
  primaryProfession longtext,
  knownForTitles longtext,
  PRIMARY KEY (nconst)
) ;

CREATE TABLE title_akas (
  titleId varchar(80) NOT NULL,
  ordering varchar(45) NOT NULL,
  title longtext,
  region varchar(45) DEFAULT NULL,
  language varchar(45) DEFAULT NULL,
  types longtext,
  attributes longtext,
  isOriginal varchar(45) DEFAULT NULL,
  PRIMARY KEY (titleId,ordering)
) ;

CREATE TABLE title_basics (
  tconst varchar(80) NOT NULL,
  title_type varchar(80) DEFAULT NULL,
  pTitle longtext,
  oTitle varchar(600) DEFAULT NULL,
  isAdult varchar(45) DEFAULT NULL,
  startYear varchar(45) DEFAULT NULL,
  endYear varchar(45) DEFAULT NULL,
  runtimeMinutes varchar(45) DEFAULT NULL,
  genres varchar(180) DEFAULT NULL,
  PRIMARY KEY (tconst)
) ;

CREATE TABLE title_episodes (
  tconst varchar(80) NOT NULL,
  parentTconst varchar(80) DEFAULT NULL,
  seasonNumber varchar(45) DEFAULT NULL,
  episodeNumber varchar(45) DEFAULT NULL,
  PRIMARY KEY (tconst)
) ;

CREATE TABLE title_principals (
  tconst varchar(80) NOT NULL,
  ordering varchar(45) NOT NULL,
  nconst varchar(45) NOT NULL,
  category varchar(80) DEFAULT NULL,
  job longtext,
  characters longtext,
  PRIMARY KEY (tconst,ordering,nconst)
) ;

CREATE TABLE title_ratings (
  tconst varchar(256) NOT NULL,
  aveRating varchar(45) DEFAULT NULL,
  numVote varchar(45) DEFAULT NULL,
  PRIMARY KEY (tconst)
) ;

LOAD DATA INFILE '/var/lib/mysql-files/titleBasic.tsv' INTO TABLE title_basics
FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA INFILE '/var/lib/mysql-files/name.tsv' INTO TABLE name_basics
FIELDS TERMINATED BY '\t' 
LINES TERMINATED BY '\n' IGNORE 1 LINES
(@col1,@col2,@col3,@col4,@col5,@col6) 
set nconst=nullif(@col1,''), 
	primaryName=nullif(@col2,''), 
    birthYear=nullif(@col3,''),
    deathYear=nullif(@col4,''), 
    primaryProfession=nullif(@col5,''), 
    knownForTitles=nullif(@col6,'');

LOAD DATA INFILE '/var/lib/mysql-files/titleAkas.tsv' INTO TABLE title_akas
FIELDS TERMINATED BY '\t' 
LINES TERMINATED BY '\n' IGNORE 1 LINES
(@col1,@col2,@col3,@col4,@col5,@col6,@col7,@col8) 
set titleId=nullif(@col1,''), 
	ordering=nullif(@col2,''), 
    title=nullif(@col3,''),
    region=nullif(@col4,''), 
    language=nullif(@col5,''), 
    types=nullif(@col6,''),
    attributes=nullif(@col7,''),
    isOriginal=nullif(@col8,'');
    
LOAD DATA INFILE '/var/lib/mysql-files/episode.tsv' INTO TABLE title_episodes
FIELDS TERMINATED BY '\t' 
LINES TERMINATED BY '\n' IGNORE 1 LINES
(@col1,@col2,@col3,@col4) 
set tconst=nullif(@col1,''), 
	parentTconst=nullif(@col2,''), 
    seasonNumber=nullif(@col3,''),
    episodeNumber=nullif(@col4,'');

LOAD DATA INFILE '/var/lib/mysql-files/principals.tsv' INTO TABLE title_principals
FIELDS TERMINATED BY '\t' 
LINES TERMINATED BY '\n' IGNORE 1 LINES
(@col1,@col2,@col3,@col4,@col5,@col6) 
set tconst=nullif(@col1,''), 
	ordering=nullif(@col2,''), 
    nconst=nullif(@col3,''),
    category=nullif(@col4,''),
    job=nullif(@col5,''), 
    characters=nullif(@col6,''); 

LOAD DATA INFILE '/var/lib/mysql-files/ratings.tsv' INTO TABLE title_ratings
FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES;
