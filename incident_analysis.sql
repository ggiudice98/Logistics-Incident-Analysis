WITH last_date AS (
    SELECT MAX(load_date) AS last_date
    FROM loads
),

driver_tenure AS ( SELECT driver_id,
                    ROUND((CASE WHEN termination_date IS NOT NULL THEN (termination_date - hire_date) ELSE (last_date - hire_date) END) / 365.25, 1) AS tenure_years
                    FROM drivers
                     CROSS JOIN last_date       
),

route_baselines AS (SELECT l.route_id,
                            AVG((l.weight_lbs / 2000.0 * t.actual_distance_miles) /NULLIF(t.fuel_gallons_used, 0)) AS route_avg_ton_mpg
    FROM trips t JOIN loads l ON t.load_id = l.load_id
   WHERE t.fuel_gallons_used IS NOT NULL
    GROUP BY l.route_id
),

driver_deltas AS (SELECT t.driver_id,
                    AVG((l.weight_lbs / 2000.0 * t.actual_distance_miles) /
                    NULLIF(t.fuel_gallons_used, 0) - rb.route_avg_ton_mpg)   AS avg_ton_mpg_delta
           
    FROM trips t JOIN loads l ON t.load_id = l.load_id JOIN route_baselines rb ON l.route_id = rb.route_id
    WHERE t.driver_id IS NOT NULL AND t.fuel_gallons_used IS NOT NULL
    GROUP BY t.driver_id
),

incidents_per_driver AS (SELECT driver_id,
                        COUNT(incident_id) AS total_incidents,
                        COUNT(*) FILTER (WHERE at_fault_flag = true) AS at_fault_incidents,
                        COUNT(*) FILTER (WHERE at_fault_flag = false AND preventable_flag = true)   AS preventable_not_at_fault,
                        COUNT(*) FILTER (WHERE at_fault_flag = false AND preventable_flag = false)  AS not_at_fault_incidents,
                        COUNT(*) FILTER (WHERE description ILIKE 'Severe%') AS severe_incidents,
                        COUNT(*) FILTER (WHERE description ILIKE 'Moderate%') AS moderate_incidents,
                        COUNT(*) FILTER (WHERE description ILIKE 'Minor%') AS minor_incidents,
                        SUM(CASE WHEN at_fault_flag = true AND description ILIKE 'Severe%' THEN 4
                         WHEN at_fault_flag = true AND description ILIKE 'Moderate%' THEN 3
                        WHEN at_fault_flag = true AND description ILIKE 'Minor%' THEN 2
                         WHEN at_fault_flag = false AND preventable_flag = true AND description ILIKE 'Severe%' THEN 2
                        WHEN at_fault_flag = false AND preventable_flag = true AND description ILIKE 'Moderate%' THEN 1
                        WHEN at_fault_flag = false AND preventable_flag = true AND description ILIKE 'Minor%' THEN 1 ELSE 0 END) AS raw_incident_score
                        FROM safety_incidents
                         GROUP BY driver_id
),

trip_count AS (SELECT driver_id,
                COUNT(trip_id) AS total_trips
                FROM trips
                WHERE driver_id IS NOT NULL
                 GROUP BY driver_id
),

combined AS (SELECT d.driver_id,
           d.first_name,
           d.last_name,
           d.years_experience,
           dt.tenure_years,
           COALESCE(i.total_incidents, 0) AS total_incidents,
           COALESCE(i.at_fault_incidents, 0)  AS at_fault_incidents,
           COALESCE(i.preventable_not_at_fault, 0) AS preventable_not_at_fault,
           COALESCE(i.not_at_fault_incidents, 0) AS not_at_fault_incidents,
           COALESCE(i.severe_incidents, 0) AS severe_incidents,
           COALESCE(i.moderate_incidents, 0) AS moderate_incidents,
           COALESCE(i.minor_incidents, 0) AS minor_incidents,
           COALESCE(i.raw_incident_score, 0) AS raw_incident_score,
           COALESCE(tc.total_trips, 0) AS total_trips,
           ROUND(dd.avg_ton_mpg_delta::numeric, 4) AS avg_ton_mpg_delta
    FROM drivers d JOIN driver_tenure dt ON d.driver_id = dt.driver_id
    LEFT JOIN incidents_per_driver i ON d.driver_id = i.driver_id
    LEFT JOIN trip_count tc ON d.driver_id = tc.driver_id
    JOIN driver_deltas dd ON d.driver_id = dd.driver_id
),

risk_scores AS (
    SELECT c.driver_id,
           c.first_name,
           c.last_name,
           c.years_experience,
           c.tenure_years,
           c.total_incidents,
           c.at_fault_incidents,
           c.preventable_not_at_fault,
           c.not_at_fault_incidents,
           c.severe_incidents,
           c.moderate_incidents,
           c.minor_incidents,
           c.raw_incident_score,
           c.total_trips,
           c.avg_ton_mpg_delta,
           (c.raw_incident_score +
               CASE WHEN c.tenure_years < 2
                    AND c.total_incidents > 0 THEN 1 ELSE 0 END +
               CASE WHEN c.years_experience < 3
                    AND c.total_incidents > 0 THEN 1 ELSE 0 END +
               CASE WHEN c.avg_ton_mpg_delta < 0 THEN 1 ELSE 0 END) AS risk_score
             FROM combined c
)

