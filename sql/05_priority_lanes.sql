USE delivinsight;

WITH lane_metrics AS (
    SELECT delivery_partner, region, vehicle_type,
        COUNT(*) AS total_deliveries,
        SUM(CASE WHEN delivery_status = 'delayed' THEN 1 ELSE 0 END) AS delayed_count,
        SUM(CASE WHEN delivery_status = 'failed' THEN 1 ELSE 0 END) AS failed_count,
        ROUND( SUM(
                CASE
                    WHEN delivery_status = 'delayed' THEN delivery_cost * 0.15
                    WHEN delivery_status = 'failed' THEN delivery_cost + 100
                    ELSE 0
                END ), 2 ) AS total_cost_exposure,
        ROUND( SUM(CASE WHEN delivery_status IN ('delayed', 'failed') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2 ) AS problem_rate_pct
    FROM deliveries
    GROUP BY delivery_partner, region, vehicle_type
    HAVING COUNT(*) >= 20
),

ranked AS (
    SELECT
        *,
        RANK() OVER (ORDER BY total_cost_exposure DESC) AS cost_rank,
        RANK() OVER (ORDER BY problem_rate_pct DESC) AS problem_rank
    FROM lane_metrics
)

SELECT delivery_partner, region, vehicle_type, total_deliveries, total_cost_exposure, cost_rank, problem_rate_pct, problem_rank,
    CASE
        WHEN cost_rank <= 3 THEN 'Immediate Investigation'
        WHEN cost_rank <= 5 THEN 'High Priority Review'
        ELSE 'Monitor'
    END AS recommendation
FROM ranked
WHERE cost_rank <= 10 AND problem_rank > 10
ORDER BY cost_rank;