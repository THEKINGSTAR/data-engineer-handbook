-- EXAMINING THE DATA_SET
SELECT * from actor_films ;


CREATE TYPE quality_class AS ENUM ('star', 'good', 'average', 'bad');


CREATE TYPE  films AS (
    film TEXT,
    votes INTEGER,
    rating REAL,
    filmid INTEGER
);

-- Drop and recreate the actors table
DROP TABLE IF EXISTS actors;

CREATE TABLE IF NOT EXISTS actors(
    actor TEXT,
    actorid INTEGER PRIMARY KEY,
    films films[],
    quality_class  quality_class,
    is_active BOOLEAN
);

-- SELECT MIN(year) FROM actor_films;
--------------------------------------------------------


--------------------------------------------------------
-- Populate the actors table
INSERT INTO actors (actor, actorid, quality_class)
WITH preview_year AS (
    SELECT * FROM actor_films
    WHERE year = 1970
),
next_year AS (
    SELECT * FROM actor_films
    WHERE year = 1971
)
SELECT 
    COALESCE(pre.actor, nex.actor) AS actor,
    COALESCE(pre.actorid, nex.actorid) AS actorid,
    CASE
        WHEN nex.rating IS NOT NULL THEN
            CASE
                WHEN nex.rating > 8 THEN 'star'
                WHEN nex.rating > 7 THEN 'good'
                WHEN nex.rating > 6 THEN 'average'
                ELSE 'bad'
            END
        ELSE 
            CASE
                WHEN pre.rating > 8 THEN 'star'
                WHEN pre.rating > 7 THEN 'good'
                WHEN pre.rating > 6 THEN 'average'
                ELSE 'bad'
            END
    END::quality_class
FROM preview_year AS pre
FULL OUTER JOIN next_year AS nex
ON pre.actorid = nex.actorid;