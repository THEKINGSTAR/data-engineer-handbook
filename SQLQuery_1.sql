select  * from public.player_seasons;

CREATE TYPE seasons_stats AS (
    season INTEGER,
    gp INTEGER,
    pts REAL,
    reb REAL,
    ast REAL
);

CREATE TABLE players(
    player_name TEXT,
    height TEXT,
    collage TEXT,
    draft_year TEXT,
    draft_round TEXT,
    draft_number TEXT,
    seasons_stats seasons_stats[],
    current_season INTEGER,
    PRIMARY KEY(player_name, current_season)
);