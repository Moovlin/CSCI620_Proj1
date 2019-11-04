create table personx as
select sur.nconst, p.primary_name, p.birth_year, p.death_year
from persons p, surrogate_person sur
where p.birth_year = sur.birth_year and p.primary_name = sur.primary_name;

create view personx as
select sur.nconst, p.primary_name, p.birth_year, p.death_year, pro.profession
from persons p, surrogate_person sur, professions pro
where p.birth_year = sur.birth_year and p.primary_name = sur.primary_name and pro.primary_name = sur.primary_name and pro.birth_year = sur.birth_year limit 0,10000;

-- 1 (4sec)
create view movie_participate as
SELECT mov.movie_tconst, par.nconst, mov.release_year
FROM movie mov, participates par
where mov.`movie_tconst` = par.tconst;

SELECT per.`primary_name`
FROM personx per
WHERE per.`death_year` IS NULL
AND per.`primary_name` LIKE 'Phi%'
AND NOT EXISTS(
SELECT *
FROM movie_participate par
where par.nconst = per.nconst
AND par.`release_year` = 2014)
and exists(
select * from acts a
where a.nconst = per.nconst);

-- 2
SELECT per.`primary_name` as name
FROM personx per
WHERE per.`primary_name` LIKE '%e%'
AND per.`death_year` IS NULL
AND per.nconst IN (
 SELECT pro.nconst
 FROM producers pro, talkshow tak
 WHERE  pro.tconst = tak.tconst
  AND tak.`show_year` = 2014 
 group by pro.nconst
 having count(*) > 1
);

-- 3 (17sec)
SELECT AVG(gen.runtime)
FROM `general_movies` gen
WHERE title LIKE '%star%'
AND gen.type = 'movie'
AND gen.tconst IN (
SELECT tconst
FROM writers w
WHERE exists (
SELECT nconst
FROM personx per
WHERE per.`death_year` IS NULL
AND per.nconst = w.nconst)
);

-- 4 (19sec)
create view producer_movie_person as
select pro.nconst, pro.tconst, gen.title, gen.type, gen.runtime, per.primary_name, per.birth_year, per.death_year
from producers pro, general_movies gen, personx per
where pro.tconst = gen.tconst and pro.nconst = per.nconst;

select primary_name , max(runtime)
from producer_movie_person
where runtime > 120 and death_year is null
group by nconst, primary_name;

-- 5
create view tmp_act as 
select a.nconst, a.tconst, p.primary_name
from acts a, personx p
where a.nconst = p.nconst 
limit 0, 100000;

create view act_act as 
select act1.primary_name as a1, act2.primary_name as a2, act1.tconst
from tmp_act act1, tmp_act act2
where act1.tconst = act2.tconst 
and cast(substring(act1.nconst,3) as signed) > cast(substring(act2.nconst,3) as signed);

select distinct a.a1, a.a2, p.rating
from act_act a, previous_rating p 
where p.tconst = a.tconst
group by a.a1, a.a2, p.rating
having count(*) > 2
order by p.rating desc;

-- 6
select h.series_tconst, gen.title
from has h, tvepisode epi, general_movies gen
where h.episode_tconst = epi.episode_tconst and gen.tconst = h.series_tconst and gen.runtime = 90
and exists (
select *
from previous_rating previous
where h.series_tconst = previous.tconst and rating > 4)
group by h.series_tconst, gen.title
having count(*) > 5;

-- 7

Select distinct lo.local_name, per.primary_name, lo.lang  
from general_movies m, personx per, localize lo, acts act  
where act.nconst = per.nconst and lo.tconst = m.tconst and m.tconst = act.tconst
and m.type = 'movie' and lo.lang = 'en' 
and per.primary_name like '%a%';

-- 8
-- all the producer
select distinct per.primary_name
from producers pro, personx per
where pro.nconst = per.nconst
and exists (select *
from movie mov
where pro.tconst = mov.movie_tconst
and mov.release_year > per.death_year);

-- 9
create view act_name_birth as
select p.primary_name, p.nconst, p.birth_year, act.tconst
from acts act, personx p
where  p.nconst = act.nconst;

create view director_name_birth as
select p.primary_name, p.nconst, p.birth_year, dir.tconst
from directors dir, personx p
where  p.nconst = dir.nconst;

create view dir_act_mov as
select dir.birth_year as dir_birth, dir.nconst as dir_nconst, act.birth_year as act_birth, act.nconst as act_nconst, dir.tconst
from director_name_birth dir, act_name_birth act
where dir.tconst = act.tconst limit 0, 5000;

select distinct gen.title
from dir_act_mov a, general_movies gen
where a.dir_birth = a.act_birth
and gen.tconst = a.tconst
and not a.dir_nconst = a.act_nconst;

-- 10
select mov.title
from general_movies mov , generes gen
where mov.tconst = gen.tconst
and gen.genre like '%show%'
and mov.runtime < 10

