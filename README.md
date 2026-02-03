# PH DOH Hospital Access Analysis (SQL) *ONGOING

## Project Overview
This project analyzes the distribution of Department of Health (DOH) hospitals across regions in the Philippines using SQL. Instead of relying on hospital counts alone, the analysis adjusts for population size to identify regions that may be underserved.

The main goal of this project is to demonstrate SQL skills and analytical thinking using real Philippine data.

## Objectives 
I used PostgreSQL and SQL to explore:
- How many DOH hospitals exist per region
- Hospital availability relative to population
- Which regions fall below the national average
- How many hospitals are needed for the most underserved region to reach the national average

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
### • How many DOH hospitals are there per region?
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

### • How many hospitals are available per million people per region?
```
SELECT 
    ddh.region,
    dpr.total_population,
    ROUND(COUNT(ddh.facility) * 1000000.0 / dpr.total_population, 2) AS hospitals_per_million
FROM dim_doh_hospital ddh 
JOIN dim_population_region dpr 
    ON ddh.region = dpr.region
GROUP BY ddh.region, dpr.total_population;
```
**Steps:**
- Used JOIN to merge `dim_doh_hospital` and `dim_population_region` to show the rate `hospitals_per_million`
- Grouped the aggregated result by `ddh.region` and `dpr.total_population`
- Used ROUND on the `hospitals_per_million` to round value to 2 decimals
  
**Insight**

Normalizing hospital counts by population allows fair comparison between regions of different sizes.

### • Which regions fall below the national average hospital access?
```
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
```
**Steps:**
- I created a second CTE named `national_avg` to get the average of the `hospitals_per_million`
- In the outer query, I used JOIN on `hospital_rate` and `national_avg` where `hospitals_per_million` is lower than the `avg_hospitals_per_million` to get underserved regions

**Insight** 

This identifies regions that are underserved relative to the national average hospital availability.

### • How many hospitals are needed for the most underserved region to reach the national average?
```
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

```
**Steps:**
- I created a third CTE named `lowest_region` and used JOIN on `hospital_rate` to combine it with the `national_avg` where the `hospitals_per_million` is lower than the `avg_hospitals_per_million`. I also used LIMIT 1 to limit the output into 1 region that is most underserved.
- On the outer query, I used JOIN to combine the `hospital_rate` and `lowest_region` where `region` is their identifier.

**Insight** 
This identifies how many addtional hospitals are needed to reach the national average and since this is theoretical, this would be rounded up to the nearest whole hospital.

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
── README.md
```

## Limitations
- Only DOH hospitals are included.
- Population data is aggregated at the regional level.
- Hospital capacity and services are not considered.

