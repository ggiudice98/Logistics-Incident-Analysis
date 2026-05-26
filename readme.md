# Logistics Incidents Analysis (SQL + Power BI)
*An Incidents Assessment of a Class 8 Trucking Company (2022–2024)*

## Project Overview
This project performs an analysis of a fictional logistics company's incidents reports using a synthetic relational database modeled on real-world industry data. 
The project is structured in two parts: an Exploratory Data Analysis establishing baseline operational health, followed by a focused Driver Risk & Incident Analysis producing actionable safety findings.

**Dataset:** [Logistics Operations Database — Kaggle (Yogape Rodriguez)](https://www.kaggle.com/datasets/yogape/logistics-operations-database)
A synthetic operational database from a fictional Class 8 trucking company spanning 2022–2024. Contains 85,000+ loads across 14 interconnected tables with proper foreign key relationships covering driver assignments, fuel purchases, maintenance schedules, and delivery performance.

---

## The Stack

| Layer | Tools |
|---|---|
| Language | SQL (PostgreSQL), DAX |
| Visualization | Power BI |
| Key Techniques | CTEs, Window Functions, Multi-Table Joins, Conditional Aggregation |

---

## Part 1: Exploratory Data Analysis

Organized into five sections moving from a company-wide pulse check to granular root-cause analysis.

**Section 1 — Company Baseline**
Establishment of core KPIs: Total Revenue, Average Load Value, On-Time Delivery Rate, and Fleet Utilization. Baseline understanding of organizational health before drilling into specifics.

**Section 2 — Revenue & Route P&L**
True profitability calculated by subtracting fuel and maintenance costs from load revenue. Identification of underperforming routes generating high revenue but low or negative net margin. Detention time analysis surfacing warehouse bottlenecks.

**Section 3 — Fleet & Maintenance**
Truck make comparison for reliability and downtime. Maintenance-to-Revenue ratio analysis to identify when an asset becomes a financial liability.

**Section 4 — Driver Performance**
Fuel efficiency (ton-MPG) benchmarked against route baselines. On-time rates and experience correlation at the individual driver level.

**Section 5 — Delivery Performance**
Root cause analysis of delays — Detention Time versus actual transit time.

---

## Part 2: Driver Risk & Incident Analysis

A focused safety audit built on top of the EDA findings. Moving from descriptive to analytical, this section scores drivers, segments risk, and identifies where preventable incidents concentrate.

**Incident Overview**
Fleet-wide breakdown of total incidents by fault type (at-fault, preventable not-at-fault, not-at-fault) and severity (Severe, Moderate, Minor). Preventable incident rate calculated as a headline KPI.

**Driver Risk Segmentation Model**
150 drivers scored across five dimensions: incident severity, fault type, tenure amplifier, experience amplifier, and fuel efficiency delta versus route baseline. Drivers classified into four risk tiers — High, Medium, Low, and No Risk — to prioritize safety intervention.

**Route Incident Analysis**
Incidents mapped to origin and destination city by month, identifying routes with disproportionate safety risk. Preventable percentage calculated per route to separate high-volume routes from genuinely dangerous ones.

*Findings compiled into an Incident Analysis Report and Power BI dashboard.*

---

## Executive Summary of Insights

*In Progress*
