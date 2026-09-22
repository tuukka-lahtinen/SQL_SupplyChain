-- Todellinen vs luvattu toimitusaika toimitustavoittain
SELECT
    shipping_mode,
    ROUND(AVG(days_for_shipment_scheduled), 2) AS avg_promised_days,
    ROUND(AVG(days_for_shipping_real), 2) AS avg_actual_days,
    ROUND(AVG(days_for_shipping_real - days_for_shipment_scheduled), 2) AS avg_gap_days
FROM fact_orders
GROUP BY shipping_mode
ORDER BY avg_gap_days DESC;
