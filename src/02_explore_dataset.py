
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

from pathlib import Path

# --------------------------------------------------
# 1. PROJECT CONFIGURATION
# --------------------------------------------------

ROOT = Path(__file__).resolve().parents[1]

RAW = ROOT / "data" / "raw"
REPORTS = ROOT / "reports"
CHARTS = REPORTS / "charts"

REPORTS.mkdir(exist_ok=True)
CHARTS.mkdir(exist_ok=True)

sns.set_theme(style="whitegrid")

# --------------------------------------------------
# 2. LOAD DATASETS
# --------------------------------------------------

def load_csv(filename):

    path = RAW / filename

    try:
        return pd.read_csv(path, encoding="utf-8",
                           low_memory=False)
    except UnicodeDecodeError:
        return pd.read_csv(path, encoding="latin1",
                           low_memory=False)


orders = load_csv("olist_orders_dataset.csv")
customers = load_csv("olist_customers_dataset.csv")
items = load_csv("olist_order_items_dataset.csv")
products = load_csv("olist_products_dataset.csv")
reviews = load_csv("olist_order_reviews_dataset.csv")
translations = load_csv("product_category_name_translation.csv")

print("All analytical datasets loaded successfully!")

# --------------------------------------------------
# 3. BASIC DATASET OVERVIEW
# --------------------------------------------------

datasets = {
    "orders": orders,
    "customers": customers,
    "order_items": items,
    "products": products,
    "reviews": reviews
}

overview = []

for name, df in datasets.items():

    overview.append({
        "Dataset": name,
        "Rows": len(df),
        "Columns": len(df.columns),
        "Missing Cells": int(df.isna().sum().sum()),
        "Duplicate Rows": int(df.duplicated().sum())
    })

overview_df = pd.DataFrame(overview)

print("\nDATASET OVERVIEW")
print(overview_df.to_string(index=False))

# --------------------------------------------------
# 4. DATE CONVERSION
# --------------------------------------------------

date_columns = [
    "order_purchase_timestamp",
    "order_approved_at",
    "order_delivered_carrier_date",
    "order_delivered_customer_date",
    "order_estimated_delivery_date"
]

for col in date_columns:

    orders[col] = pd.to_datetime(
        orders[col], errors="coerce"
    )

print("\nPURCHASE DATE RANGE")

print("Start:",
      orders["order_purchase_timestamp"].min())

print("End:",
      orders["order_purchase_timestamp"].max())

# --------------------------------------------------
# 5. ORDER STATUS ANALYSIS
# --------------------------------------------------

order_status = (
    orders["order_status"]
    .value_counts()
    .rename_axis("Order Status")
    .reset_index(name="Order Count")
)

plt.figure(figsize=(10, 5))

sns.barplot(
    data=order_status,
    x="Order Status",
    y="Order Count"
)

plt.title("Order Status Distribution")
plt.xticks(rotation=30)
plt.tight_layout()

plt.savefig(CHARTS / "order_status.png", dpi=300)
plt.close()

# --------------------------------------------------
# 6. ORDER AND REVENUE ANALYSIS
# --------------------------------------------------

# Aggregate item values to order level first.
# This avoids duplicating orders in later joins.

order_values = (
    items.groupby("order_id")
    .agg(
        product_revenue=("price", "sum"),
        freight_revenue=("freight_value", "sum"),
        total_items=("order_item_id", "count")
    )
    .reset_index()
)

sales = orders.merge(
    order_values,
    on="order_id",
    how="left"
)

# Use delivered orders for completed-sales analysis.
delivered_sales = sales[
    sales["order_status"] == "delivered"
].copy()

delivered_sales["purchase_month"] = (
    delivered_sales["order_purchase_timestamp"]
    .dt.to_period("M")
    .astype(str)
)

monthly_sales = (
    delivered_sales.groupby("purchase_month")
    .agg(
        orders=("order_id", "nunique"),
        product_revenue=("product_revenue", "sum"),
        freight_revenue=("freight_revenue", "sum")
    )
    .reset_index()
)

monthly_sales["total_item_and_freight"] = (
    monthly_sales["product_revenue"]
    + monthly_sales["freight_revenue"]
)

plt.figure(figsize=(13, 5))

sns.lineplot(
    data=monthly_sales,
    x="purchase_month",
    y="product_revenue",
    marker="o"
)

plt.title("Monthly Delivered Product Revenue")
plt.xlabel("Month")
plt.ylabel("Revenue (BRL)")
plt.xticks(rotation=60)
plt.tight_layout()

plt.savefig(CHARTS / "monthly_revenue.png", dpi=300)
plt.close()

# --------------------------------------------------
# 7. CUSTOMER REPEAT PURCHASE ANALYSIS
# --------------------------------------------------

customer_orders = delivered_sales[
    ["order_id", "customer_id"]
].merge(
    customers[["customer_id", "customer_unique_id"]],
    on="customer_id",
    how="left"
)

customer_frequency = (
    customer_orders.groupby("customer_unique_id")
    .agg(
        total_orders=("order_id", "nunique")
    )
    .reset_index()
)

total_customers = len(customer_frequency)

repeat_customers = int(
    (customer_frequency["total_orders"] > 1).sum()
)

one_time_customers = total_customers - repeat_customers

repeat_rate = (
    repeat_customers / total_customers * 100
    if total_customers > 0 else 0
)

