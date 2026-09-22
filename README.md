# Supply Chain Operations Analytics (SQL)

SQL-based analysis of order fulfillment, delivery performance, and profitability
using the DataCo Smart Supply Chain dataset. Built with PostgreSQL, focused on
identifying operational issues.

## Dataset

- **Source:** [DataCo Smart Supply Chain for Big Data Analysis](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis) (Kaggle)
- **Size:** 180,519 order line items, 53 original columns
- **Content:** Orders, customers, products, shipping performance, and profitability
  across a global retailer selling clothing, sporting goods, and electronics
- **License:** CC BY 4.0 (Mendeley Data, original publisher)

## Tech stack

- PostgreSQL 16
- psql / VS Code (PostgreSQL extension)
- Git / GitHub

## Repository structure
sql/
01_staging_schema.sql -- raw staging table, all columns as TEXT
02_fact_orders.sql -- typed fact table, cast from staging
03_analysis_late_delivery.sql -- late delivery risk by shipping mode
03b_analysis_shipping_gap.sql -- promised vs. actual shipping days
04_monthly_sales_trend.sql -- monthly sales with 3-month rolling average
05_category_profitability_rank.sql -- top products by margin, ranked within category
data/
(raw CSV, not committed — see Setup)
docs/
(ER diagram, notes)

## Setup

1. Install PostgreSQL and create a database:
```bash
   createdb supplychain_analytics
```
2. Download the dataset from Kaggle (link above) and place
   `DataCoSupplyChainDataset.csv` in `data/`.
3. Build the staging and fact tables, in order:
```bash
   psql supplychain_analytics -f sql/01_staging_schema.sql
   psql supplychain_analytics -c "\COPY stg_supply_chain FROM 'data/DataCoSupplyChainDataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'LATIN1')"
   psql supplychain_analytics -f sql/02_fact_orders.sql
```
4. Run any analysis file individually, e.g.:
```bash
   psql supplychain_analytics -f sql/03_analysis_late_delivery.sql
```

Note: the source CSV is encoded in Latin-1, not UTF-8 — this must be specified
explicitly in the `COPY` command or the load will fail on accented characters.

## Data modeling approach

Data is loaded into a raw `stg_supply_chain` staging table (all columns as `TEXT`)
before being cast into a typed `fact_orders` table. This avoids load failures from
unexpected formatting and keeps type-casting logic explicit and auditable in SQL,
rather than relying on automatic type inference.

Excluded from `fact_orders`: customer email, password, first/last name, street
address, product image, and product description — either empty, placeholder
values, or PII not needed for aggregate analysis.

## Key findings

**Late delivery risk is driven by SLA design, not operational variability.**
First Class shipments are marked late 95.3% of the time, far more than Standard
Class (38.1%), despite being the fastest shipping mode. Breaking this down by
promised vs. actual shipping days shows why: First and Second Class carry a
near-constant ~1–2 day gap between promised and actual delivery on almost every
order, meaning the SLA itself is set shorter than the fulfillment process can
reliably meet. This is a mismatch between what's promised and what's operationally
achievable, not a random risk to be forecasted.

**Monthly sales are stable except for a likely data cutoff, not a real decline.**
Order volume holds steady at ~1.0–1.1M in sales per month from Jan 2015 through
Sep 2017, then drops sharply to roughly 40% of its prior level from Oct 2017
onward, with no gradual decline and no missing calendar days in the affected
months. This step-change pattern points to a data collection cutoff rather than
genuine demand collapse, so trend analysis in this project is scoped to
2015-01 through 2017-09 to avoid a misleading trend line.

## Data quality notes

- Order dates span 2015-01 to 2018-01, but Oct 2017–Jan 2018 show an abrupt,
  step-level drop in order volume (~5,200/month to ~2,100/month) despite full
  calendar days present in each month. Trend analyses are scoped to
  2015-01 through 2017-09 as a result.
- `sales` equals `order_item_quantity * order_item_product_price` exactly on
  every row; discounts are captured separately in `order_item_total`, not `sales`.
