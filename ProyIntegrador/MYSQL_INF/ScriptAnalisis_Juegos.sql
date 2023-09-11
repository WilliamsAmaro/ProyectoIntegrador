CREATE SCHEMA integrador;
USE integrador;
CREATE TABLE JuegoSteam (
    appid INT PRIMARY KEY,
    release_date DATE,
    english INT,
    platforms VARCHAR(255),
    required_age INT,
    positive_ratings INT,
    negative_ratings INT,
    average_playtime INT,
    median_playtime INT,
    Min_Owner INT,
    Max_Owner INT,
    price DECIMAL(10, 2)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Juesgo.csv'
INTO TABLE JuegoSteam
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@appid, @release_date, @english, @platforms, @required_age, @positive_ratings, @negative_ratings, @average_playtime, @median_playtime, @Min_Owner, @Max_Owner, @price)
SET
    appid = @appid,
    release_date = CASE
        WHEN @release_date = '000' THEN NULL  -- Cambia '000' a NULL o a otra fecha válida si es necesario
        ELSE STR_TO_DATE(@release_date, '%m/%d/%Y')
		END,
    english = CASE
        WHEN @english IN ('0', '1') THEN @english  -- Acepta solo valores 0 o 1
        ELSE NULL  -- Cambia a NULL si no es 0 ni 1
    END,
    platforms = @platforms,
    required_age = @required_age,
    positive_ratings = @positive_ratings,
    negative_ratings = @negative_ratings,
    average_playtime = @average_playtime,
    median_playtime = @median_playtime,
    Min_Owner = @Min_Owner,
    Max_Owner = @Max_Owner,
    price = @price;

-- CONSULTAS
#Valoración Promedio (Rating) de los Juegos: Calcula la valoración promedio de los juegos, tomando en cuenta las valoraciones positivas y negativas.
SELECT platforms, AVG(positive_ratings - negative_ratings) AS avg_rating FROM JuegoSteam group by platforms;

#Relación entre Valoraciones Positivas y Negativas: Calcula la relación entre las valoraciones positivas y negativas para entender la satisfacción general de los jugadores.
SELECT platforms, AVG(positive_ratings / negative_ratings) AS rating_ratio FROM JuegoSteam group by platforms;

# Popularidad de Juegos por plataforma: Encuentra los juegos más populares en términos de valoraciones positivas

SELECT platforms, appid, positive_ratings FROM JuegoSteam ORDER BY positive_ratings DESC LIMIT 10;

# Juegos con Mayor Duración de Juego: Identifica los juegos con el mayor tiempo de juego promedio.

#SELECT platforms, appid, median_playtime as Tiempo_Promedio_Minutos, AVG(positive_ratings / negative_ratings) AS rating_ratio FROM JuegoSteam ORDER BY rating_ratio DESC LIMIT 10;

SELECT platforms, appid, median_playtime as Tiempo_Promedio_Minutos, positive_ratings as Rating FROM JuegoSteam 
WHERE median_playtime > (SELECT AVG(median_playtime) FROM JuegoSteam)
AND positive_ratings > (SELECT AVG(positive_ratings) FROM JuegoSteam) order by Tiempo_Promedio_Minutos desc limit 10;


# Rango de Precios de los Juegos: Determina el rango de precios de los juegos.
SELECT platforms, MIN(price) AS min_price, MAX(price) AS max_price FROM JuegoSteam group by platforms;

# Distribución de Plataformas: Visualiza la distribución de juegos en diferentes plataformas.
SELECT platforms, COUNT(*) AS count FROM JuegoSteam GROUP BY platforms;

# Edad Promedio de los Jugadores: Calcula la edad promedio de los jugadores para tener una idea de tu audiencia.
SELECT AVG(required_age) AS avg_age FROM JuegoSteam;

# Precio vs. Valoración: Examina si existe una correlación entre el precio de un juego y sus valoraciones.
SELECT platforms, price, (positive_ratings - negative_ratings) AS rating_diff FROM JuegoSteam order by rating_diff desc limit 10;

# Número de Juegos por Año de Lanzamiento: Agrupa los juegos por año de lanzamiento y calcula cuántos se lanzaron en cada año.
SELECT YEAR(release_date) AS year, COUNT(*) AS count FROM JuegoSteam GROUP BY year;












