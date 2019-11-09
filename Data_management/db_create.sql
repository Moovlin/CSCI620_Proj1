create database group3_movies;
use group3_movies;

create table users(
uid int primary key auto_increment,
passwd varchar(256),
age int,
lang varchar(3)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `general_movies` (
  `tconst` varchar(30) NOT NULL,
  `title` varchar(512) DEFAULT NULL,
  `isAdult` tinyint(1) DEFAULT NULL,
  `type` varchar(32) DEFAULT NULL,
  `runtime` int(8) DEFAULT NULL,
  PRIMARY KEY (`tconst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table history(
uid int,
tconst varchar(30),
watchDate DATETIME,
primary key (uid, tconst),
foreign key (uid) references users(uid),
foreign key (tconst) references general_movies(tconst)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table rating(
uid int,
tconst varchar(30),
rating int, 
isVote bool, 
primary key (uid, tconst),
foreign key (tconst) references general_movies(tconst),
foreign key (uid) references users(uid),
check (rating > 0 and rating <= 10)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `previous_rating` (
  `tconst` varchar(30) NOT NULL,
  `rating` decimal(2,1) DEFAULT NULL,
  `numVote` int(11) DEFAULT NULL,
  PRIMARY KEY (`tconst`),
  CONSTRAINT `a` FOREIGN KEY (`tconst`) REFERENCES `general_movies` (`tconst`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table generes(
tconst varchar(30),
genre varchar(30),
foreign key (tconst) references general_movies(tconst)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table localize(
tconst varchar(30),
local_name varchar(512),
lang varchar(3),
isOriginal bool,
primary key (tconst, local_name, lang),
foreign key (tconst) references general_movies(tconst)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table tvSeries(
series_tconst varchar(30),
isOver bool,
primary key (series_tconst),
foreign key (series_tconst) references general_movies(tconst)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table tvEpisode(
episode_tconst varchar(30),
episode_number int,
primary key (episode_tconst),
foreign key (episode_tconst) references general_movies(tconst)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table has(
series_tconst varchar(30),
episode_tconst varchar(30),
season_number int,
broadcast_year int,
primary key (series_tconst, episode_tconst),
foreign key (episode_tconst) references general_movies(tconst),
foreign key (series_tconst) references general_movies(tconst)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `movie` (
  `movie_tconst` varchar(30) NOT NULL,
  `release_year` int(11) DEFAULT NULL,
  PRIMARY KEY (`movie_tconst`),
  
CONSTRAINT `movie_ibfk_1` FOREIGN KEY (`movie_tconst`) REFERENCES `general_movies` (`tconst`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table videoGame(
game_tconst varchar(30),
sells_year int, 
primary key (game_tconst),
foreign key (game_tconst) references general_movies(tconst)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table new(
news_tconst varchar(30),
primary key (news_tconst), 
foreign key (news_tconst) references general_movies(tconst)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table persons(
primary_name varchar(256),
birth_year int,
death_year int,
primary key (primary_name, birth_year)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table professions(
primary_name varchar(256),
birth_year int,
profession varchar(256),
primary key (primary_name, birth_year, profession),
foreign key (primary_name, birth_year) references persons(primary_name, birth_year)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table acts(
act_name varchar(256),
birth_year int,
movie_tconst varchar(30),
character_name varchar(256),
primary key (act_name, birth_year, movie_tconst, character_name),
foreign key (act_name, birth_year) references persons(primary_name, birth_year),
foreign key (movie_tconst) references general_movies(tconst)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table participates(
act_name varchar(256),
birth_year int,
movie_tconst varchar(30),
category varchar(128),
job varchar(128),
primary key (act_name, birth_year, movie_tconst),
foreign key (act_name, birth_year) references persons(primary_name, birth_year),
foreign key (movie_tconst) references general_movies(tconst)) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table hosts(
news_tconst varchar(30),
host_nconst varchar(256),
role varchar(512),
primary key (news_tconst, host_nconst, role),
foreign key (news_tconst) references general_movies(tconst)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
Error Code: 1822. Failed to add the foreign key constraint. Missing index for constraint 'hosts_ibfk_2' in the referenced table 'surrogate_person'