print("\nCUSTOMER RETENTION OVERVIEW")

print("Delivered customers:", total_customers)
print("Repeat customers:", repeat_customers)
print("One-time customers:", one_time_customers)

print(f"Repeat purchase rate: {repeat_rate:.2f}%")

customer_segments = pd.DataFrame({
    "Segment": ["One-time", "Repeat"],
    "Customers": [one_time_customers, repeat_customers]
})

plt.figure(figsize=(7, 5))

sns.barplot(
    data=customer_segments,
    x="Segment",
    y="Customers"
)

plt.title("One-time vs Repeat Customers")
plt.tight_layout()

plt.savefig(CHARTS / "repeat_customers.png", dpi=300)
plt.close()

# --------------------------------------------------
# 8. PRODUCT CATEGORY ANALYSIS
# --------------------------------------------------

category_data = items.merge(
    products[
        ["product_id", "product_category_name"]
    ],
    on="product_id",
    how="left"
)

category_data = category_data.merge(
    translations,
    on="product_category_name",
    how="left"
)

delivered_order_ids = set(
    delivered_sales["order_id"]
)

category_data = category_data[
    category_data["order_id"].isin(delivered_order_ids)
].copy()

category_data["category"] = (
    category_data["product_category_name_english"]
    .fillna(category_data["product_category_name"])
    .fillna("Unknown")
)

category_revenue = (
    category_data.groupby("category")
    .agg(
        revenue=("price", "sum"),
        units_sold=("order_item_id", "count")
    )
    .reset_index()
    .sort_values("revenue", ascending=False)
)

top_categories = category_revenue.head(10)

plt.figure(figsize=(12, 6))

sns.barplot(
    data=top_categories,
    x="revenue",
    y="category"
)

plt.title("Top 10 Product Categories by Revenue")
plt.xlabel("Product Revenue (BRL)")
plt.ylabel("Category")
plt.tight_layout()

plt.savefig(CHARTS / "top_categories.png", dpi=300)
plt.close()

# --------------------------------------------------
# 9. CUSTOMER REVIEW ANALYSIS
# --------------------------------------------------

review_distribution = (
    reviews["review_score"]
    .value_counts()
    .sort_index()
    .rename_axis("Review Score")
    .reset_index(name="Review Count")
)

plt.figure(figsize=(8, 5))

sns.barplot(
    data=review_distribution,
    x="Review Score",
    y="Review Count"
)

plt.title("Customer Review Score Distribution")
plt.tight_layout()

plt.savefig(CHARTS / "review_distribution.png", dpi=300)
plt.close()

average_review = reviews["review_score"].mean()

# --------------------------------------------------
# 10. DELIVERY PERFORMANCE
# --------------------------------------------------

delivered = delivered_sales.dropna(
    subset=[
        "order_purchase_timestamp",
        "order_delivered_customer_date"
    ]
).copy()

delivered["delivery_days"] = (
    delivered["order_delivered_customer_date"]
    - delivered["order_purchase_timestamp"]
).dt.total_seconds() / 86400

delivered["delivery_status"] = np.select(
    [
        delivered["order_estimated_delivery_date"].isna(),
        delivered["order_delivered_customer_date"]
        <= delivered["order_estimated_delivery_date"]
    ],
    [
        "Unknown",
        "On Time"
    ],
    default="Late"
)
delivery_summary = (
    delivered.groupby("delivery_status")
    .agg(
        orders=("order_id", "nunique"),
        average_delivery_days=("delivery_days", "mean")
    )
    .reset_index()
)

# --------------------------------------------------
# 11. EXPORT RESULTS TO EXCEL
# --------------------------------------------------

with pd.ExcelWriter(
    REPORTS / "exploratory_analysis.xlsx",
    engine="openpyxl"
) as writer:

    overview_df.to_excel(
        writer, sheet_name="Dataset Overview", index=False
    )

    order_status.to_excel(
        writer, sheet_name="Order Status", index=False
    )

    monthly_sales.to_excel(
        writer, sheet_name="Monthly Sales", index=False
    )

    customer_frequency.to_excel(
        writer, sheet_name="Customer Frequency", index=False
    )

    category_revenue.to_excel(
        writer, sheet_name="Category Revenue", index=False
    )

    review_distribution.to_excel(
        writer, sheet_name="Review Analysis", index=False
    )

    delivery_summary.to_excel(
        writer, sheet_name="Delivery Analysis", index=False
    )

# --------------------------------------------------
# 12. FINAL BUSINESS SUMMARY
# --------------------------------------------------

print("\n" + "=" * 55)
print("OLIST E-COMMERCE ANALYTICS - EDA SUMMARY")
print("=" * 55)

print(f"Total orders: {len(orders):,}")

print(f"Delivered orders: {len(delivered_sales):,}")

print(f"Product revenue (BRL): "
      f"{delivered_sales['product_revenue'].sum():,.2f}")

print(f"Repeat purchase rate: {repeat_rate:.2f}%")

print(f"Average review score: {average_review:.2f}")

print(
    "Average delivery days: "
    f"{delivered['delivery_days'].mean():.2f}"
)

print("\nEDA COMPLETED SUCCESSFULLY!")
print("Excel report:", REPORTS / "exploratory_analysis.xlsx")
print("Charts folder:", CHARTS)
