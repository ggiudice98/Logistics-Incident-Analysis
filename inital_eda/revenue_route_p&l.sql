
-- 1. Top 10 customers by revenue with % of total revenue

WITH customer_revenue AS ( SELECT c.customer_id,
                            c.customer_name,
                            SUM(l.revenue + l.fuel_surcharge + l.accessorial_charges) AS total_revenue
                            FROM customers c JOIN loads l ON c.customer_id = l.customer_id
                             WHERE load_status = 'Completed'
                            GROUP BY c.customer_id, c.customer_name
    ),

    company_revenue AS (   SELECT SUM(revenue + fuel_surcharge + accessorial_charges) AS total_rev
                            FROM loads 
                            WHERE load_status = 'Completed')


SELECT customer_id,
        customer_name,
        total_revenue,
        ROUND(total_revenue/total_rev *100, 2 ) AS pctg_of_total_revenue
FROM customer_revenue CROSS JOIN company_revenue
ORDER BY total_revenue DESC


--2 Revenue by Route 

SELECT r.route_id,
        r.origin_city,
        r.destination_city,
        SUM(revenue + fuel_surcharge + accessorial_charges) AS total_revenue
FROM loads l JOIN routes r ON l.route_id = r.route_id
WHERE l.load_status = 'Completed'
GROUP BY r.route_id, r.origin_city, r.destination_city
ORDER BY total_revenue DESC

--3 Fuel Cost Per Route

SELECT r.route_id,
        r.origin_city,
        r.destination_city,
        r.typical_distance_miles,
        SUM(fp.total_cost) AS total_fuel_cost
FROM trips t JOIN fuel_purchases fp ON t.trip_id = fp.trip_id JOIN loads l ON t.load_id = l.load_id JOIN routes r ON l.route_id = r.route_id
WHERE l.load_status = 'Completed'
GROUP BY r.route_id, r.origin_city, r.destination_city, r.typical_distance_miles
ORDER BY total_fuel_cost DESC 

--4 Quarterly Revenue Trend

SELECT 
    DATE_TRUNC('quarter', load_date) AS quarter,
    COUNT(load_id) AS total_loads,
    SUM(revenue + fuel_surcharge + accessorial_charges) AS total_revenue,
    ROUND(AVG(revenue + fuel_surcharge + accessorial_charges), 2) AS avg_revenue_per_load
FROM loads
WHERE load_status = 'Completed'
GROUP BY DATE_TRUNC('quarter', load_date)
ORDER BY quarter ASC;






