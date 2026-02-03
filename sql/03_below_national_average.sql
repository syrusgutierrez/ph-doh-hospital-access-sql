WITH hospital_rate AS (
    SELECT 
        ddh.region,
        ROUND(COUNT(ddh.facility) * 1000000.0 / dpr.total_population, 2) AS hospitals_per_million
    FROM dim_doh_hospital ddh 
    JOIN dim_population_region dpr 
        ON ddh.region = dpr.region
    GROUP BY ddh.region, dpr.total_population
),
national_avg AS (
    SELECT
        (ROUND(AVG(hospitals_per_million), 2)) AS avg_hospitals_per_million
    FROM hospital_rate
)
SELECT
    hr.region,
    hr.hospitals_per_million
FROM hospital_rate hr
JOIN national_avg na 
    ON hr.hospitals_per_million < na.avg_hospitals_per_million;
