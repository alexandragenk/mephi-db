-- 2.1

WITH tempAverages AS (
    SELECT 
        c.name AS car_name,
        c.class AS car_class,
        ROUND(AVG(r.position), 4) AS average_position,
        COUNT(r.race) AS race_count
    FROM cars c
    JOIN results r ON c.name = r.car
    GROUP BY c.name, c.class
),
tempMinAverage AS (
    SELECT 
        car_class,
        MIN(average_position) AS min_average_position
    FROM tempAverages
    GROUP BY car_class
)
SELECT 
    ta.car_name,
    ta.car_class,
    ta.average_position AS average_position,
    ta.race_count
FROM tempAverages ta
JOIN tempMinAverage tma ON ta.car_class = tma.car_class
              AND ta.average_position = tma.min_average_position
ORDER BY ta.average_position;

-- 2.2

WITH tempAverages AS (
    SELECT 
        c.name AS car_name,
        c.class AS car_class,
        ROUND(AVG(r.position), 4) AS average_position,
        COUNT(r.race) AS race_count
        
    FROM cars c
    JOIN results r ON c.name = r.car
    GROUP BY c.name, c.class
 ),
tempMinAverage AS (
    SELECT 
        MIN(average_position) AS min_avg_position
    FROM tempAverages 
)
SELECT 
    ta.car_name,
    ta.car_class,
    ta.average_position,
    ta.race_count,
    cl.country
FROM tempAverages ta
JOIN tempMinAverage tma ON ta.average_position = tma.min_avg_position
JOIN Classes cl ON ta.car_class = cl.class
ORDER BY ta.car_name
LIMIT 1;
 
-- 2.3

WITH tempAverages AS (
    SELECT 
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
        
    FROM cars c
    JOIN results r ON c.name = r.car
    GROUP BY c.name, c.class
 ),
tempMinAverage AS (
    SELECT MIN(average_position) AS min_avg_position
    FROM tempAverages
), 
tempClasses AS (
    SELECT ta.car_class, ta.average_position, ta.race_count
    FROM tempAverages ta
    JOIN tempMinAverage ma ON ta.average_position = ma.min_avg_position
)
SELECT 
    ca.car_name,
    ca.car_class,
    ca.average_position,
    ca.race_count,
    (SELECT cl.country 
     FROM Classes cl 
     WHERE cl.class = ca.car_class) AS country,
    (SELECT sc.race_count 
     FROM tempClasses sc 
     WHERE sc.car_class = ca.car_class) AS total_races
FROM (
    SELECT 
        c.name AS car_name,
        c.class AS car_class,
        ROUND(AVG(r.position), 4) AS average_position,
        COUNT(r.race) AS race_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
) ca
WHERE ca.car_class IN (SELECT car_class FROM tempClasses)
ORDER BY ca.average_position, ca.car_name;

-- 2.4

WITH tempAverages AS (
    SELECT 
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
        
    FROM cars c
    JOIN results r ON c.name = r.car
    GROUP BY c.name, c.class
 ),
tempClasses AS (
    SELECT 
        c.class AS car_class,
        AVG(r.position) AS average_class_position,
        COUNT(DISTINCT c.name) AS car_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.class
)
SELECT 
    ta.car_name,
    ta.car_class,
    ROUND(ta.average_position, 4) AS average_position,
    ta.race_count,
    cl.country AS car_country
FROM tempAverages ta
JOIN tempClasses tc ON ta.car_class = tc.car_class
JOIN Classes cl ON ta.car_class = cl.class
WHERE ta.average_position < tc.average_class_position  
  AND tc.car_count > 1  
ORDER BY ta.car_class,ta.average_position;

-- 2.5

WITH tempAverages AS (
    SELECT 
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
),
tempPosition AS (
    SELECT 
        ta.car_name,
        ta.car_class,
        ta.average_position,
        ta.race_count
    FROM tempAverages ta
    WHERE ta.average_position > 3.0
),
tempRaces AS (
    SELECT 
        c.class AS car_class,
        COUNT(r.race) AS total_race_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.class
),
tempCounter AS (
    SELECT 
        tp.car_class,
        COUNT(tp.car_name) AS low_position_count
    FROM tempPosition tp
    GROUP BY tp.car_class
)
SELECT 
    tp.car_name,
    tp.car_class,
    ROUND(tp.average_position, 4) AS average_position,
    tp.race_count,
    cl.country,
    tr.total_race_count,
    tc.low_position_count
FROM tempPosition tp
JOIN tempCounter tc ON tp.car_class = tc.car_class
JOIN Classes cl ON tp.car_class = cl.class
JOIN tempRaces tr ON tp.car_class = tr.car_class
ORDER BY tp.average_position DESC, tc.low_position_count DESC;