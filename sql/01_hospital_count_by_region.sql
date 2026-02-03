SELECT 
    region,
    COUNT(facility) AS hospital_count
FROM dim_doh_hospital
GROUP BY region;
