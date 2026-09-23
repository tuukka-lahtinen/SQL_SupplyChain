import pandas as pd
import matplotlib.pyplot as plt
import psycopg2

conn = psycopg2.connect(dbname="supplychain_analytics")

# late delivery by shipping mode
df1 = pd.read_sql(
    """
    SELECT shipping_mode,
           ROUND(100.0 * SUM(CASE WHEN late_delivery_risk THEN 1 ELSE 0 END) / COUNT(*), 1) AS late_pct
    FROM fact_orders
    GROUP BY shipping_mode
    ORDER BY late_pct DESC
""",
    conn,
)

plt.figure(figsize=(7, 5))
plt.bar(df1["shipping_mode"], df1["late_pct"])
plt.ylabel("% orders late")
plt.title("Late delivery rate by shipping mode")
plt.tight_layout()
plt.savefig("visuals/late_delivery_by_mode.png")
plt.close()

# monthly sales trend
df2 = pd.read_sql(
    """
    SELECT DATE_TRUNC('month', order_date)::DATE AS month, SUM(sales) AS total_sales
    FROM fact_orders
    WHERE order_date < '2017-10-01'
    GROUP BY 1
    ORDER BY 1
""",
    conn,
)
df2["rolling_avg"] = df2["total_sales"].rolling(3).mean()

plt.figure(figsize=(9, 5))
plt.plot(df2["month"], df2["total_sales"], label="monthly sales")
plt.plot(df2["month"], df2["rolling_avg"], label="3-month avg")
plt.ylabel("Sales ($)")
plt.title("Monthly sales, 2015-2017")
plt.legend()
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig("visuals/monthly_sales_trend.png")
plt.close()

conn.close()
print("done")
