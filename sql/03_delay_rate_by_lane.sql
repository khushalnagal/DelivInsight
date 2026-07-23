USE delivinsight;

SELECT
    delivery_partner,
    region,
    vehicle_type,
    COUNT(*) AS total_deliveries,
    SUM(CASE WHEN delivery_status = 'delayed' THEN 1 ELSE 0 END) AS delayed_count,
    SUM(CASE WHEN delivery_status = 'failed' THEN 1 ELSE 0 END) AS failed_count,
    ROUND(
        SUM(CASE WHEN delivery_status IN ('delayed', 'failed') THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS problem_rate_pct
FROM deliveries
GROUP BY delivery_partner, region, vehicle_type
HAVING COUNT(*) >= 20
ORDER BY problem_rate_pct DESC
LIMIT 15;