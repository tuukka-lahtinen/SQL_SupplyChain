-- Myöhästymisriski toimitustavan mukaan
SELECT
    shipping_mode,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN late_delivery_risk THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
        100.0 * SUM(CASE WHEN late_delivery_risk THEN 1 ELSE 0 END) / COUNT(*),
        1
    ) AS late_pct
FROM fact_orders
GROUP BY shipping_mode
ORDER BY late_pct DESC;
