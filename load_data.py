"""
Loads all Olist CSV files from the ./csvs folder into the Postgres tables
created by schema.sql.

Requirements:
    pip install pandas sqlalchemy psycopg2-binary

Usage:
    python load_data.py
"""

import os
import pandas as pd
from sqlalchemy import create_engine

# --- Database connection settings (match docker-compose.yml) ---
DB_USER = "olist_user"
DB_PASSWORD = "olist_pass"
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "olist_db"

CSV_FOLDER = "csvs"

# Maps CSV filename -> target table name (same name here, but kept explicit)
FILES_TO_TABLES = {
    "olist_customers_dataset.csv": "olist_customers_dataset",
    "olist_sellers_dataset.csv": "olist_sellers_dataset",
    "olist_products_dataset.csv": "olist_products_dataset",
    "product_category_name_translation.csv": "product_category_name_translation",
    "olist_geolocation_dataset.csv": "olist_geolocation_dataset",
    "olist_orders_dataset.csv": "olist_orders_dataset",
    "olist_order_items_dataset.csv": "olist_order_items_dataset",
    "olist_order_payments_dataset.csv": "olist_order_payments_dataset",
    "olist_order_reviews_dataset.csv": "olist_order_reviews_dataset",
}

# Columns that should be parsed as timestamps, per table
DATE_COLUMNS = {
    "olist_orders_dataset": [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date",
    ],
    "olist_order_items_dataset": ["shipping_limit_date"],
    "olist_order_reviews_dataset": [
        "review_creation_date",
        "review_answer_timestamp",
    ],
}

# Load order matters because of foreign key constraints:
# parents before children.
LOAD_ORDER = [
    "olist_customers_dataset.csv",
    "olist_sellers_dataset.csv",
    "olist_products_dataset.csv",
    "product_category_name_translation.csv",
    "olist_geolocation_dataset.csv",
    "olist_orders_dataset.csv",
    "olist_order_items_dataset.csv",
    "olist_order_payments_dataset.csv",
    "olist_order_reviews_dataset.csv",
]


def main():
    conn_str = f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    engine = create_engine(conn_str)

    for filename in LOAD_ORDER:
        table_name = FILES_TO_TABLES[filename]
        filepath = os.path.join(CSV_FOLDER, filename)

        if not os.path.exists(filepath):
            print(f"⚠️  Skipping {filename} — file not found in '{CSV_FOLDER}/'")
            continue

        print(f"Loading {filename} -> {table_name} ...")

        parse_dates = DATE_COLUMNS.get(table_name)
        df = pd.read_csv(filepath, parse_dates=parse_dates)

        df.to_sql(
            table_name,
            engine,
            if_exists="append",   # tables already created by schema.sql
            index=False,
            method="multi",
            chunksize=5000,
        )

        print(f"   -> {len(df)} rows loaded.")

    print("\nAll done. Data loaded into Postgres.")


if __name__ == "__main__":
    main()
