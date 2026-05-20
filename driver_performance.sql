
--1. years of experience vs safety incidents

WITH last_date AS (
    SELECT MAX(load_date) AS last_date
    FROM loads
),

driver_tenure AS ( SELECT driver_id,
                    ROUND((CASE WHEN termination_date IS NOT NULL THEN (termination_date - hire_date) ELSE (last_date - hire_date)
                     END) / 365.25, 1) AS tenure_years
                    FROM drivers CROSS JOIN last_date)


SELECT d.first_name,
        d.last_name,
        dt.tenure_years,
        COUNT(si.incident_id) AS incident_count
FROM drivers d JOIN safety_incidents si ON d.driver_id = si.driver_id JOIN driver_tenure dt ON d.driver_id = dt.driver_id
GROUP BY d.first_name,d.last_name, dt.tenure_years
ORDER BY dt.tenure_years DESC 

--2 On Time Rate by Driver

SELECT d.first_name,
        d.last_name,
        ROUND((dm.on_time_delivery_rate * 100) , 1) AS on_time_pctg
FROM driver_monthly_metrics dm JOIN drivers d ON dm.driver_id = d.driver_id
ORDER BY on_time_pctg DESC 

--3 Fuel Efficiency by Driver Seniority

WITH last_date AS (
    SELECT MAX(load_date) AS last_date
    FROM loads
),

driver_tenure AS ( SELECT driver_id,
                    ROUND((CASE WHEN termination_date IS NOT NULL THEN (termination_date - hire_date) ELSE (last_date - hire_date)
                     END) / 365.25, 1) AS tenure_years
                    FROM drivers CROSS JOIN last_date)

SELECT d.first_name,
        d.last_name,
        dt.tenure_years,
        SUM(dm.average_mpg) AS total_avg_mpg
FROM driver_monthly_metrics dm JOIN drivers d ON dm.driver_id = d.driver_id JOIN driver_tenure dt ON dt.driver_id = dm.driver_id
GROUP BY d.first_name, d.last_name, dt.tenure_years
ORDER BY total_avg_mpg DESC

-- 4. Revenue per Driver

SELECT d.first_name,
        d.last_name,
        SUM(dmm.total_revenue) AS total_rev
FROM driver_monthly_metrics dmm JOIN drivers d ON dmm.driver_id = d.driver_id
GROUP BY d.first_name, d.last_name
ORDER BY total_rev DESC 

