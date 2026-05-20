
--1. On-time rate by route 

WITH route_counts AS (SELECT r.route_id,
        r.origin_city,
        r.destination_city,
        COUNT(event_id) AS total_count,
        COUNT(*) FILTER (WHERE on_time_flag = true)  AS on_time_count,
        COUNT(*) FILTER (WHERE on_time_flag = false) AS late_count
FROM delivery_events de JOIN loads l ON de.load_id = l.load_id JOIN routes r ON l.route_id = r.route_id
GROUP BY r.route_id, r.origin_city, r.destination_city)


SELECT route_id,
        origin_city,
        destination_city,
        on_time_count,
        late_count,
       ROUND((on_time_count ::numeric /total_count * 100), 2) AS on_time_pctg
FROM route_counts
ORDER BY on_time_pctg DESC

--2. Detention time impact on late deliveries

SELECT l.load_id,
        ROUND(EXTRACT(EPOCH FROM (actual_datetime - scheduled_datetime)) / 60, 1)  AS late_minutes,
        de.detention_minutes
FROM loads l JOIN delivery_events de ON l.load_id = de.load_id
WHERE load_status = 'Completed'
ORDER BY de.detention_minutes DESC

-- deeper analysis 

WITH detention_buckets AS (
    SELECT de.load_id,
        de.detention_minutes,
        
        de.on_time_flag,
        CASE WHEN de.detention_minutes = 0 THEN 'No Detention'
            WHEN de.detention_minutes <= 30 THEN '1-30 min'
            WHEN de.detention_minutes <= 60 THEN '31-60 min'
            WHEN de.detention_minutes <= 120 THEN '61-120 min'
            ELSE 'Over 120 min'
            END AS detention_bucket
        
    FROM delivery_events de JOIN loads l ON de.load_id = l.load_id
    WHERE l.load_status = 'Completed'
)

SELECT 
    detention_bucket,
    COUNT(*) AS total_loads,
    COUNT(*) FILTER (WHERE on_time_flag = false) AS late_loads,
    ROUND(COUNT(*) FILTER (WHERE on_time_flag = false)::numeric / COUNT(*) * 100, 2) AS late_rate_pct
        
FROM detention_buckets
GROUP BY detention_bucket
ORDER BY late_rate_pct DESC;




                          