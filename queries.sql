-- Adavnced SQL project - SPOTIFY dataset
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);



-- EDA

select count(*) from spotify; --20594
select count(distinct artist) from spotify; --2074
select count(distinct track) from spotify; -- 17717
select count(distinct album) from spotify; --11854

select max(duration_min) from spotify; -- 77.9343
select artist, track, album, title from spotify where duration_min = 77.9343;

select min(duration_min) from spotify; -- 0
select artist, track, album, title from spotify where duration_min = 0;

-- delete 0 min songs
DELETE FROM spotify WHERE duration_min = 0;

SELECT DISTINCT most_played_on FROM spotify;

------------------------------------
-- EASY CATEGORY SQL PROBLEMS
------------------------------------

-- Retrieve the names of all tracks that have more than 1 billion streams.
SELECT * FROM spotify 
WHERE stream > 1000000000;

-- List all albums along with their respective artists.
SELECT DISTINCT Album, Artist 
FROM spotify ORDER BY 1;

-- Get the total number of comments for tracks where licensed = TRUE.
SELECT SUM(comments) as total_comments
FROM spotify WHERE licensed = TRUE;

-- Find all tracks that belong to the album type single.
SELECT * 
FROM spotify WHERE album_type = 'single';

-- Count the total number of tracks by each artist.
SELECT artist, COUNT(distinct track) as total_num_tracks
FROM spotify GROUP BY artist ORDER BY artist;

------------------------------------
-- MEDIUM CATEGORY SQL PROBLEMS
------------------------------------
-- Calculate the average danceability of tracks in each album.
SELECT DISTINCT album, AVG(danceability) 
FROM spotify GROUP BY 1 ORDER BY 2 DESC;

-- Find the top 5 tracks with the highest energy values.
SELECT * FROM spotify ORDER BY energy DESC LIMIT 5;
SELECT track, MAX(energy) as avg_track_energy 
FROM spotify GROUP BY 1 ORDER BY 2 DESC LIMIT 5;

-- List all tracks along with their views and likes where official_video = TRUE.
SELECT track, SUM(views) AS total_views, SUM(likes) as total_likes 
FROM spotify WHERE official_video = TRUE GROUP BY 1 ORDER BY 2;

-- For each album, calculate the total views of all associated tracks.
SELECT album, track, SUM(views) as total_views
FROM spotify GROUP BY 1, 2 ORDER BY 3 DESC;

-- Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT * 
FROM 
(SELECT 
track,
COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) AS stream_spotify,
COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) AS stream_youtube
FROM spotify GROUP BY 1) as subq
WHERE stream_spotify > stream_youtube AND stream_youtube != 0
ORDER BY track;


------------------------------------
-- HARD CATEGORY SQL PROBLEMS
------------------------------------

--Find the top 3 most-viewed tracks for each artist using window functions.
WITH ranking 
as (SELECT artist, track, SUM(views) AS total_views,
DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) as rank_tracks
FROM spotify 
GROUP BY 1, 2 
ORDER BY 1, 3 DESC) 


SELECT * 
FROM ranking
WHERE rank_tracks <=3;


--Write a query to find tracks where the liveness score is above the average.

SELECT artist, track, liveness 
FROM spotify 
WHERE liveness > (SELECT AVG(liveness) FROM spotify) ORDER BY 3 DESC;


--Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH energy as
(SELECT 
album,
MAX(energy) as highest_energy,
MIN(energy) as lowest_energy
FROM spotify GROUP BY 1)

SELECT album,
highest_energy - lowest_energy as energy_diff
FROM energy 
ORDER BY energy_diff DESC;
;


--Find tracks where the energy-to-liveness ratio is greater than 1.2.

WITH cte as
(
SELECT track, energy, liveness, energy/ NULLIF(liveness, 0) as E2L_ratio FROM spotify)
SELECT track, E2L_ratio  FROM cte WHERE E2L_ratio >1.20 ORDER BY E2L_ratio DESC;



-- Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
select track, likes, views,
SUM(likes) OVER(ORDER BY views ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as rolling_total
FROM spotify;



-- QUERY OPTIMIZATION
EXPLAIN ANALYZE
SELECT 
	artist, 
	track, 
	views
FROM spotify 
WHERE artist = 'Gorillaz' AND most_played_on = 'Youtube'
ORDER BY stream DESC LIMIT 25;

CREATE INDEX artist_index ON spotify(artist);




