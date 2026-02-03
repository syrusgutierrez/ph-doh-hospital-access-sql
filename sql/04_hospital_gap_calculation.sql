WITH hospital_rate AS (
    SELECT 
        ddh.region,
        dpr.total_population,
        ROUND(COUNT(ddh.facility) * 1000000.0 / dpr.total_population, 2) AS hospitals_per_million
    FROM dim_doh_hospital ddh 
    JOIN dim_population_region dpr 
        ON ddh.region = dpr.region
    GROUP BY 1, dpr.total_population
),

national_avg AS (
    SELECT
        (ROUND(AVG(hospitals_per_million), 2)) AS avg_hospitals_per_million
    FROM hospital_rate hr
),

lowest_region AS (
    SELECT
        hr.region,
        hr.hospitals_per_million,
        na.avg_hospitals_per_million
    FROM hospital_rate hr 
    JOIN national_avg na 
        ON hr.hospitals_per_million < na.avg_hospitals_per_million
    ORDER BY 2 ASC 
    LIMIT 1
)

SELECT 
    lr.region,
    ((lr.avg_hospitals_per_million * hr.total_population / 1000000) 
    - (lr.hospitals_per_million * hr.total_population / 1000000)) AS needed_hospitals
FROM lowest_region lr 
JOIN hospital_rate hr 
    ON lr.region = hr.region;
