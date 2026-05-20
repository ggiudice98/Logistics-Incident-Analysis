
--Section 01 — Company Baseline

-- 1. Total Revenue, Total loads and AVG load revenue
CREATE VIEW company_baseline AS
SELECT SUM(revenue + fuel_surcharge + accessorial_charges) AS total_revenue,
        COUNT(load_id) AS total_loads,
        ROUND(AVG(revenue + fuel_surcharge + accessorial_charges), 2)   AS avg_load_revenue
FROM loads
WHERE load_status = 'Completed'
;

--2 Delivery rates
    -- Flag only 55.67% of shipments are on time
CREATE VIEW on_time_performance AS
SELECT COUNT(*) FILTER (WHERE on_time_flag = true) AS on_time_loads,
          COUNT(*) FILTER (WHERE on_time_flag = false) AS late_loads,
        COUNT(*)  AS total_events,
        ROUND(COUNT(*) FILTER (WHERE on_time_flag = true) * 100.0 / COUNT(*), 2) AS on_time_pct
FROM delivery_events;

--3 Avg Cost per Mile

WITH fuel_by_truck AS (SELECT truck_id,
                        SUM(total_cost) AS total_fuel
                        FROM fuel_purchases
                        GROUP BY truck_id
),

maintenance_by_truck AS (SELECT truck_id, 
                        SUM(maintenance_cost) AS total_maintenance,
                        SUM(total_miles) AS total_miles
                        FROM truck_utilization_metrics
                         GROUP BY truck_id
)

SELECT ROUND(
        (SUM(f.total_fuel) + SUM(m.total_maintenance)) / SUM(m.total_miles), 2) AS cost_per_mile
FROM fuel_by_truck f JOIN maintenance_by_truck m ON f.truck_id = m.truck_id
;

--4. Fleet Utilization Rate
CREATE VIEW fleet_utilization AS 
SELECT ROUND(AVG(utilization_rate) * 100, 2) AS avg_fleet_utilization_pct
FROM truck_utilization_metrics
;

--5 Avg Driver Tenure
CREATE VIEW avg_driver_tenure AS 
WITH last_date AS (
    SELECT MAX(load_date) AS last_date
    FROM loads
)

SELECT ROUND(AVG(CASE WHEN termination_date IS NOT NULL THEN (termination_date - hire_date)ELSE (last_date - hire_date)
        END) / 365.25, 1) AS avg_tenure_years
        FROM drivers CROSS JOIN last_date
;

--6 Revenue by load type (load_type)
CREATE VIEW revenue_by_load_type AS 
SELECT load_type,
        SUM(revenue + fuel_surcharge + accessorial_charges) AS total_revenue
FROM loads 
WHERE load_status = 'Completed'
GROUP BY load_type
ORDER BY total_revenue DESC 