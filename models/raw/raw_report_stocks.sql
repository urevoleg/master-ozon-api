{{ config(
 tags=['raw_report_stocks', 'report_stocks', 'raw'],
 target='duckdb',
 schema='raw',
 materialized='table',
 pre_hook="SET s3_region = '';
    SET s3_endpoint = '127.0.0.1:9002';
    SET s3_use_ssl = false;
    SET s3_url_style = 'path';
    SET s3_access_key_id = 's3admin';
    SET s3_secret_access_key = 's3pass_)';
    ATTACH 'dbname=tmp user=shpz password=12345 host=127.0.0.1 port=5432' AS db (TYPE POSTGRES);"
) }}

WITH raw AS (SELECT
--"Идентификатор склада" AS warehouse_id,
"Название склада" AS warehouse_name,
"Артикул" AS offer_id,
"Наименование товара" item_name,
"Доступно на моем складе, шт" AS free_to_sell_amount,
"Зарезервировано на моем складе, шт" as reserved_amount,
'fbs' AS delivery_type
FROM {{ ref('raw_report_stocks_fbs') }}
UNION ALL
SELECT
--sku,
warehouse_name,
item_code AS offer_id,
item_name,
--promised_amount,
free_to_sell_amount,
reserved_amount,
'fbo' AS delivery_type
FROM {{ ref('raw_report_stocks_fbo') }})
SELECT md5(warehouse_name) AS warehouse_pk, *
FROM raw