SELECT 
    ddh.region,
    dpr.total_population,
    ROUND(COUNT(ddh.facility) * 1000000.0 / dpr.total_population, 2) AS hospitals_per_million
FROM dim_doh_hospital ddh 
JOIN dim_population_region dpr 
    ON ddh.region = dpr.region
GROUP BY ddh.region, dpr.total_population;
