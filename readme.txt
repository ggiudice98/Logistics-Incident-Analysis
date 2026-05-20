
Logistics Operations & Fleet Audit (SQL)
An Exploratory Data Analysis of 3-Year Logistics Performance (2022–2024)

Project Overview
This project performs an end-to-end audit of a logistics company's operations using a synthetic relational database modeled on real-world logistics operations. Moving beyond surface-level revenue metrics, this analysis dives deep into Route Profitability (P&L), Maintenance Impact, and Driver Efficiency to identify hidden money leaks and operational bottlenecks.
The project follows an initial Exploratory Data Analysis (EDA) approach to discover patterns in fuel consumption, detention times, and fleet utilization.

Dataset: Logistics Operations Database (Kaggle)
https://www.kaggle.com/datasets/yogape/logistics-operations-database

A complete operational database from a fictional Class 8 trucking company spanning three years (2022–2024). 
The database contains 85,000+ records across 14 interconnected tables with proper foreign key relationships, covering driver assignments, fuel purchases, maintenance schedules, and delivery performance.

The Stack

Language: SQL (PostgreSQL), DAX
Data Visualization: Power BI
Key Techniques: Common Table Expressions (CTEs), Window Functions, Multi-Table Joins, and Aggregations

Analysis Structure

The analysis is organized into five strategic sections, moving from an initial pulse check to granular root-cause analysis. 

Section 1: Company Baseline
Establishment of core KPIs: Total Revenue, Average Load Value, and Fleet Utilization. Understanding the general health of the organization before diving into specifics.

Section 2: Revenue & Route P&L
Calculating true profitability by subtracting fuel and maintenance costs from load revenue. Identifying "Dead Zones" — routes that generate high revenue but low (or negative) net margin. Analyzing Detention Time to identify warehouse bottlenecks.

Section 3: Fleet & Maintenance
Comparing truck brands (makes) for reliability and downtime. Analyzing the Maintenance-to-Revenue ratio to determine when an asset becomes a liability.

Section 4: Driver Performance
Correlating years of experience with safety incidents. Benchmarking fuel efficiency (MPG) and on-time rates by individual drivers.

Section 5: Delivery Performance
Root cause analysis of delays — Detention Time vs. actual transit time.

Executive Summary of Insights
In Progress
