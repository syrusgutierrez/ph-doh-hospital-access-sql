# PH DOH Hospital Access Analysis (SQL) *ONGOING

## Project Overview
This project analyzes the distribution of Department of Health (DOH) hospitals across regions in the Philippines using SQL. Instead of relying on hospital counts alone, the analysis adjusts for population size to identify regions that may be underserved.

The main goal of this project is to demonstrate SQL skills and analytical thinking using real Philippine data.

## Objectives 
I used PostgreSQL and SQL to explore:
- How many DOH hospitals exist per region
- Hospital availability relative to population
- Which regions fall below the national average
- How many hospitals are needed for underserved regions to catch up

The main goal of this project is to show my SQL skills and analytical thinking, not dashboards or machine learning.

## Problem Statement
Healthcare access varies across the Philippines, and looking at hospital counts alone doesn’t tell the whole story. A region with many hospitals might still be underserved if its population is large. This project uses PostgreSQL to measure hospital access by population, find regions below the national average, and estimate gaps in hospital availability.

## Key Insights
- Hospital access varies significantly once population is considered.
- Some regions consistently fall below the national average.
- Normalizing data is necessary to make fair regional comparisons.

## Data Sources
**DOH Hospital Data** ([Source](https://sites.google.com/view/doh-hfdb/facilities))

**Table:** `dim_doh_hospital`

| Column | Description |
| :--- | :--- |
| **facility** | Name of DOH hospital |
| **region** | Administrative region |
| **province** | Province |
| **city_or_municipality** | City / Municipality |

**Population Data** ([Source](https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__1A__PO/0011A6DPHH0.px/?rxid=7a97f790-4ee2-4d9b-bba4-4486d26a422d))

**Table:** `dim_population_region`

| Column | Description |
| :--- | :--- |
| **region** | Administrative region |
| **total_population** | Total regional population |

## Tools Used
| Tool | Purpose |
|------|---------|
| PostgreSQL | SQL engine used to execute queries |
| Excel / Power Query | Cleaning raw hospital and population data |

## SQL Analysis
**- How many DOH hospitals are there per region?**
```
SELECT 
    region,
    COUNT(facility) AS hospital_count
FROM dim_doh_hospital
GROUP BY region;
```
**Steps:**
- Selected `region` and used COUNT to `facility` to show hospital count in each region.
- Grouped the aggregated result by `region`

**Insight**

This provides a baseline view of hospital distribution across regions. However, this does not yet account for population differences.

**- How many hospitals are available per million people per region?**
```
SELECT 
    ddh.region,
    dpr.total_population,
    (COUNT(ddh.facility) * 1000000 / dpr.total_population) AS hospitals_per_million
FROM dim_doh_hospital ddh
JOIN dim_population_region dpr 
    ON ddh.region = dpr.region
GROUP BY ddh.region, dpr.total_population;
```
**Steps:**
- Used JOIN to merge `dim_doh_hospital` and `dim_population_region` to show the rate `hospitals_per_million`
- Grouped the aggregated result by `ddh.region` and `dpr.total_population`
  
**Insight**

Normalizing hospital counts by population allows fair comparison between regions of different sizes.

**- What is the national average hospital access?**
```
WITH hospital_rate AS (
    SELECT 
        ddh.region,
        (COUNT(ddh.facility) * 1000000 / dpr.total_population) AS hospitals_per_million
    FROM dim_doh_hospital ddh
    JOIN dim_population_region dpr 
        ON ddh.region = dpr.region
    GROUP BY ddh.region, dpr.total_population
)
SELECT 
    AVG(hospitals_per_million) AS avg_hospitals_per_million
FROM hospital_rate;
```
**Steps:**
- I turned the previous code to Common Table Expression (CTE) as `hospital_rate`. 
- With this I performed the AVG function on `hospitals_per_million` to find the average.

**Insight** 

The national average is used as a benchmark to identify underserved regions.

**- Which regions fall below the national average hospital access?**
```
WITH hospital_rate AS (
    SELECT 
        ddh.region,
        (COUNT(ddh.facility) * 1000000 / dpr.total_population) AS hospitals_per_million
    FROM dim_doh_hospital ddh
    JOIN dim_population_region dpr 
        ON ddh.region = dpr.region
    GROUP BY ddh.region, dpr.total_population
),
national_avg AS (
    SELECT 
        AVG(hospitals_per_million) AS avg_hospitals_per_million
    FROM hospital_rate
)
SELECT 
    hr.region,
    hr.hospitals_per_million
FROM hospital_rate hr
JOIN national_avg na
    ON hr.hospitals_per_million < na.avg_hospitals_per_million;
```
**Steps:**
- Continued with the CTE and making the second CTE `avg_hospitals_per_million` as `national_avg`.
- In the outer query, I used JOIN on `hospital_rate` and `national_avg` where the `hospitals_per_million` is lower than `avg_hospitals_per_million` to find underserved regions.

**Insight**

These regions have fewer hospitals per person compared to the national benchmark.

**- How many hospitals are needed to reach the national average?**
```
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
        AVG(hospitals_per_million) AS avg_hospitals_per_million,
        AVG(hospital_count) AS avg_hospital_count
    FROM hospital_rate
),
lowest_region AS (
    SELECT
        hr.region,
        hr.hospitals_per_million,
        hr.hospital_count,
        na.avg_hospital_count
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
```
**Steps:**
- I introduced again the 3rd CTE where it is named as `lowest_region` and this CTE selects the region where the `hospitals_per_million` is lower than the `avg_hospitals_per_million`
- On the outer query, I used JOIN to combine the `hospital_rate` and `lowest_region` to 






## Methodology
- The analysis follows these steps:
- Aggregate DOH hospitals by region
- Join hospital data with population data
- Compute hospitals per million population
- Calculate national averages for comparison
- Identify regions below national benchmarks
- Estimate hospital gaps for underserved regions
All analysis was done using PostgreSQL.


## Repository Structure
```text
ph-healthcare-sql-analysis/
── data/
    └── raw/
        └── doh_hospital_population_raw.xlsx
    └── cleaned/
        └── dim_doh_hospital_cleaned.csv
        └── dim_population_region_cleaned.csv
── sql/
    └── 01_hospital_count_by_region.sql
    └── 02_hospitals_per_million.sql
    └── 03_below_national_average.sql
    └── 04_hospital_gap_calculation.sql
    └── 05_consistently_underserved_regions.sql
── docs/
── README.md
```

## Limitations
- Only DOH hospitals are included.
- Population data is aggregated at the regional level.
- Hospital capacity and services are not considered.

