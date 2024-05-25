CREATE TABLE country_vaccination_stats (
    country VARCHAR(255),
    date DATE,
    daily_vaccinations INT,
    vaccines VARCHAR(255)
);


BULK INSERT YourTableName
FROM "country_vaccination_stats.csv"
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 
);


-- First I created a CTE called MedianValues that has the 50th percentile of daily_vaccinations for each country.
WITH MedianValues AS (
    SELECT 
        country,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY daily_vaccinations) 
            OVER(PARTITION BY country) AS median_daily_vaccinations
    FROM 
        country_vaccination_stats
    WHERE 
        daily_vaccinations IS NOT NULL
)


-- Then updated the null values of country_vaccination stats with the median values.
UPDATE cvs
SET daily_vaccinations = (
    SELECT median_daily_vaccinations
    FROM MedianValues AS mv
    WHERE mv.country = cvs.country
)
FROM country_vaccination_stats AS cvs
INNER JOIN MedianValues AS mv ON cvs.country = mv.country
WHERE cvs.daily_vaccinations IS NULL;


-- I checked the number of null values left
SELECT COUNT(*) AS NullCount
FROM country_vaccination_stats
WHERE daily_vaccinations IS NULL;


-- The number of null values is zero. I checked the daily vaccination value of Kuwait.
SELECT *
FROM country_vaccination_stats
WHERE country = 'Kuwait';


