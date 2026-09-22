-- Kuukausittainen myynti ja 3kk liukuva keskiarvo
-- Rajattu 2017-09 asti: loka 2017 - tammi 2018 näyttää äkillisen,
-- tasomaisen pudotuksen tilausmäärässä (n. 5200 -> 2100/kk),
-- todennäköisesti datan keräyksen katkos eikä aito myynnin lasku.
-- Ks. README kohta "Data quality notes".
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS month,
        SUM(sales) AS total_sales
    FROM fact_orders
    WHERE order_date < '2017-10-01'
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
