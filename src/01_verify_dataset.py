
import pandas as pd
from pathlib import Path

# Project directories
ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = ROOT / "data" / "raw"
REPORT_DIR = ROOT / "reports"

REPORT_DIR.mkdir(parents=True, exist_ok=True)

# Expected dataset files
FILES = [
    "olist_customers_dataset.csv",
    "olist_geolocation_dataset.csv",
    "olist_order_items_dataset.csv",
    "olist_order_payments_dataset.csv",
    "olist_order_reviews_dataset.csv",
    "olist_orders_dataset.csv",
    "olist_products_dataset.csv",
    "olist_sellers_dataset.csv",
    "product_category_name_translation.csv"
]

# Keys used for initial uniqueness checks
KEYS = {
    "olist_customers_dataset.csv": ["customer_id"],
    "olist_orders_dataset.csv": ["order_id"],
    "olist_order_items_dataset.csv": [
        "order_id", "order_item_id"
    ],
    "olist_order_payments_dataset.csv": [
        "order_id", "payment_sequential"
    ],
    "olist_order_reviews_dataset.csv": ["review_id"],
    "olist_products_dataset.csv": ["product_id"],
    "olist_sellers_dataset.csv": ["seller_id"],
    "product_category_name_translation.csv": [
        "product_category_name"
    ]
}

table_report = []
missing_report = []

print("=" * 60)
print("OLIST DATASET VERIFICATION")
print("=" * 60)

for filename in FILES:

    filepath = RAW_DIR / filename

    if not filepath.exists():
        print(f"MISSING: {filename}")
        missing_report.append(filename)
        continue

    try:
        try:
            df = pd.read_csv(filepath, encoding="utf-8",
                             low_memory=False)
            encoding_used = "utf-8"
        except UnicodeDecodeError:
            df = pd.read_csv(filepath, encoding="latin1",
                             low_memory=False)
            encoding_used = "latin1"

        rows, columns = df.shape

        duplicate_rows = int(df.duplicated().sum())

        key_duplicates = None
        key_nulls = None

        if filename in KEYS:
            key_columns = KEYS[filename]

            key_duplicates = int(
                df.duplicated(subset=key_columns).sum()
            )

            key_nulls = int(
                df[key_columns].isna().any(axis=1).sum()
            )

        null_cells = int(df.isna().sum().sum())

        table_report.append({
            "File": filename,
            "Rows": rows,
            "Columns": columns,
            "Missing Cells": null_cells,
            "Duplicate Rows": duplicate_rows,
            "Duplicate Key Rows": key_duplicates,
            "Null Key Rows": key_nulls,
            "Encoding": encoding_used,
            "File Size MB": round(
                filepath.stat().st_size / (1024 ** 2), 2
            )
        })

        print(f"\nFILE: {filename}")
        print(f"Rows: {rows:,}")
        print(f"Columns: {columns}")
        print(f"Missing cells: {null_cells:,}")
        print(f"Duplicate rows: {duplicate_rows:,}")
        print(f"Duplicate key rows: {key_duplicates}")
        print(f"Null key rows: {key_nulls}")

    except Exception as error:
        print(f"ERROR processing {filename}: {error}")

# Export reports
summary_df = pd.DataFrame(table_report)

with pd.ExcelWriter(
    REPORT_DIR / "data_quality_report.xlsx",
    engine="openpyxl"
) as writer:

    summary_df.to_excel(
        writer, sheet_name="Table Summary", index=False
    )

    pd.DataFrame(
        {"Missing Files": missing_report}
    ).to_excel(
        writer, sheet_name="Missing Files", index=False
    )

print("\n" + "=" * 60)
print("VERIFICATION COMPLETED")
print("=" * 60)

print(f"Files found: {len(table_report)}/9")
print(f"Files missing: {len(missing_report)}")

print(
    f"\nReport saved at: "
    f"{REPORT_DIR / 'data_quality_report.xlsx'}"
)
