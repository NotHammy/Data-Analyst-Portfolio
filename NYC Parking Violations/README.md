# NYC Parking Violations Analysis

## Project Overview

This repository contains SQL scripts and a dynamic dashboard for analysing parking violations issued in New York City from 1 July 2021 to 30 June 2022. The project aims to identify trends and patterns in parking violations across different times, locations, and other dimensions provided in the dataset. Insights drawn from this analysis are intended to inform urban planning, improve traffic management, and optimise law enforcement resource allocation.

### Purpose

The purpose of this analysis is to leverage the NYC Parking Violations data to enhance understanding of parking behaviour in NYC. This supports policy-making by providing empirical evidence on the effectiveness of current parking regulations and identifying areas where improvements are needed.

## Dataset

The dataset includes records of parking violations for the fiscal year 2022, as provided by the NYC Open Data portal. Each record includes details such as the registration state, vehicle type, issue date, violation description, and more.
Link - https://data.cityofnewyork.us/City-Government/Parking-Violations-Issued-Fiscal-Year-2022/7mxj-7a6y/about_data

## Tools Used

- **Microsoft SQL Server**: Used for storing and querying the data.
- **Power BI**: For creating a dynamic dashboard that visualises the data.
- **Python** (optional): For any data cleaning or additional analysis not handled directly in SQL.

## Key Features of the Dashboard

The dynamic dashboard provides a visual analysis of:
- Total number of violations and their distribution by various factors such as vehicle type and registration state.
- Trends over time, including the most common times for violations to occur.
- Comparative analysis across different states excluding New York to highlight external impacts.
- Day of the week analysis to understand when violations are most likely to occur.

## SQL Scripts

The SQL scripts in this repository include:
- Creation of a unified table to store and query parking violations data.
- Queries that extract key metrics such as the most common violations, violation counts by vehicle body type, and temporal trends in violation occurrences.

## Usage

After setting up the database and dashboard:
1. Open the dashboard using Power BI or Tableau.
2. Explore different views and filters to analyse the parking violation data.
3. Use the insights to inform decision-making in urban planning and law enforcement strategies.

## Contributing

Contributions are welcome. If you have ideas on how to improve the analysis or the dashboard, please fork the repository and submit a pull request.

