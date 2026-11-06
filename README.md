# E-Commerce Customer Behaviour & Retention Analytics

An end-to-end e-commerce analytics project using the Olist Brazilian E-Commerce Public Dataset. This project analyzes sales performance, customer behaviour, retention, RFM segmentation, product categories, seller performance, and delivery operations using PostgreSQL, SQL, Python, and Power BI.

## Project Overview

The objective is to transform raw e-commerce transaction data into meaningful business insights and interactive dashboards that support data-driven decision-making.

The project covers:

- Relational database design and data loading using PostgreSQL.
- Data quality assessment and validation using SQL.
- Sales and revenue analysis.
- Customer segmentation using RFM analysis.
- Customer cohort retention analysis.
- Product category and seller performance.
- Interactive business dashboards using Power BI.
- Business recommendations based on analytical findings.

## Business Questions

1. What are the overall sales and order performance metrics?
2. Which product categories generate the highest revenue?
3. Which customer states contribute the most revenue?
4. What percentage of customers make repeat purchases?
5. Which customer segments represent the greatest retention opportunities?
6. How does customer retention change across monthly cohorts?
7. What is the delivery performance across orders?
8. Which sellers generate the highest product revenue?

## Dataset

**Dataset:** Olist Brazilian E-Commerce Public Dataset

