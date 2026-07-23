USE delivinsight;

SELECT
    delivery_partner,
    region,
    vehicle_type,
    COUNT(*) AS total_deliveries,
    SUM(CASE WHEN delivery_status = 'delayed' THEN 1 ELSE 0 END) AS delayed_count,
    SUM(CASE WHEN delivery_status = 'failed' THEN 1 ELSE 0 END) AS failed_count,
    ROUND(
        SUM(
            CASE
                WHEN delivery_status = 'delayed' THEN delivery_cost * 0.15
                WHEN delivery_status = 'failed' THEN delivery_cost + 100
                ELSE 0
            END
        ), 2
    ) AS total_cost_exposure
FROM deliveries
GROUP BY delivery_partner, region, vehicle_type
HAVING COUNT(*) >= 20
ORDER BY total_cost_exposure DESC
LIMIT 15;