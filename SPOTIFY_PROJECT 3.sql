-- Advance SQL Project -- Spotify Dataset
-- create table
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
ALTER TABLE public.spotify
ALTER COLUMN likes TYPE NUMERIC
USING likes::NUMERIC;


ALTER TABLE public.spotify
ALTER COLUMN likes TYPE NUMERIC USING likes::NUMERIC,
ALTER COLUMN views TYPE NUMERIC USING views::NUMERIC,
ALTER COLUMN comments TYPE NUMERIC USING comments::NUMERIC,
ALTER COLUMN stream TYPE NUMERIC USING stream::NUMERIC;

select * from public.spotify
limit 100

-- EDA 
SELECT COUNT(*) from spotify;
SELECT COUNT(DISTINCT Artist) from spotify;
SELECT COUNT(DISTINCT Album) from spotify;

SELECT MAX(duration_min) FROM spotify;
SELECT MIN(duration_min) FROM spotify;

DELETE FROM spotify
WHERE duration_min = 0;
SELECT * FROM spotify
WHERE duration_min = 0;

SELECT DISTINCT most_played_on FROM spotify;

-----------------------------------------
-- QUESTION -- BASIC
_________________________________________

-- Q. 1 Retrieve the names of all tracks that have more than 1 billion streams.
SELECT * FROM spotify
WHERE stream > 1000000000;

-- Q. 2 List all albums along with their respective artists.
SELECT 
    DISTINCT album, artist
FROM spotify
ORDER BY 1;

-- Q. 3 Get the total number of comments for tracks where licensed = TRUE.
--SELECT DISTINCT licensed FROM spotify

SELECT SUM(Comments) as total_comments
FROM spotify
WHERE licensed = 'True';

--Q. 4 Find all tracks that belong to the album type single.
SELECT * FROM spotify
WHERE album_type ILIKE 'single';

--Q. 5 Count the total number of tracks by each artist.
SELECT 
    artist,  
	COUNT(*) as total_no_songs 
FROM spotify
GROUP BY artist
ORDER BY 2 ASC

-----------------------------------------
-- QUESTIONS -- MEDIUM
_________________________________________

-- Q. 1 Calculate the average danceability of tracks in each album.
SELECT
   album,
   avg(danceability) as avg_dancebility
FROM spotify
GROUP BY 1
ORDER BY 2 DESC

-- Q. 2 Find the top 5 tracks with the highest energy values.
SELECT 
   track,
   MAX(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- Q. 3 List all tracks along with their views and likes where official_video = TRUE.
SELECT 
   track,
   SUM(views) as total_views,
   SUM(likes) as total_likes
FROM spotify
WHERE
official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- Q. 4 For each album, calculate the total views of all associated tracks.
SELECT 
   album,
   track,
   SUM(views)
FROM spotify
GROUP BY 1, 2
ORDER BY 3 DESC

-- Q. 5 Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM
(SELECT 
     track,
	 --most_played_on,
	 COALESCE(SUM(CASE WHEN most_played_on ='Youtube' THEN stream END),0) as streamed_on_youtube,
	 COALESCE(SUM(CASE WHEN most_played_on ='Spotify' THEN stream END),0) as streamed_on_spotify
FROM spotify
GROUP BY 1) as t1
WHERE 
streamed_on_spotify > streamed_on_youtube
   AND
   streamed_on_youtube <> 0


-----------------------------------------
-- QUESTIONS -- ADVANCE
_________________________________________

-- Q. 1 Find the top 3 most-viewed tracks for each artist using window functions.

-- each artist and total view for each track
WITH ranking_artist
AS
(SELECT
   artist,
   track,
   SUM(views) as total_view,
   DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) as rank
FROM spotify
GROUP BY 1, 2
ORDER BY 1, 3 DESC
)
SELECT * FROM ranking_artist
where rank <= 3

-- Q. 2 Write a query to find tracks where the liveness score is above the average.
SELECT  
   track,
   artist,
   liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)

-- Q. 3 Use a WITH clause to calculate the difference between the highest and lowest 
-- energy values for tracks in each album.

WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC

-- Q. 4 Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT
    Artist,
    Track,
    Energy,
    Liveness,
    Energy / Liveness AS energy_liveness_ratio
FROM spotify
WHERE Energy / Liveness > 1.2;

-- Q. 5 Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.


SELECT
    Artist,
    Track,
    Views,
    Likes,
    SUM(Likes) OVER (
        ORDER BY Views DESC
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS cumulative_likes
FROM spotify;


-- END PROJECT

