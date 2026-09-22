-- Tuotteiden kannattavuusranking kategorian sisällä
-- (marginaali = order_item_profit_ratio, keskiarvo tuotteittain)
WITH product_margin AS (
    SELECT
        category_name,
        product_name,
        COUNT(*) AS n_orders,
        ROUND(AVG(order_item_profit_ratio) * 100, 2) AS avg_margin_pct,
        ROUND(SUM(sales), 2) AS total_sales
    FROM fact_orders
    WHERE order_date < '2017-10-01'
    GROUP BY category_name, product_name
)
SELECT
    category_name,
    product_name,
    n_orders,
    avg_margin_pct,
    total_sales,
    RANK() OVER (
        PARTITION BY category_name
        ORDER BY avg_margin_pct DESC
    ) AS margin_rank_in_category
FROM product_margin
QUALIFY margin_rank_in_category <= 3
ORDER BY category_name, margin_rank_in_category;
