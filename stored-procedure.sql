USE moviedb;

DELIMITER $$

CREATE PROCEDURE add_movie (IN mTitle VARCHAR(100), IN mYear INT, IN mDirect VARCHAR(100), IN sName VARCHAR(100), IN mGenre VARCHAR(25))
BEGIN
	DECLARE starID VARCHAR(10);
    DECLARE temp INT;
    DECLARE movieID VARCHAR(10);
    DECLARE genreID INT;
    DECLARE returnMessage VARCHAR(100);

    IF EXISTS (SELECT 1 FROM movies WHERE movies.title = mTitle AND movies.year = mYear AND movies.director = mDirect) THEN
        SELECT 'Movie Exists' AS message;
    ELSE
		-- Generate movieID;
        SET temp = (SELECT (CAST((SELECT SUBSTRING((SELECT max(movies.id) FROM movies), 3)) AS UNSIGNED) + 1));
        SET movieID = CONCAT('tt', LPAD(temp, 7, '0'));
        INSERT INTO movies (id, title, year, director) VALUES (movieID, mTitle, mYear, mDirect);

    -- Determine starID
    IF EXISTS (SELECT 1 FROM stars WHERE UPPER(stars.name) = UPPER(sName)) THEN
                SET starID = (SELECT stars.id FROM stars WHERE UPPER(stars.name) = UPPER(sName) LIMIT 1);
    ELSE
                SET starID = CONCAT('nm', (SELECT (CAST((SELECT SUBSTRING((SELECT max(stars.id) FROM stars WHERE stars.id like 'nm%'), 3)) AS UNSIGNED) + 1)));
                -- Insert stars
    INSERT INTO stars(id, name) VALUES (starID, sName);
    END IF;


	-- Determine genreID
    IF EXISTS (SELECT 1 FROM genres WHERE UPPER(genres.name) = UPPER(mGenre)) THEN
		SET genreID = (SELECT genres.id FROM genres WHERE UPPER(genres.name) = UPPER(mGenre));
    ELSE
                SET genreID = ((SELECT max(genres.id) FROM genres) + 1);
                -- Insert genres
    INSERT INTO genres (id, name) VALUES (genreID, mGenre);
    END IF;

    INSERT INTO stars_in_movies (starID, movieID) VALUES (starID, movieID);
    INSERT INTO genres_in_movies (genreId, movieID) VALUES (genreID, movieID);
    INSERT INTO ratings (movieID, rating, numVotes) VALUES (movieID, 0.0, 0);
    SELECT 'Movie has been added' AS message, movieID AS movie_id, genreID AS genre_id, starID AS starID;
    END IF;
END
$$

DELIMITER ;

SHOW PROCEDURE STATUS WHERE db = 'moviedb';