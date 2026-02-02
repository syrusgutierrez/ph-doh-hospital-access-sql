WITH hospital_rate AS (
    SELECT 
        ddh.region,
        dpr.total_population,
        COUNT(ddh.facility) AS hospital_count,
        (COUNT(ddh.facility) * 1000000 / dpr.total_population) AS hospitals_per_million
    FROM dim_doh_hospital ddh 
    JOIN dim_population_region dpr 
        ON ddh.region = dpr.region
    GROUP BY ddh.region, dpr.total_population
),

national_avg AS (
    SELECT
        AVG(hr.hospitals_per_million) AS avg_hospitals_per_million,
        AVG(hr.hospital_count) AS avg_hospital_count
    FROM hospital_rate hr
),

lowest_region AS (
    SELECT
        hr.region,
        hr.hospitals_per_million,
        hr.hospital_count,
        na.avg_hospital_count,
        na.avg_hospitals_per_million
    FROM hospital_rate hr 
    JOIN national_avg na 
        ON hr.hospitals_per_million < na.avg_hospitals_per_million
    ORDER BY hr.hospitals_per_million ASC
)

SELECT 
    lr.region,
    hr.hospital_count,
    lr.avg_hospital_count
FROM hospital_rate hr 
JOIN lowest_region lr 
    ON hr.region = lr.region
WHERE hr.hospital_count < lr.avg_hospital_count;
