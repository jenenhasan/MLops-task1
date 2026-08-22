# MLops-task1
# Olist E-Commerce Data — MLOps Task 1

Loads the Olist Brazilian E-Commerce dataset (from Kaggle) into a local PostgreSQL
database running in Docker, as part of Task 1 of the MLOps Training 2026/2027.

## Goal

Get the raw CSV data into a real relational database, understand the tables and
their relationships, and prepare for the eventual ML problem: predicting whether
an order will be delivered late or on time.

## Setup

1. `docker compose up -d` — starts Postgres in a container
2. `docker exec -i olist_postgres psql -U olist_user -d olist_db < schema.sql` — creates the 9 tables
3. `pip install pandas sqlalchemy psycopg2-binary` — installs Python dependencies
4. `python3 load_data.py` — loads all 9 CSVs into the database

CSV files are downloaded separately from Kaggle:
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
and placed in a `csvs/` folder (not included in this repo — see `.gitignore`).

## Tables

- `olist_customers_dataset`
- `olist_sellers_dataset`
- `olist_products_dataset`
- `product_category_name_translation`
- `olist_geolocation_dataset`
- `olist_orders_dataset`
- `olist_order_items_dataset`
- `olist_order_payments_dataset`
- `olist_order_reviews_dataset`

Tables are linked by `order_id`, `customer_id`, `product_id`, `seller_id`, and
`zip_code_prefix`.

## The problem we're preparing for

Late-delivery classification: predict whether a delivered order will arrive after
its estimated delivery date, using `order_estimated_delivery_date` vs.
`order_delivered_customer_date` from `olist_orders_dataset`.

## Verification

### Tables created
```
olist_db=# \dt
                        List of relations
 Schema |               Name                | Type  |   Owner    
--------+-----------------------------------+-------+------------
 public | olist_customers_dataset           | table | olist_user
 public | olist_geolocation_dataset         | table | olist_user
 public | olist_order_items_dataset         | table | olist_user
 public | olist_order_payments_dataset      | table | olist_user
 public | olist_order_reviews_dataset       | table | olist_user
 public | olist_orders_dataset              | table | olist_user
 public | olist_products_dataset            | table | olist_user
 public | olist_sellers_dataset             | table | olist_user
 public | product_category_name_translation | table | olist_user
(9 rows)
```

### Row counts
```
olist_db=# SELECT COUNT(*) FROM olist_orders_dataset;
 count 
-------
 99441
(1 row)

olist_db=# SELECT COUNT(*) FROM olist_customers_dataset;
 count 
-------
 99441
(1 row)

olist_db=# SELECT COUNT(*) FROM olist_order_items_dataset;
 count  
--------
 112650
(1 row)
```

### Example join (orders + customers)
```
olist_db=# SELECT o.order_id, o.order_status, c.customer_city, c.customer_state
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
LIMIT 3;

            order_id              | order_status | customer_city | customer_state 
----------------------------------+--------------+---------------+----------------
 e481f51cbdc54678b7cc49136f2d6af7 | delivered    | sao paulo     | SP
 53cdb2fc8bc7dce0b6741e2150273451 | delivered    | barreiras     | BA
 47770eb9100c2d0c44946d9cf07ec65d | delivered    | vianopolis    | GO
(3 rows)
```

## Files

- `docker-compose.yml` — spins up Postgres in Docker
- `schema.sql` — creates the 9 tables with correct types and foreign keys
- `load_data.py` — loads all 9 CSVs from `csvs/` into the database
