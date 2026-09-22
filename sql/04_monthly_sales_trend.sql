-- Kuukausittainen myynti ja 3kk liukuva keskiarvo
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS month,
        SUM(sales) AS total_sales
    FROM fact_orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    month,
    total_sales,
    ROUND(
        AVG(total_sales) OVER (
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS rolling_3mo_avg
FROM monthly
ORDER BY month;