SELECT driver_id,
       first_name,
       last_name,
       years_experience,
       tenure_years,
       total_incidents,
       at_fault_incidents,
       preventable_not_at_fault,
       not_at_fault_incidents,
       severe_incidents,
       moderate_incidents,
       minor_incidents,
       total_trips,
       avg_ton_mpg_delta,
       risk_score,
       CASE
           WHEN risk_score >= 6 THEN 'High Risk'
           WHEN risk_score BETWEEN 3 AND 5 THEN 'Medium Risk'
           WHEN risk_score BETWEEN 1 AND 2 THEN 'Low Risk'
           ELSE 'No Risk' END AS risk_tier
        FROM risk_scores
        ORDER BY risk_score DESC, total_incidents DESC;

--2 Types of incidents 
SELECT
    si.driver_id,
    d.first_name,
    d.last_name,
    si.incident_type,
    si.at_fault_flag,
    si.preventable_flag,
    si.description
FROM safety_incidents si JOIN drivers d ON si.driver_id = d.driver_id
WHERE si.at_fault_flag = true OR si.preventable_flag = true
ORDER BY si.driver_id, si.incident_date;

-- 3. Most common incident Types
    SELECT
    incident_type,
    COUNT(*) AS total_incidents,
    COUNT(*) FILTER (WHERE at_fault_flag = true) AS at_fault,
    COUNT(*) FILTER (WHERE preventable_flag = true) AS preventable,
    ROUND(COUNT(*) FILTER (WHERE preventable_flag = true)::numeric/ COUNT(*) * 100, 2) AS preventable_pct
    FROM safety_incidents
GROUP BY incident_type
ORDER BY total_incidents DESC;

--4 Preventable Incidents Percentage of Total
    SELECT
    COUNT(*) AS total_incidents,
    COUNT(*) FILTER (WHERE at_fault_flag = true) AS at_fault,
    COUNT(*) FILTER (WHERE at_fault_flag = false AND preventable_flag = true)  AS preventable_not_at_fault,
    COUNT(*) FILTER (WHERE at_fault_flag = false AND preventable_flag = false) AS not_at_fault,
    COUNT(*) FILTER (WHERE at_fault_flag = true OR preventable_flag = true) AS total_preventable,
    ROUND(COUNT(*) FILTER (WHERE at_fault_flag = true OR preventable_flag = true) * 100.0 / COUNT(*), 1) AS preventable_pct
FROM safety_incidents;

--5 Route Incidents and AVG Driver Tenure

WITH last_date AS (
    SELECT MAX(load_date) AS end_date
    FROM loads
),

driver_tenure AS (
    SELECT d.driver_id,
           ROUND((CASE WHEN d.termination_date IS NOT NULL THEN (d.termination_date - d.hire_date)
            ELSE (ld.end_date - d.hire_date) END) / 365.25, 1) AS tenure_years
    FROM drivers d CROSS JOIN last_date ld
)

SELECT
    l.route_id,
    r.origin_city,
    r.destination_city,
    COUNT(si.incident_id) AS total_incidents,
    COUNT(*) FILTER (WHERE si.at_fault_flag = true) AS at_fault,
    COUNT(*) FILTER (WHERE si.at_fault_flag = false AND si.preventable_flag = true) AS preventable_not_at_fault,
    COUNT(*) FILTER (WHERE si.description ILIKE 'Severe%') AS severe,
    COUNT(*) FILTER (WHERE si.description ILIKE 'Moderate%') AS moderate,
    COUNT(*) FILTER (WHERE si.description ILIKE 'Minor%') AS minor,
    ROUND(COUNT(*) FILTER (WHERE si.at_fault_flag = true OR si.preventable_flag = true)
        * 100.0 / NULLIF(COUNT(si.incident_id), 0), 1 ) AS preventable_pct,
    ROUND(AVG(dt.tenure_years), 1) AS avg_driver_tenure_years
FROM safety_incidents si JOIN trips t ON si.driver_id = t.driver_id AND si.trip_id = t.trip_id
JOIN loads l ON t.load_id = l.load_id JOIN routes r ON l.route_id = r.route_id
JOIN driver_tenure dt ON si.driver_id = dt.driver_id
GROUP BY l.route_id, r.origin_city, r.destination_city
ORDER BY total_incidents DESC;

--6 Route Incidents by Date

SELECT
    l.route_id,
    r.origin_city,
    r.destination_city,
    DATE_TRUNC('month', si.incident_date) AS incident_month,
    COUNT(si.incident_id) AS total_incidents,
    COUNT(*) FILTER (WHERE si.at_fault_flag = true) AS at_fault,
    COUNT(*) FILTER (WHERE si.at_fault_flag = false AND si.preventable_flag = true) AS preventable_not_at_fault,
    COUNT(*) FILTER (WHERE si.description ILIKE 'Severe%') AS severe,
    COUNT(*) FILTER (WHERE si.description ILIKE 'Moderate%') AS moderate,
    COUNT(*) FILTER (WHERE si.description ILIKE 'Minor%') AS minor
FROM safety_incidents si JOIN trips t  ON si.driver_id = t.driver_id AND si.trip_id = t.trip_id
JOIN loads l  ON t.load_id = l.load_id JOIN routes r ON l.route_id = r.route_id
GROUP BY l.route_id, r.origin_city, r.destination_city, DATE_TRUNC('month', si.incident_date)
ORDER BY incident_month DESC, total_incidents DESC;