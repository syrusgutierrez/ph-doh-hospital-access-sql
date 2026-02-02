SELECT 
    ddh.region,
    COUNT(ddh.facility) AS facility_count
FROM dim_doh_hospital ddh
GROUP BY 1;
