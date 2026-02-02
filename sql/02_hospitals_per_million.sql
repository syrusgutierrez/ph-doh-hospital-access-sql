SELECT 
    ddh.region,
    (COUNT(ddh.facility) * 1000000 / dpr.total_population)
FROM dim_doh_hospital ddh 
JOIN dim_population_region dpr 
    ON ddh.region = dpr.region
GROUP BY 1;
