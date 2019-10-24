-- 1 (686sec)
SELECT per.`primary_name`
FROM persons per, surrogate_person sur
WHERE per.`primary_name`= sur.`primary_name`
AND per.`birth_year` = sur.`birth_year`
AND per.`death_year` IS NULL
AND per.`primary_name` LIKE 'Phi%'
AND sur.nconst NOT IN(
SELECT act.nconst
FROM movie mov, acts act
WHERE mov.`movie_tconst` = act.tconst
AND mov.`release_year` = 2014)
AND sur.nconst NOT IN(
SELECT par.nconst
FROM participates par, movie mov
WHERE mov.`movie_tconst` = par.tconst
AND mov.`release_year` = 2014);

-- 2
SELECT per.`primary_name` as name
FROM persons per, surrogate_person sur
WHERE per.`primary_name`= sur.`primary_name`
AND per.`birth_year` = sur.`birth_year`
AND per.`primary_name` LIKE '%Gill%'
AND per.`death_year` IS NULL
AND sur.nconst IN (
 SELECT par.nconst
 FROM participates par, talkshow tak
 WHERE par.tconst = tak.tconst
 AND par.category = 'producer'
 AND tak.`show_year` = 2017
 GROUP BY par.nconst
 HAVING COUNT(*) > 0
);

-- 3 (116sec)
SELECT AVG(gen.runtime)
FROM `general_movies` gen
WHERE title LIKE '%star%'
AND gen.type = 'movie'
AND gen.tconst IN (
SELECT tconst
FROM participates
WHERE category = 'writer'
AND nconst IN (
SELECT nconst
FROM surrogate_person sur, persons per
WHERE per.`primary_name`= sur.`primary_name`
AND per.`birth_year` = sur.`birth_year`
AND per.`death_year` IS NULL)
);


-- 9
SELECT mov.title
FROM `general_movies` mov, `participates` par, `surrogate_person` sur1, `persons` per1
WHERE mov.type='movie' AND par.category = 'director' AND mov.tconst = par.tconst AND par.nconst = sur1.nconst AND per1.`primary_name`= sur1.`primary_name` AND per1.`birth_year` = sur1.`birth_year`
AND per1.`birth_year` IN (
	SELECT per2.`birth_year`
	FROM `acts` act, `surrogate_person` sur2, `persons` per2
	WHERE mov.tconst = act.tconst AND act.nconst = sur2.nconst AND per2.`primary_name`= sur2.`primary_name` AND per2.`birth_year` = sur2.`birth_year` 
)