**Source:** [Kaggle – Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The dataset contains nine CSV files covering customers, orders, order items, payments, reviews, products, sellers, geolocation, and product category translations.

**Analysis period:** September 2016 – August 2018.

**License:** CC BY-NC-SA 4.0. Dataset attribution and license restrictions must be respected.

### Dataset Files

| File | Description |
|---|---|
| olist_customers_dataset.csv | Customer information |
| olist_geolocation_dataset.csv | Geographic coordinates and postal codes |
| olist_order_items_dataset.csv | Products purchased in each order |
| olist_order_payments_dataset.csv | Payment information |
| olist_order_reviews_dataset.csv | Customer reviews |
| olist_orders_dataset.csv | Order and delivery information |
| olist_products_dataset.csv | Product information |
| olist_sellers_dataset.csv | Seller information |
| product_category_name_translation.csv | English product category translations |

## Technology Stack

| Technology | Purpose |
|---|---|
| PostgreSQL | Relational database and data storage |
| SQL | Data quality checks and business analysis |
| Python | Data exploration and data processing |
| Pandas and NumPy | Data manipulation |
| Power BI Desktop | Interactive dashboards |
| DAX | KPI calculations and analytical measures |
| Git and GitHub | Version control and project sharing |

## Project Architecture

```text
Raw CSV Dataset
      |
      v
PostgreSQL Staging Schema
      |
      v
Data Quality Validation
      |
      v
PostgreSQL Analytics Schema
      |
      v
SQL Business Analysis
      |
      +---------------------+
      |                     |
      v                     v
Customer RFM          Cohort Retention
Segmentation          Analysis
      |                     |
      +----------+----------+
                 |
                 v
          Power BI Desktop
                 |
                 v
       Interactive Dashboards
                 |
                 v
        Business Insights
```

## Project Structure

```text
olist-ecommerce-analytics/
│
├── data/
│   ├── raw/
│   └── processed/
│
├── notebooks/
│   ├── 01_data_exploration.ipynb
│   ├── 02_data_cleaning.ipynb
│   └── 03_customer_analytics.ipynb
│
├── sql/
│   ├── 01_database_schema.sql
│   ├── 02_data_quality.sql
│   ├── 03_sales_analysis.sql
│   ├── 04_customer_segmentation.sql
│   ├── 05_cohort_retention.sql
│   └── 06_create_analytics_model.sql
│
├── dashboards/
│   └── ecommerce_analytics.pbix
│
├── reports/
│   ├── data_quality_report.xlsx
│   └── business_insights.md
│
├── docs/
│
├── src/
│
├── requirements.txt
├── .gitignore
└── README.md
```

## Database Design and Data Quality

The project uses two PostgreSQL schemas:

- `staging`: Stores the imported CSV data.
- `analytics`: Contains structured analytical tables with primary keys, foreign keys, and indexes.

### Data Quality Checks

The SQL validation process includes:

- Missing-value checks.
- Duplicate record checks.
- Referential integrity validation.
- Invalid price and freight checks.
- Order status validation.
- Payment and review validation.
- Duplicate key investigation.

The staging dataset contains 99,441 orders and 112,650 order-item records.

The review dataset requires special handling because `review_id` is not unique across the entire dataset. The analytical model preserves the original review identifier and uses a generated record identifier.

## SQL Analysis

The SQL analysis is organized into the following areas:

### 1. Sales Analysis

- Total orders and delivered orders.
- Delivered product revenue.
- Freight revenue.
- Average order value.
- Monthly and annual revenue.
- Product category performance.
- Seller performance.
- Customer-state revenue.
- Payment method analysis.
- Delivery performance.

### 2. RFM Customer Segmentation

RFM stands for:

- **Recency:** How recently a customer purchased.
- **Frequency:** How often a customer purchased.
- **Monetary:** How much a customer spent.

Customers are segmented using RFM scores to identify Champions, Loyal Customers, At Risk customers, Hibernating customers, and other segments.

### 3. Cohort Retention Analysis

Customers are grouped according to their first delivered purchase month. Subsequent delivered purchases are tracked across calendar months to understand repeat purchasing behaviour.

## Key Business Findings

### Executive Performance

| KPI | Result |
|---|---:|
| Total Orders | 99,441 |
| Delivered Orders | 96,478 |
| Delivery Rate | 97.02% |
| Product Revenue | R$13,221,498.11 |
| Freight Revenue | R$2,198,275.64 |
| Average Order Value | R$137.04 |

Product revenue represents delivered-order item prices excluding freight. It does not represent profit.

### Customer Retention

| Metric | Result |
|---|---:|
| Unique Customers | 93,358 |
| Repeat Customers | 2,801 |
| Repeat Customer Rate | 3.00% |
| At Risk Customers | 18,372 |

The low repeat customer rate highlights an opportunity to improve customer engagement and retention.

### Top Product Categories

| Category | Product Revenue |
|---|---:|
| Health & Beauty | R$1,233,131.72 |
| Watches & Gifts | R$1,166,176.98 |
| Bed, Bath & Table | R$1,023,434.76 |

### Cohort Retention

| Month After First Purchase | Weighted Retention |
|---|---:|
| Month 1 | 0.48% |
| Month 2 | 0.34% |
| Month 3 | 0.25% |

These figures measure subsequent calendar-month purchasing, not exact 30-day retention.

## Power BI Dashboard

The Power BI report contains three analytical pages.

### 1. Executive Overview

- Total Orders
- Delivered Orders
- Product Revenue
- Freight Revenue
- Average Order Value
- Delivery Rate
- Monthly Product Revenue Trend
- Order Status Distribution
- Purchase Year and Order Status slicers

### 2. Customer Analytics

- Total Customers
- Repeat Customers
- Repeat Customer Rate
- At Risk Customers
- RFM Customer Segmentation
- Customer Cohort Retention Matrix

### 3. Product & Seller Performance

- Top 10 Product Categories by Revenue
- Top 10 Sellers by Revenue
- Revenue by Customer State

**Power BI report:** `dashboards/ecommerce_analytics.pbix`

## Business Recommendations

1. Improve customer retention through personalized offers and loyalty programs.
2. Prioritize high-value At Risk customers for re-engagement campaigns.
3. Investigate customer demand in high-revenue states.
4. Monitor leading product categories to optimize inventory and marketing decisions.
5. Investigate late and undelivered orders to improve delivery operations.
6. Track customer retention and sales KPIs through regular dashboard reviews.

## Installation and Execution

### 1. Clone the repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd olist-ecommerce-analytics
```

Replace the placeholder with your actual GitHub repository URL.

### 2. Create a Python virtual environment

```bash
python -m venv venv
```

Activate it on Windows:

```cmd
venv\Scripts\activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Download the dataset

Download the Olist dataset from Kaggle and extract the nine CSV files into:

```text
data/raw/
```

### 5. Create the PostgreSQL database

```sql
CREATE DATABASE olist_analytics;
```

Connect to the database and execute the SQL scripts in the following order:

1. `01_database_schema.sql`
2. Import the CSV files into the staging tables.
3. `02_data_quality.sql`
4. `06_create_analytics_model.sql`
5. `03_sales_analysis.sql`
6. `04_customer_segmentation.sql`
7. `05_cohort_retention.sql`

### 6. Open the Power BI report

Open:

```text
dashboards/ecommerce_analytics.pbix
```

Connect to the PostgreSQL database if prompted and refresh the data.

## Limitations

- The dataset contains historical transactions from 2016–2018.
- Product revenue is not profit because product costs and operating expenses are not included.
- RFM segmentation is descriptive and does not predict future churn.
- Cohort retention uses calendar-month purchasing behaviour.
- Historical patterns should not be interpreted as guaranteed future business outcomes.

## Conclusion

This project demonstrates an end-to-end analytics workflow, from raw e-commerce data ingestion and SQL-based data quality validation to customer segmentation, cohort analysis, and interactive Power BI reporting.

It demonstrates practical skills in SQL, PostgreSQL, Python, data modeling, DAX, Power BI, and business insight generation.

## Dataset Attribution

Olist Brazilian E-Commerce Public Dataset  
Source: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce  
License: CC BY-NC-SA 4.0

This project is intended for educational and portfolio purposes. The original dataset license and attribution requirements apply.