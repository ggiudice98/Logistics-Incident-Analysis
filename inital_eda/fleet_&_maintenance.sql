
--1. Truck utilization rate by truck make

SELECT t.make,
        ROUND(AVG(tum.utilization_rate) * 100, 2) AS avg_utilization_pctg

FROM truck_utilization_metrics tum JOIN trucks t ON tum.truck_id = t.truck_id
GROUP BY t.make
ORDER BY avg_utilization_pctg DESC

;

-- 2 Maintenance Visits and total trips by Truck Make

SELECT t.make,
        SUM(tum.maintenance_events) AS total_maintenance_events,
        SUM(tum.trips_completed) AS total_trips
FROM truck_utilization_metrics tum JOIN trucks t ON tum.truck_id = t.truck_id
GROUP BY t.make
ORDER BY  total_trips DESC

--3 Maintenance Cost vs Revenue Per Truck

WITH rev_maint AS ( SELECT truck_id,
        SUM(total_revenue) AS total_rev,
        SUM(maintenance_cost) AS total_maintenance_cost
FROM truck_utilization_metrics
GROUP BY truck_id),

rev_vs_cost AS ( SELECT truck_id,
                        (total_rev - total_maintenance_cost) AS profit_loss,
                        CASE WHEN (total_rev - total_maintenance_cost) > 0 THEN 'Profitable' ELSE 'Loss' END AS flag
                FROM rev_maint
)

SELECT rc.truck_id,
        rm.total_rev,
        rm.total_maintenance_cost,
        rc.profit_loss,
        rc.flag
FROM rev_vs_cost rc JOIN rev_maint rm ON rc.truck_id = rm.truck_id
ORDER BY profit_loss DESC 

--4 Downtime hours by truck brand

SELECT tum.truck_id, 
        t.make,
        SUM(tum.downtime_hours) AS total_time_down
FROM truck_utilization_metrics tum JOIN trucks t ON tum.truck_id = t.truck_id
GROUP BY tum.truck_id, t.make
ORDER BY total_time_down DESC
