# PH DOH Hospital Access Analysis (SQL) *ONGOING

## Project Overview
This project analyzes the distribution of Department of Health (DOH) hospitals across Philippine regions.
Instead of relying only on raw hospital counts, the analysis adjusts for population size to better identify regions that may be underserved.

## Objectives 
The objectives of this project are to:

- Count DOH hospitals by region
- Normalize hospital counts using regional population data
- Compare regions against the national average
- Identify regions that appear consistently underserved
- Estimate hospital gaps relative to national benchmarks


## Data Sources
DOH Hospital Data ([Source](https://sites.google.com/view/doh-hfdb/facilities))

**Table:** `dim_doh_hospital`

| Column | Description |
| :--- | :--- |
| **facility** | Name of DOH hospital |
| **region** | Administrative region |
| **province** | Province |
| **city_or_municipality** | City / Municipality |

Population Data ([Source](https://openstat.psa.gov.ph/PXWeb/pxweb/en/DB/DB__1A__PO/0011A6DPHH0.px/?rxid=7a97f790-4ee2-4d9b-bba4-4486d26a422d))

**Table:** `dim_population_region`

| Column | Description |
| :--- | :--- |
| **region** | Administrative region |
| **total_population** | Total regional population |

## Tools Used
- PostgreSQL
- SQL (CTEs, joins, aggregations)

## Methodology

- The analysis follows these steps:
- Aggregate DOH hospitals by region
- Join hospital data with population data
- Compute hospitals per million population
- Calculate national averages for comparison
- Identify regions below national benchmarks
- Estimate hospital gaps for underserved regions
All analysis was done using PostgreSQL.


## Project Structure

## Project Structure

```text
ph-healthcare-sql-analysis/
│
├── data/
│   ├── raw/
│   │   └── doh_hospital_population_raw.xlsx
│   │
│   ├── cleaned/
│   │   ├── dim_doh_hospital_cleaned.csv
│   │   └── dim_population_region_cleaned.csv
│
├── sql/
│
├── docs/
│
├── README.md
└── LICENSE



