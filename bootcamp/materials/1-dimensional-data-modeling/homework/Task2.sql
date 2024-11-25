INSERT INTO actors
WITH last_year AS (
    SELECT 
        actor, 
        actorid, 
        year, 
        filmsdata, 
        quality_class, 
        is_active
    FROM actors
    WHERE year = 1970
), 

this_year AS (
    SELECT 
        actor, 
        actorid, 
        year,
        array_agg(ARRAY[ROW(
						film,
						votes,
					    rating,
					    filmid)::films_data]) AS filmsdata, 
                        ROUND(CAST(AVG(rating) AS numeric), 2) AS avg_rating 
    FROM actor_films
    WHERE year = 1971
    GROUP BY actor, actorid, year
)

SELECT
    COALESCE(ls.actor, ts.actor) AS actor,
    COALESCE(ls.actorid, ts.actorid) AS actorid,
    COALESCE(ts.year, ls.year + 1) AS year,
    COALESCE(ls.filmsdata, ARRAY[]::films_data[])||  
    CASE 
     WHEN ts.year IS NOT NULL THEN ts.filmsdata
     ELSE ARRAY[]::films_data[] END AS filmsdata,
	CASE 
     WHEN ts.year IS NOT NULL THEN
	   (CASE WHEN ts.avg_rating > 8 THEN 'star'
        WHEN ts.avg_rating BETWEEN 7 AND 8 THEN 'good'
        WHEN ts.avg_rating BETWEEN 6 AND 7 THEN 'average'
        ELSE 'bad'END)::quality_class_type 
	  ELSE ls.quality_class
     END AS qualityclass, 
    ts.year IS NOT NULL AS is_active
FROM last_year ls
FULL OUTER JOIN this_year ts
ON ls.actor = ts.actor;


