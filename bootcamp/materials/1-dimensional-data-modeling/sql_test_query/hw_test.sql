
CREATE TYPE film_struct AS (
    film TEXT,
    votes INTEGER,
    rating REAL,
    filmid INTEGER
);

CREATE TYPE quality_class AS ENUM ('star', 'good', 'average', 'bad');

CREATE TABLE actors (
    actor_name TEXT NOT NULL,
    actor_id TEXT PRIMARY KEY,
    films film_struct[],
    quality_class quality_class,
    is_active BOOLEAN
);



WITH films_by_actor AS (
    SELECT
        actor,
        actorid,
        ARRAY_AGG(ROW(film, votes, rating, filmid)::film_struct) AS films,
        AVG(rating) AS avg_rating,
        MAX(year) AS last_year
    FROM actor_films
    WHERE year = 1970 -- Replace with the desired year for cumulative population
    GROUP BY actor, actorid
)
INSERT INTO actors (actor_name, actor_id, films, quality_class, is_active)
SELECT
    actor AS actor_name,
    actorid AS actor_id,
    films,
    CASE
        WHEN avg_rating > 8 THEN 'star'
        WHEN avg_rating > 7 THEN 'good'
        WHEN avg_rating > 6 THEN 'average'
        ELSE 'bad'
    END AS quality_class,
    last_year = EXTRACT(YEAR FROM CURRENT_DATE) AS is_active
FROM films_by_actor;




CREATE TABLE actors_history_scd (
    actor_id TEXT NOT NULL,
    quality_class quality_class,
    is_active BOOLEAN,
    start_date DATE NOT NULL,
    end_date DATE,
    PRIMARY KEY (actor_id, start_date)
);










INSERT INTO actors_history_scd (actor_id, quality_class, is_active, start_date, end_date)
SELECT
    actor_id,
    quality_class,
    is_active,
    '1970-01-01'::DATE AS start_date, -- Replace with the earliest dataset year
    NULL AS end_date -- Current record has no end_date
FROM actors;



















WITH new_data AS (
    SELECT
        actor_id,
        quality_class,
        is_active
    FROM actors
),
updates AS (
    -- Close current records for actors with changes
    UPDATE actors_history_scd
    SET end_date = CURRENT_DATE
    WHERE actor_id IN (SELECT actor_id FROM new_data)
      AND (quality_class, is_active) IS DISTINCT FROM (SELECT quality_class, is_active FROM new_data WHERE new_data.actor_id = actors_history_scd.actor_id)
    RETURNING actor_id
)
-- Insert new records for updated actors
INSERT INTO actors_history_scd (actor_id, quality_class, is_active, start_date, end_date)
SELECT
    actor_id,
    quality_class,
    is_active,
    CURRENT_DATE AS start_date,
    NULL AS end_date
FROM new_data
WHERE actor_id IN (SELECT actor_id FROM updates);
